-- Mid Project
-- Show the company's growth by using several metrics
use mavenfuzzyfactory;
show tables;

-- Task 1
-- session to order conversion rate by month to show the trend, gsearch is the source that we focus on.


select * from website_sessions;
select * from orders;


select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_order_cv_rate
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where 
	website_sessions.created_at < "2012-11-27"
    and utm_source = "gsearch"
group by
	1,2;
    
-- Task 2
-- monthly trend of session to order conversion rate in gsearch and spliting out nonbrand and brand campaign

select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
     count(distinct case when utm_campaign = "brand" then orders.order_id else null end)
    / count(distinct case when utm_campaign = "brand" then website_sessions.website_session_id else null end) as brand_sessions_order_cv_rate,
    count(distinct case when utm_campaign = "nonbrand" then orders.order_id else null end)
    / count(distinct case when utm_campaign = "nonbrand" then website_sessions.website_session_id else null end) as nonbrand_sessions_order_cv_rate
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where
	website_sessions.created_at < "2012-11-27"
    and utm_source = "gsearch"
group by 1, 2;

-- Task 3
-- dive into gsearch and nonbrnad, pull monthly sessions and orders split by device type
select device_type 
from website_sessions
group by
	device_type;

select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct case when device_type = "mobile" then website_sessions.website_session_id else null end) as mobile_sessions,
    count(distinct case when device_type = "mobile" then orders.order_id else null end) as mobile_order,
    count(distinct case when device_type = "mobile" then orders.order_id else null end)
    /count(distinct case when device_type = "mobile" then website_sessions.website_session_id else null end) as mobile_sessions_order_cv_rt,
    count(distinct case when device_type = "desktop" then website_sessions.website_session_id else null end) as desktop_sessions,
    count(distinct case when device_type = "desktop" then orders.order_id else null end) as desktop_sessions,
    count(distinct case when device_type = "desktop" then orders.order_id else null end)
    /count(distinct case when device_type = "desktop" then website_sessions.website_session_id else null end) as desktop_sessions_order_cv_rt
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where
	website_sessions.created_at < "2012-11-27"
    and utm_source = "gsearch"
    and utm_campaign = "nonbrand"
group by 1,2;
    
-- Task 4
-- one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. Pulling out monthly 
-- trends for gsearch, alongside  monthly trends for each of our other channels

select 
	distinct utm_source,
		utm_campaign,
        http_referer
from website_sessions
where created_at <"2012-11-27";


select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct case when utm_source = "gsearch" then website_sessions.website_session_id else null end) as gsearch_paid_sessions,
    count(distinct case when utm_source = "bsearch" then website_sessions.website_session_id else null end) as bsearch_paid_sessions,
    count(distinct case when utm_source is null and http_referer is not null then website_sessions.website_session_id else null end) as organic_search_sessions,
    count(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) as direct_type_in_sessions
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where 
	website_sessions.created_at < "2012-11-27"
group by 
	1,2;
    
    
-- Insights: the board members will be very happy to see organic search sessions and direct type sessions are growing in 8 months because they are not paying for these.




-- Task 5 
-- tell the story of our website performance improvements over the course of first 8 months
-- pull sessions to orders conversion rate, by month?



select * from website_pageviews;

select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as sessions_orders_cv_rt
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where
	website_sessions.created_at < "2012-11-27"
group by 1,2;

-- Task 6
-- for gsearch lander test, estimate the revenue that test earned us(hint: look at the increase in CVR from the test(Jun 19 - Jul 28)
-- and use nonbrand sessions and revenue since then to calculate incremental value.
select 
min(website_pageview_id) as first_test_pv
from website_pageviews
where pageview_url = "/lander-1";
-- first test pageview is 23504

drop table if exists first_test_pagview;
create temporary table first_test_pageview
select 
	website_sessions.website_session_id,
    min(website_pageviews.website_pageview_id) as first_pv_id
from website_pageviews
	inner join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where utm_source = "gsearch" and utm_campaign = "nonbrand"
	and website_sessions.created_at <= "2012-07-28"
    and website_pageviews.website_pageview_id >= 23504
group by 1;

select * from first_test_pageview;

drop table if exists landing_page_view;

create temporary table landing_page_view 
select 
	first_test_pageview.website_session_id,
    website_pageviews.pageview_url
from first_test_pageview
	left join website_pageviews
    on first_test_pageview.website_session_id = website_pageviews.website_session_id
where pageview_url in ("/home", "/lander-1");


select * from landing_page_view;


select 
	pageview_url as landing_page,
	count(distinct landing_page_view.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct landing_page_view.website_session_id) as session_order_cv_rt
    
from landing_page_view
	left join orders
    on landing_page_view.website_session_id = orders.website_session_id
group by 1;

-- home: cv - 0.0319, lander: cv - 0.0406
-- 0.0087 additional order per session

-- finding out the most recent pageview for gsearch and nonbrand where the traffic was sent to /home


select 
	max(website_sessions.website_session_id) as most_recent_home_pageview
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where utm_source = "gsearch" and utm_campaign = "nonbrand"
	and pageview_url = "/home"
    and website_sessions.created_at <"2012-11-27";

-- max website_session_id = 17145
select 
	count(website_session_id) as session_since_test
from website_sessions
	where utm_source = "gsearch"
		and utm_campaign = "nonbrand"
        and created_at < "2012-11-27"
        and website_session_id > 17145;
select 22972*0.0087; -- 200 additional order concluding




-- Task 7 
-- show a full conversion funnels from of the two pages to orders time(6/19 - 7/28)
use mavenfuzzyfactory;


select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/home' then 1 else 0 end as home_page,
    case when pageview_url = '/lander-1' then 1 else 0 end as custom_lander,
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-orignial-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = 'billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end thankyou_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where
	utm_source = 'gsearch' and utm_campaign = 'nonbrand'
	and website_sessions.created_at between "2012-06-19" and "2012-07-28"
    and website_pageviews.pageview_url in ('/home','/lander-1', '/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order');

drop table if exists session_level_made_it;

create temporary table session_level_made_it
select 
	website_session_id,
    max(home_page) as saw_homepage,
    max(custom_lander) as saw_custom_lander,
    max(product_page) as product_made_it,
    max(mrfuzzy_page) as mrfuzzy_made_it,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thankyou_page) as thankyou_made_it
from (select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/home' then 1 else 0 end as home_page,
    case when pageview_url = '/lander-1' then 1 else 0 end as custom_lander,
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end thankyou_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where
	utm_source = 'gsearch' and utm_campaign = 'nonbrand'
	and website_sessions.created_at between "2012-06-19" and "2012-07-28"
    and website_pageviews.pageview_url in ('/home','/lander-1', '/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
) as pageview_level
group by 
	website_session_id;
    
-- test session_level_made_it

select * from session_level_made_it;

-- look at differnt funnels numbers
select
	case when saw_homepage = 1 then 'saw_homepage'
		 when saw_custom_lander = 1 then 'saw_custom_lander'
	else 'uh oh... check on the logic'
	end as segment,
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
from session_level_made_it
group by 1;




select 
	case when saw_homepage = 1 then 'saw_homepage'
		 when saw_custom_lander = 1 then 'saw_custom_lander'
	else 'uh oh ... check on the logic'
    end as segment,
	count(distinct case when product_made_it = 1 then website_session_id else null end)
    /count(distinct website_session_id) as product_clickthrough_rate,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
    /count(distinct case when product_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate,
    count(distinct case when cart_made_it = 1 then website_session_id else null end)
    /count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as cart_clickthrough_rate,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end)
    /count(distinct case when cart_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate,
    count(distinct case when billing_made_it = 1 then website_session_id else null end)
    /count(distinct case when shipping_made_it = 1 then website_session_id else null end) as billing_clickthrough_rate,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end)
    /count(distinct case when billing_made_it = 1 then website_session_id else null end) as thankyou_clickthrough_rate
from session_level_made_it
group by 1;


-- Task 8
-- using /billing and /billing-2 as the test
-- step 1: find out when start to use billing-2 and who

select 
	min(website_pageview_id) as first_pv_id,
    min(created_at) as first_created_at
from website_pageviews
where pageview_url = '/billing-2';
-- id = 53550, date = 2012-09-10

-- step 2 
select
	website_pageviews.website_session_id,
	pageview_url as billing_version_seen,
    orders.order_id,
    orders.price_usd
from website_pageviews
	left join orders
    on website_pageviews.website_session_id = orders.website_session_id
where
	website_pageviews.website_pageview_id >= 53550
    and website_pageviews.created_at between "2012-09-10" and "2012-11-10"
    and pageview_url in ('/billing','/billing-2');



select 
	billing_version_seen,
    count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
    count(distinct order_id) / count(distinct website_session_id) as billing_cv_rt,
    sum(price_usd) / count(distinct website_session_id) as revenue_per_bliing_seen
from (select
	website_pageviews.website_session_id,
	pageview_url as billing_version_seen,
    orders.order_id, 
    orders.price_usd
from website_pageviews
	left join orders
    on website_pageviews.website_session_id = orders.website_session_id
where
	website_pageviews.website_pageview_id >= 53550
    and website_pageviews.created_at between "2012-09-10" and "2012-11-10"
    and pageview_url in ('/billing','/billing-2')
) as billing_level
group by 1;


-- lift: 31.34-22.83 = 8.5, every time a customer comes to the billing page you make $8.5 more than previous billing page.
select
	count(website_session_id) as billing_seen_last_month
from website_pageviews
where pageview_url in ('/billing','/billing-2')
	and created_at between '2012-10-27' and '2012-11-27';
    
-- 1194 from last month
-- 1194*8.5 will have $10,160 increase if using billing-2 page over in the last month




    




    
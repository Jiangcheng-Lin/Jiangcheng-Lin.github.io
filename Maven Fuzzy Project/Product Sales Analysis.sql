-- Product Sales Analysis

-- 1. To analyze sales performances at a product level,
-- we will look at our order data, and tie in a specific product(s) driving sales

-- 2. We want to know how much of our order volumes comes from each product, and 
-- the overall revenue and margin generated.
use mavenfuzzyfactory;
select * from orders;

select 
	primary_product_id,
    count(distinct order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    avg(price_usd) as aov
from orders
where order_id between 10000 and 11000
group by 1;

-- Assignment 1: Product-Level Sales Analysis


select
	year(created_at) as yr,
    month(created_at) as mo,
    count(distinct order_id) as sales,
    sum(price_usd) as total_revenue,
    sum(price_usd-cogs_usd) as total_margin
from orders
where created_at < "2013-01-03"
group by 1,2;


-- Assignment: Analyzing the product launches
select * from website_sessions;
select 
	distinct primary_product_id
from orders
where created_at between "2012-04-01" and "2013-04-05";

select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at)  as mo,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)
	/ count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as rev_per_session,
    count(distinct case when orders.primary_product_id = 1 then orders.order_id else null end) as product_one_order,
    count(distinct case when orders.primary_product_id = 2 then orders.order_id else null end) as product_two_order
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where 
	website_sessions.created_at between "2012-04-01" and "2013-04-05"
group by 1,2;



-- Product Level Website Analysis

-- Product Conversion
-- 1. Use website_pageviews data to identify users who viewed the/products page, 
-- and see which products they click next.

-- 2. From specific product pages, we will look at view-to-order
-- conversion rates, and create multi-step conversion funnels.
select 
	distinct pageview_url
from website_pageviews
where website_pageviews.created_at between "2013-02-01" and "2013-03-01";



select
	website_pageviews.pageview_url,
    count(distinct website_pageviews.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_pageviews.website_session_id) as viewed_to_product_rate
from website_pageviews
	left join orders
		on website_pageviews.website_session_id = orders.website_session_id
where website_pageviews.created_at between "2013-02-01" and "2013-03-01"
	and website_pageviews.pageview_url in ("/the-original-mr-fuzzy","/the-forever-love-bear")
group by 1;


-- Assignment: Product Pathing Analysis

-- step 1: select all pageviews for relevant sessions
select * from website_pageviews;

select
	website_sessions.website_session_id,
    website_sessions.created_at as created_at,
    case when pageview_url = "/products" then 1 else 0 end as product_page,
	case when pageview_url = "/the-original-mr-fuzzy" then 1 
		 when pageview_url = "/the-forever-love-bear" then 2
         else 0 end as w_next_pg
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between "2012-10-06" and "2013-04-06"
	and website_pageviews.pageview_url in ("/products","/the-original-mr-fuzzy","/the-forever-love-bear");
 
 -- step 2: create temporary product path table for funnels.
 drop table if exists product_path;
 
create temporary table product_path
select 
	website_session_id,
    date(created_at) as dt,
    max(product_page) as product_made_it,
    max(w_next_pg) as next_pg_made_it
from 
(select
	website_sessions.website_session_id,
    website_sessions.created_at as created_at,
    case when pageview_url = "/products" then 1 else 0 end as product_page,
	case when pageview_url = "/the-original-mr-fuzzy" then 1
		 when pageview_url = "/the-forever-love-bear" then 2
	else 0 end as w_next_pg
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between "2012-10-06" and "2013-04-06"
	and website_pageviews.pageview_url in ("/products","/the-original-mr-fuzzy","/the-forever-love-bear")
) as product_path_level
group by 1;

select * from product_path;
-- 1: "/the-original-mr-fuzzy", 2: "/the-forever-love-bear"
-- get the pct results
select
	case when dt < "2013-01-06" then "A.pre_product_2" else "B.Post_product_2" end as time_period,
    count(case when product_made_it = 1 then website_session_id else null end) as sessions,
    count(case when next_pg_made_it = 1 or next_pg_made_it = 2 then website_session_id else null end) as w_next_pg,
    count(case when next_pg_made_it = 1 or next_pg_made_it = 2 then website_session_id else null end)
    /count(case when product_made_it = 1 then website_session_id else null end) as pct_w_next_pg,
    count(case when next_pg_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(case when next_pg_made_it = 1 then website_session_id else null end)
    /count(case when product_made_it = 1 then website_session_id else null end) as pct_to_mrfuzzy,
    count(case when next_pg_made_it = 2 then website_session_id else null end) to_lovebear,
    count(case when next_pg_made_it = 2 then website_session_id else null end)
    /count(case when product_made_it = 1 then website_session_id else null end) as pct_to_lovebear
from product_path
group by 1;

-- After looking at the solution, we have different approach. it uses website_pageview_id for product as the base to find the next page which is more common use. 


-- Assignment: Building Product level conversion funnels

-- step 1: select all pageviews for relevant sessions
-- step 2: figure out which pageviews to look for 
-- step 3: pull all pageviews and identify the funnel steps
-- step 4: create the session level conversion funnel view
-- step 5: aggreate the data to access the funnel performance
drop table if exists sessions_seeing_product_pages;
create temporary table sessions_seeing_product_pages
select 
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
from website_pageviews
where created_at between "2013-01-06" and "2013-04-10"
	and pageview_url in ("/the-original-mr-fuzzy","/the-forever-love-bear");
    
select * from website_pageviews;
select
	distinct pageview_url
from sessions_seeing_product_pages
	left join website_pageviews
		on sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
        and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id;
        
-- step 3
select 
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    case when pageview_url = "/cart" then 1 else 0 end as cart_page,
    case when pageview_url = "/shipping" then 1 else 0 end as shipping_page,
    case when pageview_url = "/billing-2" then 1 else 0 end as billing_page,
    case when pageview_url = "/thank-you-for-your-order" then 1 else 0 end as thankyou_page
from sessions_seeing_product_pages
	left join website_pageviews
		on sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
        and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id;

-- step 4

drop table if exists session_level_funnel_view;
create temporary table session_level_funnel_view
select 
	website_session_id,
    product_page_seen,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thankyou_page) as thankyou_made_it
from 
(select 
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    case when pageview_url = "/cart" then 1 else 0 end as cart_page,
    case when pageview_url = "/shipping" then 1 else 0 end as shipping_page,
    case when pageview_url = "/billing-2" then 1 else 0 end as billing_page,
    case when pageview_url = "/thank-you-for-your-order" then 1 else 0 end as thankyou_page
from sessions_seeing_product_pages
	left join website_pageviews
		on sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
        and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id)
as pageview_level
group by 1, 2;

-- step 5
select * from session_level_funnel_view;

select
	case when product_page_seen = "/the-original-mr-fuzzy" then "mrfuzzy"
		else "lovebear" end as product_page_seen,
	count(distinct website_session_id) as sessions,
    count(case when cart_made_it = 1 then website_session_id else null end) as to_cart,
    count(case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
from session_level_funnel_view
group by 1;


select
	case when product_page_seen = "/the-original-mr-fuzzy" then "mrfuzzy"
		 when product_page_seen = "/the-forever-love-bear" then "lovebear"
		else "uh...check logic"
        end as product_page_seen,
	count(distinct website_session_id) as sessions,
    count(case when cart_made_it = 1 then website_session_id else null end)
    /count(distinct website_session_id) as product_clickthrough_rate,
    count(case when shipping_made_it = 1 then website_session_id else null end)
    /count(case when cart_made_it = 1 then website_session_id else null end) as cart_clickthrough_rate,
    count(case when billing_made_it = 1 then website_session_id else null end)
    /count(case when shipping_made_it = 1 then website_session_id else null end) as shipping_clickthrough_rate,
    count(case when thankyou_made_it = 1 then website_session_id else null end)
    /count(case when billing_made_it = 1 then website_session_id else null end) as billing_click_through_rate
from session_level_funnel_view
group by 1;


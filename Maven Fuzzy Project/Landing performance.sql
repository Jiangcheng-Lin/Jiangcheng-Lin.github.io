-- Section 4: Analyzing Website Performance
-- Website content analysis: understanding which page are seen the most by your users, to identify where to 
-- focus on your business.

-- practice
use mavenfuzzyfactory;
select * from website_pageviews;

select 
	pageview_url,
    count(distinct website_pageview_id) as pvs
from website_pageviews
where website_pageview_id <1000 -- arbitrary
group by pageview_url
order by pvs desc;

drop table if exists first_pageview;

create temporary table first_pageview
select 
	website_session_id,
    min(website_pageview_id) as min_pv_id
from website_pageviews
where
	website_pageview_id < 1000
group by website_session_id;

select * from first_pageview;

select 
	first_pageview.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_pageview
	left join website_pageviews
    on first_pageview.min_pv_id = website_pageviews.website_pageview_id;
    
select 
    website_pageviews.pageview_url as landing_page, -- aka"entry page"
    count(distinct first_pageview.website_session_id) as session_hitting_this_land
from first_pageview
	left join website_pageviews
    on first_pageview.min_pv_id = website_pageviews.website_pageview_id
group by 
	website_pageviews.pageview_url;
    
-- Assignment 1: find the top website pages

select 
	pageview_url,
	count(distinct website_session_id) as sessions -- count(distinct website_pageview_id) as sessions
from website_pageviews
where 
	date(created_at) < "2012-06-09"
group by 
	pageview_url
order by 
	sessions desc;
    
-- Assignment 2: Finding the top entry pages

-- step 1: find the first pageview for each session
create temporary table f_pageview
select 
	website_session_id,
    min(website_pageview_id) as min_pv_id
from website_pageviews 
where
	date(created_at) < "2012-06-12"
group by
	website_session_id;

select * from f_pageview;

select 
	f_pageview.website_session_id,
    pageview_url
from f_pageview
	left join website_pageviews
	on f_pageview.min_pv_id = website_pageviews.website_pageview_id;

-- step 2: find the url for the customer saw on that first pageview
select 
	pageview_url as landing_page,
    count(distinct f_pageview.website_session_id) as sessions_hitting_this_landing_page
from f_pageview
	left join website_pageviews
	on f_pageview.min_pv_id = website_pageviews.website_pageview_id
group by 1
order by 2 desc;

-- Landing page performance & test analysis: see landing page performance for a certain time period

-- step 1: find the first website_pageview_id for each sessions
-- step 2: identify the landing page url of each session
-- step 3: counting pageviews for each session, to identify "bounces"
-- step 4: summarizing total sessions and bounce session by LP

select * from website_sessions;

-- step 1
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where 
	website_sessions.created_at between "2014-01-01" and "2014-02-01"
group by 1;

-- same query as above, create temporary table

create temporary table first_pageviews_memo
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where 
	website_sessions.created_at between "2014-01-01" and "2014-02-01"
group by 1;

-- step 2

create temporary table sessions_w_landing_page_demo
select 
	first_pageviews_memo.website_session_id,
	website_pageviews.pageview_url as landing_page
from first_pageviews_memo
	left join website_pageviews
    on first_pageviews_memo.min_pageview_id = website_pageviews.website_pageview_id;

select * from sessions_w_landing_page_demo;

-- step 3

create temporary table bounced_session_only  
select 
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from sessions_w_landing_page_demo
	left join website_pageviews
    on sessions_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
group by
	1, 2
having 
	count_of_pages_viewed = 1;
-- note: one session can have multiple pages
select * from bounced_session_only;


select 
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_session_only.website_session_id as bounced_website_session_id
from sessions_w_landing_page_demo
	left join bounced_session_only
    on sessions_w_landing_page_demo.website_session_id = bounced_session_only.website_session_id
order by 
	2;
    
-- final output - count the record
select 
	sessions_w_landing_page_demo.landing_page,
    count(distinct sessions_w_landing_page_demo.website_session_id) as total_session,
    count(distinct bounced_session_only.website_session_id) as bounced_session,
    count(distinct bounced_session_only.website_session_id)/count(distinct sessions_w_landing_page_demo.website_session_id) as bounce_rate
from sessions_w_landing_page_demo
	left join bounced_session_only
    on sessions_w_landing_page_demo.website_session_id = bounced_session_only.website_session_id
group by 
	1;

-- Assignment 1: Calculating the Bounce Rate

-- Step 1: find the first pageview id for each session
-- Step 2: find the landing page for each session
-- Step 3: counting the page for each session bounce only
-- Step 4: summarizing total session and bounce session, and calculating the bounce rate
-- step 1
drop table if exists first_pv;
create temporary table first_pv
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews
	join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where 
	date(website_sessions.created_at) < "2012-06-14"
group by
	website_session_id;


-- step 2
drop table if exists landing_pv;
select * from first_pv;
create temporary table landing_pv
select 
	pageview_url as landing_page,
    first_pv.website_session_id
from first_pv
	left join website_pageviews
    on first_pv.min_pv_id = website_pageviews.website_pageview_id
    where pageview_url = "/home";

-- step 3
select * from landing_pv;

drop table if exists bounce_only;
create temporary table bounce_only
select 
	landing_pv.website_session_id,
    landing_pv.landing_page,
    count(website_pageviews.website_session_id) as count_pg_viewed
from landing_pv
	left join website_pageviews
    on landing_pv.website_session_id = website_pageviews.website_session_id
group by
	1,2
having count_pg_viewed = 1;

-- step 4

select * from bounce_only;
select * from landing_pv;

select 
	count(distinct landing_pv.website_session_id) as sessions,
    count(distinct bounce_only.website_session_id) as bounce_sessions,
    count(distinct bounce_only.website_session_id)/count(distinct landing_pv.website_session_id) as bounced_rate
from landing_pv
	left join bounce_only
    on landing_pv.website_session_id = bounce_only.website_session_id
group by landing_pv.landing_page;


-- Assignment 2: Landing Page Test

-- step 0: find the first date and pageview id for using new custom home page
-- step 1: finding the first website_pageview_id for relevant session
-- step 2: finding landing page for each session
-- step 3: counting page for each session bounce only
-- step 4: summarizing sessions and bounce session, to calculate bounce rate for each landing page
select 
	min(created_at) as first_created_at,
    min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = "/lander-1";

-- first_created_at: 2012-06-19, pageview_id: 23504

-- step 1
select * from website_pageviews;

drop table if exists first_pg;
create temporary table first_pg
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as first_pageview_id
from website_pageviews
	join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < "2012-07-28"
	and website_pageviews.website_pageview_id >= 23504
    and utm_source = "gsearch"
    and utm_campaign = "nonbrand"
group by 1;

select * from first_pg;
drop table if exists landing_demo;

create temporary table landing_demo
select first_pg.website_session_id,
	pageview_url as landing_page
from first_pg
	left join website_pageviews
    on first_pg.first_pageview_id = website_pageviews.website_pageview_id
where website_pageviews.created_at >="2012-06-19";
    
-- step 3
select * from landing_demo;
drop table if exists bounce_only;
create temporary table bounce_only
select 
	landing_demo.website_session_id,
    landing_demo.landing_page,
    count(website_pageviews.website_session_id) as count_pg_viewed
from landing_demo
	left join website_pageviews
    on landing_demo.website_session_id = website_pageviews.website_session_id
group by 1,2
having count_pg_viewed = 1;

-- step 4
select * from bounce_only;

select 
	landing_demo.landing_page,
	count(distinct landing_demo.website_session_id) as sessions,
    count(distinct bounce_only.website_session_id) as bounce_session,
    count(distinct bounce_only.website_session_id)/count(distinct landing_demo.website_session_Id) as bounce_rate
from landing_demo
	left join bounce_only
    on landing_demo.website_session_id = bounce_only.website_session_id
group by 1;


-- Assignment 3: Landing Page Trend Analysis

-- step 1: find out the volume of paid search nonbrand traffic landing on /home and /lander.
-- step 2: finding the landing page for each session
-- step 3: counting the landing page bounce only
-- step 4: summarizing the weekly session and bounce session, calculate the bounce rate

-- step 1
select * from website_sessions;
drop table if exists first_pg_view;
create temporary table first_pg_view
select 
	website_pageviews.website_session_id,
    website_sessions.created_at,
    min(website_pageviews.website_pageview_id) as first_pageview_id
from website_pageviews
	join website_sessions
    on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between "2012-06-01" and "2012-08-31"
    and utm_source = "gsearch"
    and utm_campaign = "nonbrand"
group by 1;

-- step 2
select * from first_pg_view;

drop table if exists landing_pg_demo;

create temporary table landing_pg_demo
select 
	first_pg_view.website_session_id,
    first_pg_view.created_at,
    pageview_url as landing_page
from first_pg_view
	left join website_pageviews
    on first_pg_view.first_pageview_id = website_pageviews.website_pageview_id;
    
-- step 3
select * from landing_pg_demo;

drop table if exists bounce_only;
create temporary table bounce_only
select landing_pg_demo.website_session_id,
	landing_pg_demo.landing_page,
    count(website_pageviews.website_session_id) as count_pg_viewed
from landing_pg_demo
	left join website_pageviews
    on landing_pg_demo.website_session_id = website_pageviews.website_session_id
group by 1,2
having count_pg_viewed = 1;

-- step 4
select * from bounce_only;
select * from landing_pg_demo;

select 
	yearweek(landing_pg_demo.created_at) as year_week,
    min(date(landing_pg_demo.created_at)) as week_start_date,
    count(distinct bounce_only.website_session_id)/count(distinct landing_pg_demo.website_session_id) as bounce_rate,
    count(case when landing_pg_demo.landing_page = "/home" then landing_pg_demo.website_session_id else null end) as home_sessions,
    count(case when landing_pg_demo.landing_page = "/lander-1" then landing_pg_demo.website_session_id else null end) as lander_sessions
from landing_pg_demo
	left join bounce_only
    on landing_pg_demo.website_session_id = bounce_only.website_session_id
group by 1;

---------------------------------------------

-- Business Concept
-- Conversion Funnel Analysis

-- Business Context
  -- we want to build a mini conversion funnels, from /lander-2 to /cart
  -- we want to know how many people reach each steps, and also drop rates
  -- for simplicity of the demo, we're looking at /lander-2 traffic only
  -- for simplicity of the demo, we're looking at customers who like Mr Fuzz only

-- step 1: select all pageviews for relevant sessions
-- step 2: identify each relevant pageivews as the specific funnel step
-- step 3: create the session-level conversion funnel view
-- step 4: aggregate the data to assess funnel performance

-- step 1 


select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/products' then 1 else 0 end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between "2014-01-01" and "2014-02-01" -- random timeframe for demo
 and website_pageviews.pageview_url in ('/lander-2', '/products','/the-original-mr-fuzzy','/cart')

order by 
	1, 3;
    
-- step 2 

select 
	website_session_id,
    max(products_page) as product_made_it,
    max(mrfuzzy_page) as mrfuzzy_page_made_it,
    max(cart_page) as cart_page_made_it
from (select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/products' then 1 else 0 end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between "2014-01-01" and "2014-02-01" -- random timeframe for demo
 and website_pageviews.pageview_url in ('/lander-2', '/products','/the-original-mr-fuzzy','/cart')

order by 
	1, 3) as pageview_level
group by 1;

-- create temporary table 
create temporary table session_level_made_it_flags_demo
select 
	website_session_id,
    max(products_page) as product_made_it,
    max(mrfuzzy_page) as mrfuzzy_page_made_it,
    max(cart_page) as cart_page_made_it
from (select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/products' then 1 else 0 end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between "2014-01-01" and "2014-02-01" -- random timeframe for demo
 and website_pageviews.pageview_url in ('/lander-2', '/products','/the-original-mr-fuzzy','/cart')

order by 
	1, 3) as pageview_level
group by 1;



select * from session_level_made_it_flags_demo;
-- final output (part 1)


select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_page_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as to_cart
from session_level_made_it_flags_demo;

-- final output(part 2)
select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as lander_clickthrough_rate,
    count(distinct case when mrfuzzy_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when product_made_it = 1 then website_session_id else null end) as product_clickthrough_rate,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when mrfuzzy_page_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate
from session_level_made_it_flags_demo;


-- Assignment 1: Analyzing the conversion funnels


-- Business Context step
-- 1. build conversion funnels, starting from /lander-1
-- 2. to figure out how many people reach each step, also drop off.
-- 3. calculate the conversion rate for each step

-- step 1 
select * from website_sessions;
select distinct pageview_url from website_pageviews;

select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_sessions.created_at between "2012-08-05" and "2012-09-05"
    and website_sessions.utm_source = "gsearch"
    and website_pageviews.pageview_url in ('/lander-1', '/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order');
    
--
drop table if exists session_level_made_it;

create temporary table session_level_made_it
select 
	website_session_id,
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
    case when pageview_url = '/products' then 1 else 0 end as product_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
	left join website_pageviews
    on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_sessions.created_at between "2012-08-05" and "2012-09-05"
    and website_sessions.utm_source = "gsearch"
    and website_sessions.utm_campaign = "nonbrand"
    and website_pageviews.pageview_url in ('/lander-1', '/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
) as pageview_level
group by website_session_id;

select * from session_level_made_it;
-- step 2&3 


select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when thankyou_made_it =1 then website_session_id else null end) as to_thankyou
from session_level_made_it;

-- conver to calculating conversion rate
select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as product_clickthrough_rate,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
		/count(distinct case when product_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate,
    count(distinct case when cart_made_it = 1 then website_session_id else null end)
		/count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as cart_clickthrough_rate,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end) 
		/count(distinct case when cart_made_it = 1 then website_session_id else null end) as shipping_clickthrough_rate,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) 
		/count(distinct case when shipping_made_it = 1 then website_session_id else null end) as billing_clickthrough_rate,
    count(distinct case when thankyou_made_it =1 then website_session_id else null end) 
		/count(distinct case when billing_made_it = 1 then website_session_id else null end) as thankyou_clickthrough_rate
from session_level_made_it;


-- Assignment 2 Conversion funnels test results
-- Business step
-- 1. find out when the billing-2 start, date and session_id
-- 2. identify billing-1 and billing-2 for relevant sessions
-- 3.calculating the conversion result of billing and order
select 
	min(created_at) as first_pv_date,
	min(website_pageview_id) as first_pv_id
from website_pageviews
where pageview_url ='/billing-2';

select * from orders;

-- first_pv_date: 2012-09-10, id:53550

-- find out the website_session_id with test_pages
select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id
from website_pageviews
	left join orders
    on website_pageviews.website_session_id = orders.website_session_id
where
	website_pageviews.website_pageview_id >= 53550
    and website_pageviews.created_at between '2012-09-10' and '2012-11-10'
    and website_pageviews.pageview_url in ('/billing','/billing-2');
    
-- final output

select 
	billing_version_seen,
    count(distinct website_session_id) as billing_sessions,
    count(distinct order_id) as orders,
    count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rt
from (select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id
from website_pageviews
	left join orders
    on website_pageviews.website_session_id = orders.website_session_id
where
	website_pageviews.website_pageview_id >= 53550
    and website_pageviews.created_at between '2012-09-10' and '2012-11-10'
    and website_pageviews.pageview_url in ('/billing','/billing-2')) as billing_orders
group by 1;

    















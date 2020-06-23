-- Final Project (Timeline: 3/20/2012 - 3/20/2015)
-- Task 1: show volume growth, pull overall session and order volume, trended by quarter for the life of the business 
use mavenfuzzyfactory;
select * from website_sessions;
select * from orders;

select 
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) qtr,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2012-01-01" and "2014-12-31"
group by 1,2;
-- overall, sessions and orders are keep increasing since 2012 for each quarter.

-- Task 2: efficiency improvement, show quarterly figures of conv_rt, revenue per order, revenue per session

select 
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) qtr,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_to_order_conv_rt,
    sum(price_usd)/count(distinct orders.order_id) as revenue_per_order,
    sum(price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_session
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2012-01-01" and "2014-12-31"
group by 1,2;
-- conversion, revenue per order, revenue per session are all increasing from quarter to quarter.

-- Task 3: pull a quarterly view of orders from gsearch nonbrand, bsearch nonbrand, brand search overall, organic search, and direct type in
-- gsearch, bsearch, nonbrand - paid_nonbrand
-- gsearch, bserach, brand - paid_brand
-- source null, campaign null, http_referer null - direct_type_in
-- source null, campaign null, http_referer is not null - organic_search
-- socialbook - paid_social

select 
	utm_source,
    utm_campaign,
    http_referer
from website_sessions
where created_at between "2012-01-01" and "2014-12-31"
group by 1,2,3;

select 
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
    count(distinct case when utm_source = "gsearch" and utm_campaign = "nonbrand" then orders.order_id else null end) as "gsearch_nonbrand",
    count(distinct case when utm_source = "bsearch" and utm_campaign = "nonbrand" then orders.order_id else null end) as "bsearch_nonbrand",
    count(distinct case when utm_campaign = "brand" then orders.order_id else null end) as "brand_search",
    count(distinct case when utm_source is null and utm_campaign is null and http_referer is not null then orders.order_id else null end) as "organic_search",
    count(distinct case when utm_source is null and utm_campaign is null and http_referer is null then orders.order_id else null end) as "direct_type_in"
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2012-01-01" and "2014-12-31"
group by 1, 2;

-- overll increase from 2012 qtr 1 to 2014 qtr 4

-- Task 4: session to order conversion rate for those same channels by quarter, make a note of any period where we made major imrpovement 


select 
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
    count(distinct case when utm_source = "gsearch" and utm_campaign = "nonbrand" then orders.order_id else null end)
    /count(distinct case when utm_source = "gsearch" and utm_campaign = "nonbrand" then website_sessions.website_session_id else null end) as "gsearch_nonbrand_conv_rt",
    count(distinct case when utm_source = "bsearch" and utm_campaign = "nonbrand" then orders.order_id else null end)
    /count(distinct case when utm_source = "bsearch" and utm_campaign = "nonbrand" then website_sessions.website_session_id else null end)as "bsearch_nonbrand_conv_rt",
    count(distinct case when utm_campaign = "brand" then orders.order_id else null end)
    /count(distinct case when utm_campaign = "brand" then website_sessions.website_session_id else null end) as "brand_search_conv_rt",
    count(distinct case when utm_source is null and utm_campaign is null and http_referer is not null then orders.order_id else null end)
    /count(distinct case when utm_source is null and utm_campaign is null and http_referer is not null then website_sessions.website_session_id else null end) as "organic_search_conv_rt",
    count(distinct case when utm_source is null and utm_campaign is null and http_referer is null then orders.order_id else null end)
    /count(distinct case when utm_source is null and utm_campaign is null and http_referer is null then website_sessions.website_session_id else null end)as "direct_type_in_conv_rt"
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2012-01-01" and "2014-12-31"
group by 1, 2;

-- Task 5: since the days of selling a single product, please pull monthly trending for revenue and margin by product, along with total sales and revenue, note anything about seasonality.
select * from order_items;
select 
	distinct product_id
    from order_items;

select 
	year(created_at) as yr,
    month(created_at) as month,
    sum(case when product_id = 1 then price_usd else null end) as prod1_rev, -- mrfuzzy
    sum(case when product_id = 1 then price_usd - cogs_usd else null end) as prod1_margin,
    sum(case when product_id = 2 then price_usd else null end) as prod2_rev, -- lovebear
    sum(case when product_id = 2 then price_usd - cogs_usd else null end) as prod2_margin,
    sum(case when product_id = 3 then price_usd else null end) as prod3_rev, -- birthdaybear
    sum(case when product_id = 3 then price_usd - cogs_usd else null end) as prod3_margin,
    sum(case when product_id = 4 then price_usd else null end) as prod4_rev, -- minibear
    sum(case when product_id = 4 then price_usd - cogs_usd else null end) as prod4_margin,
    count(distinct order_id) as total_sales,
    sum(price_usd) as total_rev
from order_items
group by 1, 2
order by 1, 2; 
-- product 2: launch from 2013 Jan, product 3: launch from 2013 Dec, product 4: launch from 2014 Feb 

-- Task 6: pull monthly sessions to the /product page, and show % of the sessions clicking through another page has changed over time, 
-- along with a view of how conversion from /product to placing an order has improved.
select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id as product_pg_id
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_pageviews.pageview_url = "/products";

drop table if exists product_to_next_pg;

create temporary table product_to_next_pg
select 
	yr,mo,
	products_pg.website_session_id,
    products_pg.product_pg_id,
    min(website_pageviews.website_pageview_id) as next_pg_id
from (select 
    year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id as product_pg_id
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_pageviews.pageview_url = "/products")
as products_pg 
	left join website_pageviews
		on products_pg.website_session_id = website_pageviews.website_session_id
        and products_pg.product_pg_id < website_pageviews.website_pageview_id
group by 1, 2, 3, 4;


select
	yr,mo,
	count(distinct product_to_next_pg.next_pg_id)/count(distinct product_to_next_pg.product_pg_id) as products_clickthrough_rt,
    count(distinct orders.order_id)/count(distinct product_to_next_pg.product_pg_id) as product_to_order_conv_rt
from product_to_next_pg
	left join orders
		on product_to_next_pg.website_session_id = orders.website_session_id
group by 1, 2;

-- Task 7: 4th product available as a primary product Dec 05 2014(it was previously only a cross-sell item). pull sales data, show how well each product 
-- cross sells from one another?

select * from order_items;

drop table if exists primary_product;
create temporary table primary_product
select 
	order_id,
    primary_product_id,
	created_at as ordered_at
from orders
where created_at > "2014-12-05";

select * from primary_product;

select 
	primary_product.order_id,
    primary_product.primary_product_id,
    primary_product.ordered_at,
    order_items.product_id as cross_sell_product_id
from primary_product 
	left join order_items
		on primary_product.order_id = order_items.order_id
        and order_items.is_primary_item = 0;
select 
	primary_product_id,
    count(distinct order_id) as orders,
    count(distinct case when cross_sell_product_id = 1 then order_id else null end) as _xsold_1,
    count(distinct case when cross_sell_product_id = 2 then order_id else null end) as _xsold_2,
    count(distinct case when cross_sell_product_id = 3 then order_id else null end) as _xsold_3,
    count(distinct case when cross_sell_product_id = 4 then order_id else null end) as _xsold_4,
    count(distinct case when cross_sell_product_id = 1 then order_id else null end)/count(distinct order_id) as p1_xsell_rt,
    count(distinct case when cross_sell_product_id = 2 then order_id else null end)/count(distinct order_id) as p2_xsell_rt,
    count(distinct case when cross_sell_product_id = 3 then order_id else null end)/count(distinct order_id) as p3_xsell_rt,
    count(distinct case when cross_sell_product_id = 4 then order_id else null end)/count(distinct order_id) as p4_xsell_rt
from
(select 
	primary_product.order_id,
    primary_product.primary_product_id,
    primary_product.ordered_at,
    order_items.product_id as cross_sell_product_id
from primary_product 
	left join order_items
		on primary_product.order_id = order_items.order_id
        and order_items.is_primary_item = 0)
as product_w_cross_sell
group by 1;

-- Task 8: Share some recommendations and opportunity going forward.
-- recommendation: 1. target month - hoilday season need to be targeted.
-- 				   2. product 4 is good  cross-sell product with other products. Therefore, it may should create bundle sales between prod4 and other products to stimulate the sales.
--                 3. product variety - having positive response on sessions, orders, revenues and margin.

        





	


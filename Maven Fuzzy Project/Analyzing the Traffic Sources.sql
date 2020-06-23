 use mavenfuzzyfactory;
show tables;
select * from website_sessions;
select * from orders;

-- Project 1: Traffic Source Analysis
-- Business Concept - Traffic Source
-- understand where your customers come from and which channels are driving the highest quality traffic.

-- practice

select website_sessions.utm_content,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conversion_rate
from website_sessions
left join orders 
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.website_session_id between 1000 and 2000 -- arbitrary
group by 1
order by 2 desc;


-- Assignment 1 
select utm_source, utm_campaign, http_referer,
count(distinct website_session_id) as sessions
from website_sessions
where date(created_at) < "2012-04-12"
group by 1,2,3
order by 4 desc;

-- Assignment 2 
select utm_source, utm_campaign, http_referer,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct order_id) as orders,
	count(distinct order_id)/count(distinct website_sessions.website_session_id) as conversion_rate
from website_sessions
	left join orders
	on website_sessions.website_session_id = orders.website_session_id
where utm_source = "gsearch" 
    and utm_campaign = "nonbrand" 
    and date(website_sessions.created_at) < "2012-04-14"
group by utm_source, utm_campaign,http_referer;

-- Business Concept - Bid optimization
-- understanding the value of various segments of paid traffic, so that you can optimize your marketing budget.


-- Date Function Practice
select 
    year(created_at) as year,
    week(created_at) as week,
    min(date(created_at)) as week_start,
    count(distinct website_session_id) as sessions
from 
	website_sessions
where
	website_session_id between 100000 and 115000
group by 
	1,2
order by 
	3 desc;
    
-- Pivot Case Count Method -Case when using within the count)
select 
	primary_product_id,
    count(distinct case when items_purchased = 1 then order_id else null end) as single_item_orders,
    count(distinct case when items_purchased = 2 then order_id else null end) as two_item_orders
from orders
where 
	order_id between 31000 and 32000
group by
	1;
    
-- Assignment 3: Traffic Source Trending

select 
    min(date(created_at)) as week_start_date,
    count(distinct website_session_id) as sessions
from 
	website_sessions
where
	utm_source = 'gsearch' and utm_campaign = 'nonbrand'
    and date(created_at) < "2012-05-10"
group by 
	year(created_at),
    week(created_at); 


-- Assignment 4: Bid Optimization for Paid Traffic

select 
	device_type,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    (count(distinct orders.order_id)/count(distinct website_sessions.website_session_id)) as order_session_cov_rate
from 
	website_sessions
left join 
	orders
on website_sessions.website_session_id = orders.website_session_id
where
	utm_source = "gsearch" and utm_campaign = "nonbrand"
    and date(website_sessions.created_at) < "2012-05-11"
group by 
	1;

-- Assignment 5: Trending W/Granular Segments

select 
-- year(created_at) as yr,
-- week(created_at) as wk,
	min(date(created_at)) as week_start_date,
    count(distinct case when device_type = "desktop" then user_id else null end) as dtop_sessions,
    count(distinct case when device_type = "mobile" then user_id else null end) as mob_sessions
from 
	website_sessions
where
	utm_source = "gsearch" and utm_campaign = "nonbrand"
    and date(created_at) between "2012-04-15" and "2012-06-09"
group by 
	year(created_at),
    week(created_at);
	

    



 
 
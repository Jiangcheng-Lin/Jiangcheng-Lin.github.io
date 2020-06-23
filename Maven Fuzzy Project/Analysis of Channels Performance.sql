-- Analysis of marketing channels performance 

-- Paid marketing campaign: tracking parameters
-- measurement: how much they spend, how well traffic converts to sales, etc.
-- Paid traffic is commonly tagged with UTM parameters, which are appended to URLs and allow 
-- us to tie website activity back to specific traffic sources and campaigns.



-- Channel Portfoilo Analysis

-- 1. To identify traffic coming from multiple marketing channels,
-- we will use utm parameters stored in our sessions table.

-- 2. Left join with order table to understand which of the session
-- converted to placing an order and generating revenue.

use mavenfuzzyfactory;
select * from website_sessions;
select * from orders;
-- utm_content for company to track specific ads
select utm_content,
	count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_to_order_cv_rt
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2014-01-01" and "2014-02-01"
group by 1
order by 2 desc;

-- Assignment 1: Analyzing Channel Portfolio


select 
	min(date(created_at)) as week_started_date,
    count(distinct website_session_id) as total_sessions,
    count(distinct case when utm_source = "gsearch" then website_session_id else null end) as gsearch_sessions,
    count(distinct case when utm_source = "bsearch" then website_session_id else null end) as bsearch_sessions
from website_sessions
where created_at between "2012-08-22" and "2012-11-29"
	and utm_campaign = "nonbrand"
    and utm_source in ("gsearch","bsearch")
group by
	yearweek(created_at);
    
-- Assignment 2:

select 
	utm_source,
    count(distinct website_session_id) as sessions,
    count(distinct case when device_type = "mobile" then website_session_id else null end) as mobile_sessions,
    count(distinct case when device_type = "mobile" then website_session_id else null end)/count(distinct website_session_id) as pct_mobile
from website_sessions
	where created_at between "2012-08-22" and "2012-11-30"
    and utm_campaign = "nonbrand"
    and utm_source in ("gsearch", "bsearch")
group by 1; 

-- Assignment 3: Cross-Channel Bid Optimization
select 
	device_type,
    utm_source,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.website_session_id) as orders,
    count(distinct orders.website_session_id)/count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where 
	utm_campaign = "nonbrand"
    and website_sessions.created_at between "2012-08-22" and "2012-09-19"
group by 1, 2;   

-- Assignment 4: Analyzing Channel Portfolio Trend


select
	min(date(created_at)) as week_start_date,
    count(distinct case when device_type = "desktop" and utm_source = "gsearch" then website_session_id else null end) as g_dtop_session,
    count(distinct case when device_type = "desktop" and utm_source = "bsearch" then website_session_id else null end) as b_dtop_session,
    count(distinct case when device_type = "desktop" and utm_source = "bsearch" then website_session_id else null end) 
    /count(distinct case when device_type = "desktop" and utm_source = "gsearch" then website_session_id else null end) as b_pct_to_g_dtop,
    count(distinct case when device_type = "mobile" and utm_source = "gsearch" then website_session_id else null end) as gmobile_session,
    count(distinct case when device_type = "mobile" and utm_source = "bsearch" then website_session_id else null end) as bmobile_session,
    count(distinct case when device_type = "mobile" and utm_source = "bsearch" then website_session_id else null end)
    /count(distinct case when device_type = "mobile" and utm_source = "gsearch" then website_session_id else null end) as b_pct_to_g_mobile
from website_sessions
	where created_at between "2012-11-04" and "2012-12-22"
    and utm_campaign = "nonbrand"
group by 
	yearweek(created_at);
    
    
-- Analyzing direct traffic
use mavenfuzzyfactory;
select 
	case 
		when http_referer is null then "direct_type_in"
		when http_referer = "https://www.gsearch.com" then "gsearch_organic"
        when http_referer = "https://www.bsearch.com" then "bsearch_organic"
        else "others"
        end as traffic_type,
	count(distinct website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
	and utm_source is null
group by 1
order by 2 desc;


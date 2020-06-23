-- User Analysis
-- DateDiff(second_date, first_date)

-- Assignment 1: Identify repeat visitors
use mavenfuzzyfactory;
select * from website_sessions;

select 
	user_id,
    count(user_id) as surfing_times
from website_sessions
	where created_at between "2014-01-01" and "2014-11-01"
group by 1
order by 1;


select 
	case when surfing_times = 1 then 0
		 when surfing_times = 2 then 1
         when surfing_times = 3 then 2
         when surfing_times = 4 then 3
	else "uh...oh check the logic"
    end as repeat_sessions,
    count(distinct user_id) as users
from
(select 
	user_id,
    count(user_id) as surfing_times
from website_sessions
	where created_at between "2014-01-01" and "2014-11-01"
group by 1
order by 1)
as surfing_level
group by 1;

-- Assignment 2: Deep Dive on Repeat
drop table if exists new_sessions;
create temporary table new_sessions
select 
	user_id,
    created_at as first_time,
    is_repeat_session as first_session
from website_sessions
where created_at between "2014-01-01" and "2014-11-01"
	and is_repeat_session = 0;
    
    
select * from new_sessions;

select 
	min(datediff(second_time,first_time)) as min_date,
    max(datediff(second_time,first_time)) as max_date,
    avg(datediff(second_time,first_time)) as avg_time
from 
(select 
	new_sessions.user_id,
    date(new_sessions.first_time) as first_time,
    new_sessions.first_session,
    website_sessions.is_repeat_session as second_session,
	min(date(website_sessions.created_at)) as second_time
from new_sessions
	left join website_sessions
		on new_sessions.user_id = website_sessions.user_id
        and new_sessions.first_time < website_sessions.created_at
where website_sessions.is_repeat_session is not null
group by 1,2,3,4
) as timediff_level;

-- Assignment 3: Repeat Channel Mix
select 
	utm_source,
    utm_campaign,
    http_referer
from website_sessions
where website_sessions.created_at between "2014-01-01" and "2014-11-05"
group by 1,2,3;
-- gsearch, bsearch, nonbrand - paid_nonbrand
-- gsearch, bserach, brand - paid_brand
-- source null, campaign null, http_referer null - direct_type_in
-- source null, campaign null, http_referer is not null - organic_search
-- socialbook - paid_social

select 
	channel_group,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_session,
    count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_session
from 
(select
	website_session_id,
    user_id,
    is_repeat_session,
	case when utm_campaign = "nonbrand" then "paid_nonbrand"
		 when utm_campaign = "brand" then "paid_brand"
         when utm_source is null and utm_campaign is null and http_referer is not null then "organic_search"
         when utm_source = "socialbook" then "paid_social"
         else "direct_type_in"
         end as channel_group
from website_sessions
	where website_sessions.created_at between "2014-01-01" and "2014-11-5")
as channel_gp_session
group by 1
order by repeat_session desc;
-- paid brand is cheapter than paid nonbrand sessions.

-- Assignment 4

select 	
	website_sessions.is_repeat_session,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rt,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as rev_per_session
from website_sessions
	left join orders
    on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between "2014-01-01" and "2014-11-08"
group by 1;
 





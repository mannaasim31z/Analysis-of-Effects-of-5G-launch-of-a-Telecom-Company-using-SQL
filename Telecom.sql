-- 1.cities where they run their business
SELECT DISTINCT(city_name) AS city
FROM dim_cities;

-- total plans
SELECT DISTINCT(plan_description) AS plans
FROM dim_plan;

-- 2.total revenue before and after 5G city wise
WITH x AS (
SELECT city_name,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_crores_before_5G
FROM dim_cities c 
LEFT JOIN fact_atliqo_metrics a ON c.city_code=a.city_code
LEFT JOIN dim_date d ON d.date=a.date
WHERE Before_after_5g="Before 5G"
GROUP BY city_name),
y AS (
SELECT city_name,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_crores_after_5G
FROM dim_cities c 
LEFT JOIN fact_atliqo_metrics a ON c.city_code=a.city_code
LEFT JOIN dim_date d ON d.date=a.date
WHERE Before_after_5g="After 5G"
GROUP BY city_name)
SELECT city_name,revenue_crores_before_5G,revenue_crores_after_5G,
ROUND((revenue_crores_after_5G-revenue_crores_before_5G),2) AS difference
FROM x
JOIN y
USING (city_name)
ORDER BY difference DESC;

-- 3.Monthly revenue before  5G
SELECT month_name,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"
GROUP BY month_name;

-- 4.Monthly revenue after 5G
SELECT month_name,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G"
GROUP BY month_name;

-- 5.Total revenue before and after 5G
WITH before_5G AS (
SELECT ROUND(SUM(atliqo_revenue_crores),2) AS revenue_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"),
after_5G AS(
SELECT ROUND(SUM(atliqo_revenue_crores),2) AS revenue_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G")
SELECT revenue_before_5G,revenue_after_5G,
ROUND(((revenue_after_5G/revenue_before_5G)-1)*100,2) AS revenue_change_pct
FROM before_5G,after_5G;

-- 6.subscribed customer before and after 5G
WITH before_5G AS (
SELECT ROUND(SUM(active_users_lakhs),2) AS active_user_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"),
after_5G AS(
SELECT ROUND(SUM(active_users_lakhs),2) AS active_user_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G")
SELECT active_user_before_5G,active_user_after_5G,
ROUND(((active_user_after_5G/active_user_before_5G)-1)*100,2) AS active_user_pct_change
FROM before_5G,after_5G;

-- 7. citywise active user before and after 5G
WITH before_5G AS (
SELECT city_name,ROUND(SUM(active_users_lakhs),2) AS active_user_before_5G
FROM dim_cities dc
LEFT JOIN fact_atliqo_metrics fam
ON dc.city_code=fam.city_code
LEFT JOIN dim_date dd
ON dd.date=fam.date
WHERE before_after_5g="Before 5G"
GROUP BY city_name),
after_5G AS (
SELECT city_name,ROUND(SUM(active_users_lakhs),2) AS active_user_after_5G
FROM dim_cities dc
LEFT JOIN fact_atliqo_metrics fam
ON dc.city_code=fam.city_code
LEFT JOIN dim_date dd
ON dd.date=fam.date
WHERE before_after_5g="After 5G"
GROUP BY city_name)
SELECT city_name,active_user_before_5G,active_user_after_5G,
ROUND(((active_user_after_5G-active_user_before_5G)/active_user_before_5G)*100,2)
AS user_diff_pct
FROM before_5G
LEFT JOIN after_5G
USING (city_name)
ORDER BY user_diff_pct DESC;

-- 8.citywise unsubscribed user before and after 5G
WITH before_5G AS (
SELECT city_name,ROUND(SUM(unsubscribed_users_lakhs),2) AS unsubscribed_user_before_5G
FROM dim_cities dc
LEFT JOIN fact_atliqo_metrics fam
ON dc.city_code=fam.city_code
LEFT JOIN dim_date dd
ON dd.date=fam.date
WHERE before_after_5g="Before 5G"
GROUP BY city_name),
after_5G AS (
SELECT city_name,ROUND(SUM(unsubscribed_users_lakhs),2) AS unsubscribed_user_after_5G
FROM dim_cities dc
LEFT JOIN fact_atliqo_metrics fam
ON dc.city_code=fam.city_code
LEFT JOIN dim_date dd
ON dd.date=fam.date
WHERE before_after_5g="After 5G"
GROUP BY city_name)
SELECT city_name,unsubscribed_user_before_5G,unsubscribed_user_after_5G,
ROUND(((unsubscribed_user_after_5G-unsubscribed_user_before_5G)/unsubscribed_user_before_5G)*100,2)
AS user_diff_pct
FROM before_5G
LEFT JOIN after_5G
USING (city_name)
ORDER BY user_diff_pct DESC;

-- 9. Revenue before and after with time_period
WITH before_5g AS (
SELECT time_period,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"
GROUP BY time_period),
after_5G AS (
SELECT time_period,ROUND(SUM(atliqo_revenue_crores),2) AS revenue_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G"
GROUP BY time_period)
SELECT time_period,revenue_before_5G,revenue_after_5G,
ROUND((revenue_after_5G-revenue_before_5G),2) AS revenue_change
FROM before_5G
LEFT JOIN after_5G
USING (time_period);

-- 10.ARPU change before and after 5G with time_period
WITH before_5G AS (
SELECT time_period,ROUND(AVG(arpu),2) AS ARPU_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"
GROUP BY time_period),
after_5G AS (
SELECT time_period,ROUND(AVG(arpu),2) AS ARPU_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G"
GROUP BY time_period)
SELECT time_period,ARPU_before_5G,ARPU_after_5G,
(ARPU_after_5G-ARPU_before_5G) AS ARPU_change
FROM before_5G
LEFT JOIN after_5G
USING (time_period);

-- 11.ACTIVE USER BEFORE AND AFTER 5G THROUGH TIME PERIOD
WITH before_5G AS (
SELECT time_period,ROUND(SUM(active_users_lakhs),2) AS user_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"
GROUP BY time_period),
after_5G AS (
SELECT time_period,ROUND(SUM(active_users_lakhs),2) AS user_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G"
GROUP BY time_period)
SELECT time_period,user_before_5G,user_after_5G,
ROUND(((user_after_5G/user_before_5G)-1)*100,2) AS percentage_change
FROM before_5G
LEFT JOIN after_5G
USING (time_period);

-- 12.UNSUBSCRIBED USER BEFORE AND AFTER 5G WITH TIME
WITH before_5G AS (
SELECT time_period,ROUND(SUM(unsubscribed_users_lakhs),2) AS user_before_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="Before 5G"
GROUP BY time_period),
after_5G AS (
SELECT time_period,ROUND(SUM(unsubscribed_users_lakhs),2) AS user_after_5G
FROM dim_date
LEFT JOIN fact_atliqo_metrics
USING (date)
WHERE before_after_5g="After 5G"
GROUP BY time_period)
SELECT time_period,user_before_5G,user_after_5G,
ROUND(((user_after_5G/user_before_5G)-1)*100,2) AS percentage_change
FROM before_5G
LEFT JOIN after_5G
USING (time_period);

-- 13. Market share by Each company
WITH x AS (
select company,ROUND(SUM(ms_pct),2) AS market_share
FROM fact_market_share
GROUP BY company)
SELECT company,ROUND(market_share*100/SUM(market_share) over(),2) AS percentage
FROM x
ORDER BY percentage DESC;




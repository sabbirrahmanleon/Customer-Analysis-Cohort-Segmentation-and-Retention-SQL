--create view cohort_analysis

CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.quantity * s.netprice * s.exchangerate) AS total_net_revenue,
		count(s.orderkey) AS num_orders,
		max(c.countryfull) AS countryfull,
		max(c.age) AS age,
		max(c.givenname) AS givenname,
		max(c.surname) AS surname
	FROM
		sales s
	JOIN customer c ON
		c.customerkey = s.customerkey
	GROUP BY
		s.customerkey,
		s.orderdate
)
 SELECT
	customerkey,
	orderdate,
	total_net_revenue,
	num_orders,
	countryfull,
	age,
	concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS cleaned_name,
	min(orderdate) OVER (
		PARTITION BY customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;


--------------------
-- Cohort Analysis

SELECT
    cohort_year,
    SUM(total_net_revenue) AS total_revenue,
    COUNT(DISTINCT customerkey) AS total_customers,
    SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date
GROUP BY 
    cohort_year

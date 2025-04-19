WITH customer_last_purchase AS
(
	SELECT
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER (
			PARTITION BY customerkey
		ORDER BY
			orderdate DESC
		) AS number,
		first_purchase_date,
		cohort_year
	FROM
		cohort_analysis
),
churned_customers AS (
	SELECT
		customerkey,
		cleaned_name,
		first_purchase_date,
		orderdate AS last_purchase_date,
		CASE
			WHEN orderdate < (SELECT max(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active'
		END AS customer_status,
		cohort_year
	FROM
		customer_last_purchase
	WHERE
		number = 1
		AND first_purchase_date < (SELECT max(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT
	cohort_year,
	customer_status,
	count(DISTINCT customerkey) AS total_customers,
	sum(count(DISTINCT customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
	(round(count(DISTINCT customerkey) / sum(count(DISTINCT customerkey)) over(PARTITION BY cohort_year), 2)) * 100  AS percentage
FROM churned_customers
GROUP BY cohort_year, customer_status;

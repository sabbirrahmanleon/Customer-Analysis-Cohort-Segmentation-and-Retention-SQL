WITH customer_ltv AS (
	SELECT
		customerkey,
		cleaned_name,
		sum(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY
		customerkey,
		cleaned_name
), 
customer_segments AS (
	SELECT
		percentile_cont(0.25) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_25th_percentile,
		percentile_cont(0.75) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_75th_percentile
	FROM
		customer_ltv
),
segment_values AS (
	SELECT
		c.*,
		CASE
			WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1- Low Value'
			WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2- Mid Value'
			ELSE '3- High Value'
		END AS customer_segment
	FROM
		customer_ltv c,
		customer_segments cs
)
SELECT
	customer_segment,
	sum(total_ltv) AS total_ltv,
	count(customerkey) AS customer_count,
	sum(total_ltv) / count(customerkey) AS avg_ltv
FROM
	segment_values
GROUP BY
	customer_segment
ORDER BY
	customer_segment DESC;

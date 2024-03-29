WITH sum_of_order as (
    SELECT Order_ID
    , SUM(Sales) as total_order_sales
    , concat(YEAR(Order_Date),'-', MONTH(Order_Date)) as month_year
    FROM performance.Orders
    GROUP BY  month_year, Order_ID
    ORDER BY year(Order_Date) DESC, month(Order_Date) DESC
)

, avg_std as (
    SELECT month_year
    , SUM(total_order_sales) as sum_sales
    , COUNT(*) as no_order
    , AVG(total_order_sales) as avg_sales
    , STD(total_order_sales) as std_sales
    FROM sum_of_order 
    GROUP BY month_year
)

, upper_lower_whisker as (
    SELECT month_year
    , no_order
    , avg_sales
    , std_sales
    , (avg_sales + std_sales*3) as upper_whisker
    , CASE WHEN (avg_sales - std_sales*3) < 0 THEN 0 
        ELSE (avg_sales - std_sales*3) 
        END as lower_whisker
    FROM avg_std
)

, find_outliers as (
    SELECT spo.Order_ID
    , spo.month_year
    , spo.total_order_sales
    , ul.no_order
    , ul.std_sales
    , ul.avg_sales
    , ul.upper_whisker
    , ul.lower_whisker
    , CASE WHEN total_order_sales > upper_whisker 
    or total_order_sales < lower_whisker THEN 'Outlier' 
    ELSE 'Expected' 
    END as Outlier_status
    FROM sum_of_order as spo
    LEFT JOIN upper_lower_whisker as ul
    ON spo.month_year = ul.month_year
)
 
  SELECT month_year
 , no_order
 , std_sales
 , upper_whisker
 , lower_whisker
 , avg_sales
 , AVG(total_order_sales) as avg_sales_no_outliers
 , COUNT(*) as new_no_orders 
 , COUNT(*)/no_order * 100 as remaining_data
 FROM find_outliers
 WHERE Outlier_status = 'Expected'
 GROUP BY month_year, no_order
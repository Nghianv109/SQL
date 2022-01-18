-- Data sample: https://drive.google.com/file/d/1AzhEfmHAMFCVoHBJd0_ccBrivA1ZD3Tf/view 

-- Show sale data table & ORDER BY date

SELECT * 
FROM sale_16
ORDER BY 1, 2

-- UNION with Sale 2017

SELECT * 
FROM (sale_16
UNION 
SELECT *
FROM sale_17) as sale
ORDER BY 1 desc

-- Looking at number of ORDER BY productkey

SELECT 
    sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) as order_number
FROM sale
GROUP BY sale.ProductKey, sale.TerritoryKey

-- Calculate return rate by productkey
With product_summary (ProductKey, TerritoryKey, order_number, return_number, return_qty) as
(
SELECT 
	order_groupby.*,
	r.return_number,
	CASE WHEN r.return_number > 0 then r.return_number else 0 end as return_qty 
    -- Replace null value by 0
FROM (	
	SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) as order_number 
    -- Get number of ORDER BY productkey
	FROM sale
	GROUP BY sale.ProductKey, sale.TerritoryKey
	) as order_groupby

LEFT JOIN (
		SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) as return_number 
        -- Get number of return by productkey
		FROM return_table re
		GROUP BY re.ProductKey, re.TerritoryKey ) as r
		on order_groupby.ProductKey = r.ProductKey
		and order_groupby.TerritoryKey = r.TerritoryKey
)

SELECT ps.ProductKey, ps.order_number, ps.return_qty,  
		(return_qty/order_number)*100 as return_rate, 
        -- calculate return rate
		p.ProductSKU, p.ProductName, p.ModelName, p.ProductCost, p.ProductPrice
FROM product_summary as ps
LEFT JOIN product as p
	    on ps.ProductKey = p.ProductKey
ORDER BY 4 desc


-- CREATE TEMP TABLE

Drop table if exists #Summary_order_return_of_product
Create Table #Summary_order_return_of_product
(
product_key numeric,
terri_key numeric,
order_qty numeric,
return_number numeric,
return_qty numeric
)
insert into #Summary_order_return_of_product
SELECT 
	order_groupby.*,
	r.return_number,
	CASE WHEN r.return_number > 0 then r.return_number 
    else 0 end as return_qty -- Replace null value by 0
FROM (	
	SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) as order_number 
    -- Get number of ORDER BY productkey
	FROM (
		SELECT * FROM sale_16
		UNION
		SELECT * FROM sale_17) as sale
	GROUP BY sale.ProductKey, sale.TerritoryKey
	) as order_groupby
LEFT JOIN (
			SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) as return_number 
            -- Get number of return by productkey
			FROM return_table re
			GROUP BY re.ProductKey, re.TerritoryKey ) as r
		on order_groupby.ProductKey = r.ProductKey
		and order_groupby.TerritoryKey = r.TerritoryKey
SELECT * FROM #Summary_order_return_of_product
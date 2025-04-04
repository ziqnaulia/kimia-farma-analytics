-- Define the 'transaksi' CTE
WITH transaksi AS (
  SELECT 
    transaction_id,
    date,
    branch_id,
    product_id,
    customer_name,
    discount_percentage,
    rating
  FROM `kf_dataset.kf_final_transaction`
),
-- Define the 'cabang' CTE
cabang AS (
  SELECT 
    branch_id,
    branch_name,
    kota,
    provinsi,
    rating
  FROM `kf_dataset.kf_kantor_cabang`
),
-- Define the 'produk' CTE
produk AS (
  SELECT 
    product_id,
    product_name,
    price
  FROM `kf_dataset.kf_product`
),
-- Define the 'tabel_analisa' CTE
tabel_analisa AS (
  SELECT
    t.transaction_id, --t as alias for transaksi
    t.date,
    c.branch_id, -- c as alias for customer
    c.branch_name,
    c.kota,
    c.provinsi,
    c.rating AS rating_cabang,
    t.customer_name,
    p.product_id, -- p as alias for product
    p.product_name,
    p.price AS actual_price,
    t.discount_percentage,
    -- calculates the gross profit percentage based on the product price
    CASE
      WHEN p.price <= 50000 THEN 10
      WHEN p.price > 50000 AND p.price <= 100000 THEN 15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 20
      WHEN p.price > 300000 AND p.price <= 500000 THEN 25
      WHEN p.price > 500000 THEN 30
    END AS persentase_gross_laba,
    -- calculates the nett sales after applying the discount
    (p.price - (p.price * t.discount_percentage / 100)) AS nett_sales,
    -- calculates the nett profit based on the nett sales and the gross profit percentage
    ((p.price - (p.price * t.discount_percentage / 100)) * 
     CASE
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        WHEN p.price > 500000 THEN 0.30
      END) AS nett_profit,
    t.rating AS rating_transaksi
  FROM transaksi t
  JOIN cabang c ON t.branch_id = c.branch_id --inner join transaction data with branch data
  JOIN produk p ON t.product_id = p.product_id --inner join transaction and branch data with product data
)

--final selection
SELECT * FROM tabel_analisa;
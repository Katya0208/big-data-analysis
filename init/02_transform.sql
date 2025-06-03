/* LOCATION (покупатели + продавцы + магазины + поставщики) */
INSERT INTO mart.dim_location (country,state,city,postal_code)
SELECT DISTINCT COALESCE(customer_country,seller_country,store_country,supplier_country),
       store_state,
       store_city,
       COALESCE(customer_postal_code,seller_postal_code)
FROM staging.mock_data
ON CONFLICT DO NOTHING;

/* PET */
INSERT INTO mart.dim_pet (pet_name, pet_type, pet_breed, pet_category)
SELECT DISTINCT customer_pet_name, customer_pet_type, customer_pet_breed, pet_category
FROM staging.mock_data
ON CONFLICT DO NOTHING;

/* BRAND + CATEGORY */
INSERT INTO mart.dim_brand (brand_name)
SELECT DISTINCT product_brand FROM staging.mock_data
WHERE product_brand IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO mart.dim_category (category_name)
SELECT DISTINCT product_category FROM staging.mock_data
WHERE product_category IS NOT NULL
ON CONFLICT DO NOTHING;

/* SUPPLIER */
INSERT INTO mart.dim_supplier (name, contact, email, phone, address, location_id)
SELECT DISTINCT supplier_name, supplier_contact, supplier_email, supplier_phone,
       supplier_address,
       l.location_id
FROM staging.mock_data m
LEFT JOIN mart.dim_location l
       ON l.country = m.supplier_country
      AND l.city    = m.supplier_city
ON CONFLICT DO NOTHING;


/* CUSTOMER */
INSERT INTO mart.dim_customer (customer_id, first_name, last_name, age, email, pet_id, location_id)
SELECT DISTINCT sale_customer_id,
       customer_first_name, customer_last_name, customer_age, customer_email,
       p.pet_id,
       l.location_id
FROM staging.mock_data m
LEFT JOIN mart.dim_pet      p ON (p.pet_name = m.customer_pet_name)
LEFT JOIN mart.dim_location l ON (l.country = m.customer_country AND l.postal_code = m.customer_postal_code)
ON CONFLICT DO NOTHING;

/* SELLER */
INSERT INTO mart.dim_seller (seller_id, first_name, last_name, email, location_id)
SELECT DISTINCT sale_seller_id,
       seller_first_name, seller_last_name, seller_email,
       l.location_id
FROM staging.mock_data m
LEFT JOIN mart.dim_location l ON (l.country = m.seller_country AND l.postal_code = m.seller_postal_code)
ON CONFLICT DO NOTHING;

/* STORE */
INSERT INTO mart.dim_store (name, phone, email, location_id)
SELECT DISTINCT store_name, store_phone, store_email,
       l.location_id
FROM staging.mock_data m
LEFT JOIN mart.dim_location l ON (l.country = m.store_country AND l.city = m.store_city)
ON CONFLICT DO NOTHING;


INSERT INTO mart.dim_product (product_id, product_name, category_id, brand_id,
                              color, size, material, weight, description,
                              rating, reviews, release_date, expiry_date, supplier_id)
SELECT DISTINCT sale_product_id,
       product_name,
       c.category_id,
       b.brand_id,
       product_color,
       product_size,
       product_material,
       product_weight,
       product_description,
       product_rating,
       product_reviews,
       product_release_date,
       product_expiry_date,
       s.supplier_id
FROM staging.mock_data m
LEFT JOIN mart.dim_category c ON c.category_name = m.product_category
LEFT JOIN mart.dim_brand    b ON b.brand_name    = m.product_brand
LEFT JOIN mart.dim_supplier s ON s.name          = m.supplier_name
ON CONFLICT DO NOTHING;


INSERT INTO mart.dim_date (date_id, year, quarter, month, day_of_week)
SELECT DISTINCT sale_date,
       EXTRACT(YEAR    FROM sale_date),
       EXTRACT(QUARTER FROM sale_date),
       EXTRACT(MONTH   FROM sale_date),
       EXTRACT(DOW     FROM sale_date)
FROM staging.mock_data
ON CONFLICT DO NOTHING;


INSERT INTO mart.fact_sales (source_sale_id, date_id, customer_id,
                             seller_id, product_id, store_id,
                             quantity, total_price)
SELECT id,                     
       sale_date,
       sale_customer_id,
       sale_seller_id,
       sale_product_id,
       st.store_id,
       sale_quantity,
       sale_total_price
FROM staging.mock_data m
JOIN mart.dim_store st ON st.name = m.store_name;


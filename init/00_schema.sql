/* ----------  STAGING  ---------- */
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE staging.mock_data (
    row_id  serial PRIMARY KEY,
    id      int,  
    customer_first_name   text,
    customer_last_name    text,
    customer_age          int,
    customer_email        text,
    customer_country      text,
    customer_postal_code  text,
    customer_pet_type     text,
    customer_pet_name     text,
    customer_pet_breed    text,
    seller_first_name     text,
    seller_last_name      text,
    seller_email          text,
    seller_country        text,
    seller_postal_code    text,
    product_name          text,
    product_category      text,
    product_price         numeric(10,2),
    product_quantity      int,
    sale_date             date,
    sale_customer_id      int,
    sale_seller_id        int,
    sale_product_id       int,
    sale_quantity         int,
    sale_total_price      numeric(12,2),
    store_name            text,
    store_location        text,
    store_city            text,
    store_state           text,
    store_country         text,
    store_phone           text,
    store_email           text,
    pet_category          text,
    product_weight        numeric(8,3),
    product_color         text,
    product_size          text,
    product_brand         text,
    product_material      text,
    product_description   text,
    product_rating        numeric(3,2),
    product_reviews       int,
    product_release_date  date,
    product_expiry_date   date,
    supplier_name         text,
    supplier_contact      text,
    supplier_email        text,
    supplier_phone        text,
    supplier_address      text,
    supplier_city         text,
    supplier_country      text
);

/* ----------  MART (snowflake)  ---------- */
CREATE SCHEMA IF NOT EXISTS mart;

/* ——— измерения-словари ——— */
CREATE TABLE mart.dim_location (
    location_id serial PRIMARY KEY,
    country      text,
    state        text,
    city         text,
    postal_code  text,
    UNIQUE(country,state,city,postal_code)
);

CREATE TABLE mart.dim_date (
    date_id       date PRIMARY KEY,
    year          int,
    quarter       int,
    month         int,
    day_of_week   int
);

CREATE TABLE mart.dim_pet (
    pet_id serial PRIMARY KEY,
    pet_name    text,
    pet_type    text,
    pet_breed   text,
    pet_category text
);

CREATE TABLE mart.dim_customer (
    customer_id int PRIMARY KEY,
    first_name  text,
    last_name   text,
    age         int,
    email       text,
    pet_id      int REFERENCES mart.dim_pet,
    location_id int REFERENCES mart.dim_location
);

CREATE TABLE mart.dim_seller (
    seller_id   int PRIMARY KEY,
    first_name  text,
    last_name   text,
    email       text,
    location_id int REFERENCES mart.dim_location
);

CREATE TABLE mart.dim_store (
    store_id    serial PRIMARY KEY,
    name        text,
    phone       text,
    email       text,
    location_id int REFERENCES mart.dim_location
);

CREATE TABLE mart.dim_brand (
    brand_id serial PRIMARY KEY,
    brand_name text UNIQUE
);

CREATE TABLE mart.dim_category (
    category_id serial PRIMARY KEY,
    category_name text UNIQUE
);

CREATE TABLE mart.dim_supplier (
    supplier_id serial PRIMARY KEY,
    name        text,
    contact     text,
    email       text,
    phone       text,
    address     text,
    location_id int REFERENCES mart.dim_location
);

CREATE TABLE mart.dim_product (
    product_id  int PRIMARY KEY,
    product_name text,
    category_id int REFERENCES mart.dim_category,
    brand_id    int REFERENCES mart.dim_brand,
    color       text,
    size        text,
    material    text,
    weight      numeric(8,3),
    description text,
    rating      numeric(3,2),
    reviews     int,
    release_date date,
    expiry_date  date,
    supplier_id int REFERENCES mart.dim_supplier
);

CREATE TABLE mart.fact_sales (
    fact_id      serial PRIMARY KEY,     
    source_sale_id int,                   
    date_id      date REFERENCES mart.dim_date,
    customer_id  int REFERENCES mart.dim_customer,
    seller_id    int REFERENCES mart.dim_seller,
    product_id   int REFERENCES mart.dim_product,
    store_id     int REFERENCES mart.dim_store,
    quantity     int,
    total_price  numeric(12,2)
);
CREATE INDEX fact_sales_date_idx ON mart.fact_sales (date_id);

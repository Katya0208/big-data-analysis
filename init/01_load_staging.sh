#!/bin/bash
set -euo pipefail
echo ">>> loading CSV into staging.mock_data"

DB_NAME="${POSTGRES_DB:-bigdata}"
USER="${POSTGRES_USER:-labuser}"
export PGPASSWORD="${POSTGRES_PASSWORD:-labpass}"

DATA_PATH="/data"
TABLE="staging.mock_data"

COLS="id,customer_first_name,customer_last_name,customer_age,customer_email,customer_country,customer_postal_code,customer_pet_type,customer_pet_name,customer_pet_breed,seller_first_name,seller_last_name,seller_email,seller_country,seller_postal_code,product_name,product_category,product_price,product_quantity,sale_date,sale_customer_id,sale_seller_id,sale_product_id,sale_quantity,sale_total_price,store_name,store_location,store_city,store_state,store_country,store_phone,store_email,pet_category,product_weight,product_color,product_size,product_brand,product_material,product_description,product_rating,product_reviews,product_release_date,product_expiry_date,supplier_name,supplier_contact,supplier_email,supplier_phone,supplier_address,supplier_city,supplier_country"

psql -v ON_ERROR_STOP=1 -U "$USER" -d "$DB_NAME" -c "TRUNCATE TABLE $TABLE;"

for file in "$DATA_PATH"/MOCK_DATA_*.csv; do
  echo "   → $file"
  psql -v ON_ERROR_STOP=1 -U "$USER" -d "$DB_NAME" \
    -c "\copy $TABLE($COLS) FROM '$file' WITH (FORMAT csv, HEADER true);"
done

echo '>>> done: 10 × CSV loaded'

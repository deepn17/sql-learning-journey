---1. Country Master
CREATE TABLE reference.countries(
	country_code CHAR(2) PRIMARY KEY,
	country_name VARCHAR(100) NOT NULL UNIQUE,
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

---2. Currency Master
CREATE TABLE reference.currencies(
	currency_code CHAR(3) PRIMARY KEY,
	currency_name VARCHAR(100) NOT NULL,
	decimal_places SMALLINT NOT NULL,
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	CONSTRAINT chk_currency_decimal_places
		CHECK (decimal_places BETWEEN 0 AND 4)
);


--- 3. Customer Segments
CREATE TABLE reference.customer_segments(
	segment_code VARCHAR(20) PRIMARY KEY,
	segment_name VARCHAR(100) NOT NULL,
	description TEXT,
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


--- 4. Customer Types
CREATE TABLE reference.customer_types(
	customer_type_code VARCHAR(20) PRIMARY KEY,
	customer_type_name VARCHAR(100) NOT NULL UNIQUE,
	is_active BOOLEAN NOT NULL DEFAULT TRUE
);

--- 5. customer statuses
CREATE TABLE reference.customer_statuses(
	status_code VARCHAR(20) PRIMARY KEY,
	status_name VARCHAR(100) NOT NULL UNIQUE,
	description TEXT,
	is_active BOOLEAN NOT NULL DEFAULT TRUE
);


--- 6. Risk Ratings
CREATE TABLE reference.risk_ratings(
	risk_code VARCHAR(20) PRIMARY KEY,
	risk_name VARCHAR(100) NOT NULL UNIQUE,
	risk_score_min SMALLINT NOT NULL,
	risk_score_max SMALLINT NOT NULL,
	constraint chk_risk_score_range
		CHECK (
			risk_score_min >= 0
			AND risk_score_max <= 100
			AND risk_score_min <= risk_score_max
		)
);



--- Validate your tables
SELECT
	table_schema,
	table_name
from information_schema.tables
where table_schema = 'reference'
	and table_type = 'BASE TABLE'
order by table_name;


--- inspect their columns:

SELECT
	table_name,
	column_name,
	data_type,
	is_nullable,
	column_default
from information_schema.columns
where table_schema = 'reference'
order by table_name, ordinal_position;
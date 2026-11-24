SELECT current_database(), current_user;

SELECT
    schema_name,
    schema_owner
FROM information_schema.schemata
ORDER BY schema_name;

create schema customer
authorization postgres;

create schema kyc
authorization postgres;

create schema accounts
authorization postgres;

create schema payments
authorization postgres;

create schema lending
authorization postgres;

create schema operations
authorization postgres;

create schema audit
authorization postgres;

create schema staging
authorization postgres;

create schema analytics
authorization postgres;

create schema reference
authorization postgres;

select
	  schema_name,
	  schema_owner
from information_schema.schemata
where schema_name IN (
	'customer',   
	'kyc',
	'accounts',
	'payments',
	'audit',
	'analytics',
	'operations',
	'lending',
	'staging',
	'reference'
)







SQL DAY ZERO

Detailed Study Notes & Practical Workbook

PostgreSQL 19 • Windows 11 • Enterprise Banking & Financial Services
Data Model

Scope: This document consolidates the SQL Day Zero material covered so
far: environment setup, database creation, schemas, reference/master
data, relational modelling foundations, and the proposed customer master
design. It includes the SQL statements, explanations, validation
queries, practical considerations and additional study notes.

Progress accuracy --- The PostgreSQL connection, banking_db creation,
ten business schemas, six reference tables and 75 reference records were
reported as successful. The customer.customers CREATE TABLE statement
was provided as the next exercise, but its execution has not yet been
confirmed.

# Contents

-   1.  Learning objectives and project principles
-   2.  PostgreSQL environment: server, database, schema, table and
        client
-   3.  Windows installation and initial verification
-   4.  Creating banking_db
-   5.  PostgreSQL schemas and enterprise organization
-   6.  Relational modelling: grain, relationships, keys and
        normalization
-   7.  Reference/master data design
-   8.  Creating and validating six reference tables
-   9.  Loading 75 reference records
-   10. Data validation, metadata and safe loading patterns
-   11. Customer domain requirements and logical model
-   12. Proposed customer master table
-   13. Senior developer and senior analyst checklists
-   14. Practice exercises and knowledge checks
-   15. Progress tracker and next steps

# 1. Learning objectives and project principles

The aim is not merely to memorize SQL syntax. The aim is to learn how to
design, create, populate, validate, query and eventually optimize a
relational database that resembles a real financial-services
environment.

-   Think like a database developer: data types, keys, constraints,
    ownership, integrity, indexing, transactions and maintainability.

-   Think like a senior data analyst: business definitions, table grain,
    population/denominator rules, NULL handling, duplicates, aggregation
    and reconciliation.

-   Think like a business analyst: clarify requirements, identify
    entities, define lifecycle states, challenge ambiguity and document
    acceptance criteria.

-   Use large, realistic synthetic data with meaningful relationships,
    historical events, exceptions and data-quality issues. Large row
    counts alone are not sufficient; the data must have useful
    complexity.

-   Use fictional data only. Do not use real customer identifiers,
    account numbers, personal information or production data.

## 1.1 Project direction

The training project is an enterprise-style banking and
financial-services database. Planned domains include customer
management, KYC, accounts, payments, lending, operations, reference
data, audit, staging and analytics.

  -----------------------------------------------------------------------
  Domain                              Examples of entities / subject
                                      areas
  ----------------------------------- -----------------------------------
  Customer                            Customers, addresses, identifiers,
                                      profiles, relationships, source
                                      mappings, history

  KYC                                 Applications, documents,
                                      verification events, risk
                                      assessments, exceptions

  Accounts                            Bank accounts, account holders,
                                      balance history

  Payments                            Financial transactions, transaction
                                      events, reversals, disputes,
                                      failures

  Lending                             Loan applications, loan accounts,
                                      repayment schedules and payments

  Operations                          Cases, assignments, workflow
                                      history, SLA events

  Reference                           Countries, currencies, segments,
                                      statuses, products and other
                                      controlled values

  Audit                               Audit events and change history

  Staging                             Raw inbound data from source
                                      systems

  Analytics                           Reporting views and analytical
                                      structures
  -----------------------------------------------------------------------

Initial scale discussed: approximately 6.19 million records across the
broader project datasets. These are planning targets, not records
already loaded. Customer-domain targets include 100,000+ customers and
several hundred thousand related records. Data generation will be done
programmatically (SQL and/or Python), not by manually typing millions of
INSERT statements.

# 2. PostgreSQL environment fundamentals

## 2.1 Core terminology

  -----------------------------------------------------------------------
  Term                    Meaning                 Practical distinction
  ----------------------- ----------------------- -----------------------
  PostgreSQL              Relational database     The database engine
                          management system       that stores data,
                          (RDBMS).                executes SQL and
                                                  enforces constraints.

  PostgreSQL server       The running database    Can host multiple
                          service/instance        databases.
                          managing a database     
                          cluster.                

  Database                A logically separate    Objects in different
                          database within the     databases are not
                          server/cluster.         normally queried
                                                  together through an
                                                  ordinary cross-schema
                                                  reference.

  Schema                  A namespace inside a    Organizes tables,
                          database.               views, functions,
                                                  sequences and other
                                                  objects.

  Table                   A structured relation   Stores records at a
                          made up of columns and  defined grain.
                          rows.                   

  Row / record            One occurrence of the   The meaning of one row
                          entity or event         must be explicitly
                          represented by the      defined.
                          table.                  

  Column                  An attribute of the     Has a data type and
                          entity or event.        possibly constraints.

  SQL                     Structured Query        Used to define,
                          Language.               manipulate and query
                                                  relational data.

  pgAdmin 4               Graphical               A client interface; it
                          administration/client   is not the database
                          application.            engine.

  psql                    PostgreSQL command-line Useful for scripts,
                          client.                 troubleshooting and
                                                  automation.
  -----------------------------------------------------------------------

Important --- Closing pgAdmin does not necessarily stop PostgreSQL.
pgAdmin is a client; the PostgreSQL server runs as a Windows service
independently.

## 2.2 Installation choices used

  ---------------------------------------------------------------------------------------
  Installer setting                   Choice / guidance
  ----------------------------------- ---------------------------------------------------
  Components                          PostgreSQL Server, pgAdmin 4 and Command Line Tools
                                      selected; Stack Builder optional.

  Installation directory              Default location accepted (commonly
                                      C:`\Program `{=tex}Files`\PostgreSQL`{=tex}\\19).

  Data directory                      Default location accepted. Contains database
                                      cluster data and configuration.

  Superuser                           postgres, the administrative database role created
                                      during initialization.

  Port                                5432, PostgreSQL's conventional default port.

  Locale                              Default installer locale accepted.
  ---------------------------------------------------------------------------------------

Stack Builder is an optional utility for installing additional tools,
drivers and extensions. It was not required for this learning setup.
Examples include ODBC drivers and pgBouncer. pgBouncer is a connection
pooler used in some production architectures; it is not needed for the
current exercises.

Security --- The postgres superuser has extensive privileges. Keep its
password private, do not paste it into chat or screenshots, and do not
use it as an application/analyst account in a production design. Later
exercises will introduce least-privilege roles.

## 2.3 Server port and data directory

-   Port 5432 is the TCP endpoint clients commonly use to connect to
    PostgreSQL. If the installer reports it is already occupied,
    investigate the existing service before choosing another port.

-   The installation directory contains program files; the data
    directory contains the database cluster's persistent data and
    configuration. They are different locations.

-   Do not manually edit or delete files inside the PostgreSQL data
    directory. Use PostgreSQL tools and supported backup/restore
    procedures.

# 3. Initial connection verification

The first Query Tool session was opened against the default postgres
database in pgAdmin. The following query was used:

``` sql
SELECT
    version() AS database_version,
    current_database() AS database_name,
    current_user AS connected_user,
    inet_server_port() AS server_port,
    CURRENT_TIMESTAMP AS connection_time;
```

  -----------------------------------------------------------------------
  Expression                          What it reports
  ----------------------------------- -----------------------------------
  version()                           PostgreSQL version and build
                                      information.

  current_database()                  Database to which the current
                                      session is connected.

  current_user                        Current effective database role.

  inet_server_port()                  Server port for the current
                                      connection; may be NULL in some
                                      connection contexts.

  CURRENT_TIMESTAMP                   Timestamp at the start of the
                                      current transaction.
  -----------------------------------------------------------------------

Subtle timestamp behaviour --- In PostgreSQL, CURRENT_TIMESTAMP is
equivalent to transaction_timestamp(); it remains constant throughout
the current transaction. It is not necessarily the wall-clock instant at
which each statement is executed. clock_timestamp() returns the actual
current wall-clock time.

Observed result reported: successful connection; database postgres; port
5432; current user postgres. The installation was PostgreSQL 19
according to the environment setup.

# 4. Creating the project database

A separate database named banking_db was created while connected to
postgres. This avoids using the default maintenance database as the home
for the training project's business tables.

``` sql
CREATE DATABASE banking_db
WITH
    OWNER = postgres;
```

Expected successful command tag: CREATE DATABASE. The database appeared
in pgAdmin after refreshing the Databases node. Its owner was verified
as postgres.

Verification query (run while connected to postgres):

``` sql
SELECT
    datname AS database_name,
    pg_get_userbyid(datdba) AS database_owner,
    pg_encoding_to_char(encoding) AS encoding
FROM pg_database
WHERE datname = 'banking_db';
```

After creating the database, open a new Query Tool connected to
banking_db and verify:

SELECT current_database(), current_user;

Important PostgreSQL rule --- CREATE DATABASE cannot run inside a
transaction block. Execute it as a standalone command, not inside
BEGIN/COMMIT or a tool-managed explicit transaction.

Naming convention --- Use lowercase snake_case for database objects.
Unquoted PostgreSQL identifiers are folded to lowercase; quoted
mixed-case identifiers become case-sensitive and are usually best
avoided in this project.

# 5. Schemas and enterprise organization

## 5.1 What a schema does

A schema is a namespace within a database. It groups related objects and
can support ownership and permission boundaries. A schema is not a
separate database and does not, by itself, guarantee security.

The project's ten business schemas were created inside banking_db:

  -----------------------------------------------------------------------
  Schema                              Intended responsibility
  ----------------------------------- -----------------------------------
  customer                            Customer master, profiles,
                                      addresses, identifiers and
                                      relationships.

  kyc                                 KYC applications, documents,
                                      verification history, risk
                                      assessments and exceptions.

  accounts                            Bank accounts, account holders and
                                      account balance history.

  payments                            Transactions, lifecycle events,
                                      reversals, disputes and payment
                                      failures.

  lending                             Loan applications, loan accounts,
                                      credit assessments and repayments.

  operations                          Cases, assignments, workflow
                                      history, SLA events and
                                      escalations.

  reference                           Controlled master/reference values
                                      used by business tables.

  audit                               Audit events and change history.

  staging                             Raw inbound/source data before
                                      validation and transformation.

  analytics                           Reporting views and analytical
                                      structures.
  -----------------------------------------------------------------------

Creation statements used (executed while connected to banking_db):

``` sql
CREATE SCHEMA customer AUTHORIZATION postgres;
CREATE SCHEMA kyc AUTHORIZATION postgres;
CREATE SCHEMA accounts AUTHORIZATION postgres;
CREATE SCHEMA payments AUTHORIZATION postgres;
CREATE SCHEMA lending AUTHORIZATION postgres;
CREATE SCHEMA operations AUTHORIZATION postgres;
CREATE SCHEMA reference AUTHORIZATION postgres;
CREATE SCHEMA audit AUTHORIZATION postgres;
CREATE SCHEMA staging AUTHORIZATION postgres;
CREATE SCHEMA analytics AUTHORIZATION postgres;
```

The verification query returned ten rows:

``` sql
SELECT
    schema_name,
    schema_owner
FROM information_schema.schemata
WHERE schema_name IN (
    'customer', 'kyc', 'accounts', 'payments', 'lending',
    'operations', 'reference', 'audit', 'staging', 'analytics'
)
ORDER BY schema_name;
```

Progress confirmed --- The user reported that schema inspection
succeeded, all ten schemas were created, and verification returned ten
rows.

## 5.2 The public schema and search_path

A newly initialized PostgreSQL database normally includes a public
schema. The system also exposes information_schema and
PostgreSQL-specific catalogs. The earlier ten-row query intentionally
filtered for the ten project schemas, so it did not imply that only ten
schemas exist.

When a table is referenced without a schema, PostgreSQL uses the current
search_path to resolve the object name. For clarity and predictable
behaviour, this project will generally use schema-qualified names such
as customer.customers and reference.countries.

``` sql
SHOW search_path;

-- Explicit schema-qualified reference:
SELECT *
FROM reference.countries;
```

Security consideration --- The search_path affects name resolution. In
security-sensitive environments, control who can CREATE objects in
schemas appearing early in the search_path; otherwise object-name
shadowing can create risks.

## 5.3 information_schema and PostgreSQL catalogs

information_schema provides standardized metadata views, for example
information_schema.schemata, information_schema.tables and
information_schema.columns. PostgreSQL-specific catalogs such as
pg_namespace, pg_class and pg_constraint expose richer
PostgreSQL-specific metadata.

``` sql
-- Inspect schemas:
SELECT schema_name, schema_owner
FROM information_schema.schemata
ORDER BY schema_name;

-- Inspect tables in the reference schema:
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'reference'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

# 6. Relational data modelling foundations

## 6.1 Grain: the meaning of one row

Grain is the precise statement of what one row represents. Define the
grain before designing columns, keys or analytical queries.

  -----------------------------------------------------------------------
  Table example                       Grain
  ----------------------------------- -----------------------------------
  customers                           One enterprise customer.

  customer_addresses                  One address record associated with
                                      a customer.

  kyc_applications                    One KYC application.

  kyc_verification_history            One verification event.

  bank_accounts                       One bank account.

  financial_transactions              One financial transaction.

  transaction_events                  One event in a transaction's
                                      lifecycle.

  loan_repayments                     One scheduled or actual repayment
                                      record, depending on the final
                                      design.
  -----------------------------------------------------------------------

Example: customer C001 has two KYC applications. A join from customers
to kyc_applications returns two rows for C001. This is valid one-to-many
behaviour, not necessarily duplicate data. Counting joined rows as
customers would overstate the customer count.

Analyst rule --- Before aggregating, ask: what is the grain before the
join, what is the grain after the join, and what entity am I actually
counting? COUNT(DISTINCT customer_id) may be appropriate for a customer
count, but it should not be used as a reflexive patch for an incorrectly
designed join.

## 6.2 Relationship types

  ------------------------------------------------------------------------------------
  Relationship            Example                 Typical implementation
  ----------------------- ----------------------- ------------------------------------
  One-to-one (1:1)        One customer has one    Child table has a foreign key to
                          individual profile.     customer and a UNIQUE constraint on
                                                  that FK; often the FK is also the
                                                  PK.

  One-to-many (1:M)       One customer has        Foreign key is stored on the
                          multiple KYC            many-side table,
                          applications.           e.g. kyc_applications.customer_id.

  Many-to-many (M:M)      Customers can jointly   Use a junction table such as
                          hold accounts; accounts accounts.account_holders with FKs to
                          can have multiple       customers and bank_accounts.
                          holders.                
  ------------------------------------------------------------------------------------

A junction table can carry attributes of the relationship itself, such
as holder role, ownership percentage, valid-from date and valid-to date.
Those attributes belong to the relationship, not necessarily to either
parent entity.

## 6.3 Primary keys, foreign keys and unique constraints

  -----------------------------------------------------------------------
  Constraint / key        Purpose                 Important behaviour
  ----------------------- ----------------------- -----------------------
  PRIMARY KEY             Uniquely identifies     Unique and NOT NULL;
                          each row.               one primary-key
                                                  constraint per table,
                                                  possibly composite.

  FOREIGN KEY             Requires a referenced   Can be NULL unless NOT
                          key to exist in the     NULL is also declared;
                          referenced table.       duplicate FK values are
                                                  allowed unless
                                                  separately constrained.

  UNIQUE                  Prevents duplicate      NULL handling in
                          values/combinations.    PostgreSQL permits
                                                  multiple NULLs by
                                                  default; UNIQUE NULLS
                                                  NOT DISTINCT is
                                                  available in supported
                                                  versions when that
                                                  behaviour is required.

  NOT NULL                Requires a value in the Does not by itself
                          column.                 validate whether a
                                                  value is meaningful or
                                                  correctly formatted.

  CHECK                   Enforces a Boolean      A CHECK passes when the
                          row-level condition.    expression is TRUE or
                                                  NULL; pair with NOT
                                                  NULL when NULL must be
                                                  rejected.
  -----------------------------------------------------------------------

Example parent and child:

``` sql
CREATE TABLE customer.customers_example (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL
);

CREATE TABLE kyc.kyc_applications_example (
    application_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    CONSTRAINT fk_example_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer.customers_example(customer_id)
);
```

The example is illustrative only; the actual project customer table is
named customer.customers and the actual KYC table has not yet been
created.

## 6.4 Natural keys and surrogate keys

  -----------------------------------------------------------------------
  Type                    Description             Example
  ----------------------- ----------------------- -----------------------
  Natural key             A meaningful business   A standardized country
                          identifier that exists  code or a business
                          outside the database.   application reference.

  Surrogate key           An internally generated BIGINT identity
                          identifier with no      customer_id.
                          business meaning.       
  -----------------------------------------------------------------------

The project uses surrogate keys for core customer identity. Business
identifiers such as customer_number are stored separately and can have a
UNIQUE constraint. This helps avoid coupling internal relationships to
identifiers that may change, be corrected, or differ across source
systems.

## 6.5 Normalization: 1NF, 2NF and 3NF

  -----------------------------------------------------------------------
  Normal form             Core idea               Example of a design
                                                  issue
  ----------------------- ----------------------- -----------------------
  1NF                     Columns hold atomic     Storing several phone
                          values; avoid repeating numbers in one
                          groups and arrays of    comma-separated column.
                          same-kind values in     
                          ordinary relational     
                          attributes.             

  2NF                     Every non-key attribute In a customer-account
                          depends on the whole    junction keyed by
                          candidate key; relevant (customer_id,
                          especially when a       account_id), storing
                          candidate key is        customer_name creates a
                          composite.              partial dependency on
                                                  customer_id.

  3NF                     Avoid transitive        Storing country_name
                          dependencies of non-key repeatedly alongside
                          attributes on other     country_code in every
                          non-key attributes.     customer row when
                                                  country_code determines
                                                  country_name.
  -----------------------------------------------------------------------

Normalization reduces update, insertion and deletion anomalies and helps
maintain consistency. Analytical systems may later use denormalized
structures or dimensional models for query simplicity and performance.
The correct design depends on workload and purpose.

## 6.6 History and lifecycle modelling

Current-state tables and history/event tables serve different purposes.
A customer master may store the current status for convenient
operational access, while customer_status_history records each status
transition. The model must define effective timestamps, event
timestamps, correction rules and how the current row is determined.

Do not overwrite history if the business needs an auditable timeline.
Later lessons will distinguish event history, audit logging, slowly
changing dimensions and valid-time versus transaction-time concepts.

# 7. Reference/master data design

Reference data contains controlled values used by business entities.
Instead of allowing arbitrary text values in many tables, a reference
table provides a governed list and a foreign key can enforce that only
known values are used.

  -----------------------------------------------------------------------------
  Reference table               Purpose                 Expected records loaded
  ----------------------------- ----------------------- -----------------------
  reference.countries           Country codes and names 25

  reference.currencies          Currency codes, names   20
                                and decimal-place       
                                metadata                

  reference.customer_segments   Retail, premium, HNI,   8
                                corporate, SME and      
                                other segments          

  reference.customer_types      Individual, joint, sole 10
                                proprietorship,         
                                partnership, company,   
                                trust, etc.             

  reference.customer_statuses   Active, inactive,       8
                                blocked, suspended,     
                                dormant, closed, etc.   

  reference.risk_ratings        Illustrative risk bands 4
                                and score ranges        

  TOTAL                         Six reference tables    75
  -----------------------------------------------------------------------------

## 7.1 Reference table DDL

``` sql
-- 1. Country master
CREATE TABLE reference.countries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Currency master
CREATE TABLE reference.currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    decimal_places SMALLINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_currency_decimal_places
        CHECK (decimal_places BETWEEN 0 AND 4)
);

-- 3. Customer segments
CREATE TABLE reference.customer_segments (
    segment_code VARCHAR(20) PRIMARY KEY,
    segment_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Customer types
CREATE TABLE reference.customer_types (
    customer_type_code VARCHAR(20) PRIMARY KEY,
    customer_type_name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 5. Customer statuses
CREATE TABLE reference.customer_statuses (
    status_code VARCHAR(20) PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 6. Risk ratings
CREATE TABLE reference.risk_ratings (
    risk_code VARCHAR(20) PRIMARY KEY,
    risk_name VARCHAR(100) NOT NULL UNIQUE,
    risk_score_min SMALLINT NOT NULL,
    risk_score_max SMALLINT NOT NULL,
    CONSTRAINT chk_risk_score_range
        CHECK (
            risk_score_min >= 0
            AND risk_score_max <= 100
            AND risk_score_min <= risk_score_max
        )
);
```

## 7.2 Why these data types and constraints?

  -----------------------------------------------------------------------
  Definition                          Reasoning / caveat
  ----------------------------------- -----------------------------------
  CHAR(2) country_code                Fixed-length country code.
                                      PostgreSQL CHAR(n) pads values with
                                      spaces; VARCHAR or TEXT may be
                                      preferable in some designs. Be
                                      consistent and understand
                                      comparison/padding behaviour.

  CHAR(3) currency_code               Three-character currency code.
                                      Similar CHAR considerations apply.

  VARCHAR(n)                          Variable-length text with an
                                      explicit maximum length. Choose
                                      limits from business rules, not
                                      guesswork.

  TEXT                                Variable-length text without a
                                      declared length limit; useful for
                                      descriptions.

  BOOLEAN                             True/false state. Use NOT NULL if
                                      unknown is not an allowed state.

  SMALLINT                            Compact integer type suitable for
                                      small numeric ranges such as
                                      decimal-place counts.

  DATE                                Calendar date without time-of-day
                                      or time zone.

  TIMESTAMPTZ                         Timestamp with time zone semantics;
                                      PostgreSQL stores an absolute
                                      instant and displays it in the
                                      session time zone.

  NUMERIC(p,s)                        Exact decimal arithmetic, generally
                                      appropriate for monetary amounts
                                      when precision and scale are
                                      defined.

  CHECK                               Database-level validation for a
                                      row-level rule, e.g. decimal_places
                                      BETWEEN 0 AND 4.
  -----------------------------------------------------------------------

Money --- Use NUMERIC rather than FLOAT or REAL for exact financial
amounts. Define precision and scale deliberately, and document rounding
rules. Currency minor-unit metadata is useful but does not alone define
every product's calculation or rounding policy.

Risk band caveat --- The CHECK constraint validates each row's own
min/max values. It does not prevent ranges in different rows from
overlapping or leaving gaps. Cross-row integrity needs additional
design, validation or controlled loading logic. The 0--100 bands used
here are training examples, not regulatory thresholds.

# 8. Loading reference data

## 8.1 INSERT syntax and good practice

``` sql
INSERT INTO schema_name.table_name (
    column_1,
    column_2,
    column_3
)
VALUES (
    value_1,
    value_2,
    value_3
);
```

-   Name the target columns explicitly. This makes the statement
    resilient to column-order changes and easier to review.

-   Text literals use single quotes, e.g. 'India'.

-   Numeric literals are unquoted, e.g. 2.

-   Boolean literals are TRUE and FALSE.

-   Use NULL for a missing value; do not use the text string 'NULL'.

-   If a column with a DEFAULT is omitted from the insert column list,
    PostgreSQL uses the default.

-   Multi-row INSERT uses comma-separated value tuples and is convenient
    for small reference datasets.

## 8.2 Country data -- 25 rows

``` sql
INSERT INTO reference.countries (
    country_code, country_name, is_active
)
VALUES
    ('IN', 'India', TRUE),
    ('US', 'United States', TRUE),
    ('GB', 'United Kingdom', TRUE),
    ('AE', 'United Arab Emirates', TRUE),
    ('SG', 'Singapore', TRUE),
    ('HK', 'Hong Kong', TRUE),
    ('AU', 'Australia', TRUE),
    ('CA', 'Canada', TRUE),
    ('DE', 'Germany', TRUE),
    ('FR', 'France', TRUE),
    ('CH', 'Switzerland', TRUE),
    ('JP', 'Japan', TRUE),
    ('CN', 'China', TRUE),
    ('MY', 'Malaysia', TRUE),
    ('TH', 'Thailand', TRUE),
    ('ID', 'Indonesia', TRUE),
    ('SA', 'Saudi Arabia', TRUE),
    ('QA', 'Qatar', TRUE),
    ('ZA', 'South Africa', TRUE),
    ('BR', 'Brazil', TRUE),
    ('NZ', 'New Zealand', TRUE),
    ('NL', 'Netherlands', TRUE),
    ('IE', 'Ireland', TRUE),
    ('IT', 'Italy', TRUE),
    ('ES', 'Spain', TRUE);
```

## 8.3 Currency data -- 20 rows

``` sql
INSERT INTO reference.currencies (
    currency_code, currency_name, decimal_places, is_active
)
VALUES
    ('INR', 'Indian Rupee', 2, TRUE),
    ('USD', 'US Dollar', 2, TRUE),
    ('EUR', 'Euro', 2, TRUE),
    ('GBP', 'Pound Sterling', 2, TRUE),
    ('AED', 'UAE Dirham', 2, TRUE),
    ('SGD', 'Singapore Dollar', 2, TRUE),
    ('HKD', 'Hong Kong Dollar', 2, TRUE),
    ('AUD', 'Australian Dollar', 2, TRUE),
    ('CAD', 'Canadian Dollar', 2, TRUE),
    ('CHF', 'Swiss Franc', 2, TRUE),
    ('JPY', 'Japanese Yen', 0, TRUE),
    ('CNY', 'Chinese Yuan', 2, TRUE),
    ('MYR', 'Malaysian Ringgit', 2, TRUE),
    ('THB', 'Thai Baht', 2, TRUE),
    ('IDR', 'Indonesian Rupiah', 2, TRUE),
    ('SAR', 'Saudi Riyal', 2, TRUE),
    ('QAR', 'Qatari Riyal', 2, TRUE),
    ('ZAR', 'South African Rand', 2, TRUE),
    ('BRL', 'Brazilian Real', 2, TRUE),
    ('NZD', 'New Zealand Dollar', 2, TRUE);
```

## 8.4 Customer segments -- 8 rows

``` sql
INSERT INTO reference.customer_segments (
    segment_code, segment_name, description
)
VALUES
    ('RETAIL', 'Retail Banking', 'Individual retail banking customers'),
    ('PREMIUM', 'Premium Banking', 'Customers receiving premium banking services'),
    ('HNI', 'High Net Worth', 'High net worth individual customers'),
    ('CORPORATE', 'Corporate Banking', 'Corporate and institutional customers'),
    ('SME', 'Small and Medium Enterprise', 'Small and medium business customers'),
    ('MICRO', 'Micro Banking', 'Micro and small-value banking customers'),
    ('NRI', 'Non Resident Indian', 'Non resident Indian customers'),
    ('PRIVATE', 'Private Banking', 'Private wealth management customers');
```

The INSERT omits created_at, so the DEFAULT CURRENT_TIMESTAMP is applied
automatically.

## 8.5 Customer types -- 10 rows

``` sql
INSERT INTO reference.customer_types (
    customer_type_code, customer_type_name
)
VALUES
    ('INDIVIDUAL', 'Individual Customer'),
    ('JOINT', 'Joint Customer'),
    ('SOLE_PROP', 'Sole Proprietorship'),
    ('PARTNERSHIP', 'Partnership Firm'),
    ('LLP', 'Limited Liability Partnership'),
    ('PRIVATE_LTD', 'Private Limited Company'),
    ('PUBLIC_LTD', 'Public Limited Company'),
    ('TRUST', 'Trust'),
    ('HUF', 'Hindu Undivided Family'),
    ('SOCIETY', 'Registered Society');
```

## 8.6 Customer statuses -- 8 rows

``` sql
INSERT INTO reference.customer_statuses (
    status_code, status_name, description
)
VALUES
    ('ACTIVE', 'Active', 'Customer relationship is active'),
    ('INACTIVE', 'Inactive', 'Customer relationship is inactive'),
    ('BLOCKED', 'Blocked', 'Customer relationship is blocked'),
    ('SUSPENDED', 'Suspended', 'Customer relationship is temporarily suspended'),
    ('DORMANT', 'Dormant', 'Account relationship is classified as dormant'),
    ('CLOSED', 'Closed', 'Customer relationship has been closed'),
    ('DECEASED', 'Deceased', 'Customer reported as deceased'),
    ('UNDER_REVIEW', 'Under Review', 'Customer is under compliance review');
```

## 8.7 Risk ratings -- 4 rows

``` sql
INSERT INTO reference.risk_ratings (
    risk_code, risk_name, risk_score_min, risk_score_max
)
VALUES
    ('LOW', 'Low Risk', 0, 24),
    ('MEDIUM', 'Medium Risk', 25, 49),
    ('HIGH', 'High Risk', 50, 74),
    ('CRITICAL', 'Critical Risk', 75, 100);
```

Training qualification --- The customer status and risk categories are
illustrative reference values for the learning database. They are not a
substitute for a bank's approved policy, jurisdictional rules or
regulatory taxonomy.

# 9. Data validation and safe loading

## 9.1 Record-count reconciliation

``` sql
SELECT 'countries' AS table_name, COUNT(*) AS total_records
FROM reference.countries
UNION ALL
SELECT 'currencies', COUNT(*)
FROM reference.currencies
UNION ALL
SELECT 'customer_segments', COUNT(*)
FROM reference.customer_segments
UNION ALL
SELECT 'customer_types', COUNT(*)
FROM reference.customer_types
UNION ALL
SELECT 'customer_statuses', COUNT(*)
FROM reference.customer_statuses
UNION ALL
SELECT 'risk_ratings', COUNT(*)
FROM reference.risk_ratings
ORDER BY table_name;
```

  Table               Expected rows
  ------------------- ---------------
  countries           25
  currencies          20
  customer_segments   8
  customer_types      10
  customer_statuses   8
  risk_ratings        4
  Total               75

The user reported a total of 75 records and successful risk validation.

## 9.2 COUNT(\*) versus COUNT(column)

``` sql
SELECT
    COUNT(*) AS total_currencies,
    COUNT(currency_code) AS populated_currency_codes,
    COUNT(currency_name) AS populated_currency_names,
    COUNT(decimal_places) AS populated_decimal_places
FROM reference.currencies;
```

-   COUNT(\*) counts rows, including rows where one or more columns are
    NULL.

-   COUNT(column) counts only rows where that expression is not NULL.

-   COUNT(DISTINCT column) counts distinct non-NULL values.

-   COUNT(\*) - COUNT(column) can help identify how many rows have NULL
    in a particular column, provided the query is scoped correctly.

## 9.3 Validate risk ranges

``` sql
SELECT
    risk_code,
    risk_name,
    risk_score_min,
    risk_score_max,
    risk_score_max - risk_score_min + 1 AS scores_covered
FROM reference.risk_ratings
ORDER BY risk_score_min;
```

Expected bands: LOW 0--24, MEDIUM 25--49, HIGH 50--74, CRITICAL 75--100.
Together these cover all 101 integer scores from 0 through 100 without
gaps or overlaps.

## 9.4 NULL and defaults

-   NULL means unknown, missing or not applicable depending on the
    business definition; it is not zero, an empty string or the literal
    word 'NULL'.

-   Use IS NULL / IS NOT NULL to test for NULL. Comparisons such as
    column = NULL do not work as ordinary equality tests.

-   DEFAULT applies when the column is omitted or DEFAULT is explicitly
    requested. Supplying NULL explicitly does not invoke the default.

-   NOT NULL is needed when the business requires a value. A DEFAULT
    alone does not prevent an explicit NULL unless the column is also
    NOT NULL.

## 9.5 Duplicate prevention and ON CONFLICT

Re-running a plain INSERT for an already-loaded primary key or unique
key will fail with a uniqueness violation. PostgreSQL supports ON
CONFLICT for deliberate conflict handling.

``` sql
-- Insert only if the country code does not already exist:
INSERT INTO reference.countries (
    country_code, country_name, is_active
)
VALUES ('IN', 'India', TRUE)
ON CONFLICT (country_code)
DO NOTHING;
```

DO NOTHING is appropriate only when ignoring the conflicting row is the
intended policy. If a trusted source is authoritative and updates are
required, ON CONFLICT DO UPDATE may be appropriate. Do not use an upsert
blindly: define which source wins, which columns may change, how changes
are audited and how concurrent updates are handled.

## 9.6 Transactions and atomic loading

A transaction groups changes so they can be committed together or rolled
back. This is especially useful when a load consists of dependent steps.

``` sql
BEGIN;

-- INSERT statements go here.
-- Run validation queries here if desired.

COMMIT;

-- If something is wrong before COMMIT, use:
-- ROLLBACK;
```

A transaction should be kept purposeful and appropriately sized. Large
bulk loads may require batching and operational planning. CREATE
DATABASE is a special case and cannot run inside a transaction block.

## 9.7 UNION versus UNION ALL

  -----------------------------------------------------------------------
  Operator                Behaviour               Typical consideration
  ----------------------- ----------------------- -----------------------
  UNION                   Combines result sets    Requires duplicate
                          and removes duplicate   elimination; useful
                          rows.                   when deduplication is
                                                  part of the
                                                  requirement.

  UNION ALL               Combines result sets    Usually faster when
                          and preserves all rows. duplicates do not need
                                                  to be removed; used for
                                                  the six independent
                                                  count results.
  -----------------------------------------------------------------------

# 10. Customer domain requirements and logical model

## 10.1 Business scenario

The training bank operates across multiple markets and customer
segments. It receives customer information from core banking, CRM,
digital onboarding, KYC, wealth and corporate banking systems. Different
source systems may assign different identifiers to the same real-world
customer.

  Source system        Typical information
  -------------------- ------------------------------------------------
  CORE_BANKING         Customer and account details.
  CRM                  Customer profile and contact details.
  DIGITAL_ONBOARDING   New customer applications and onboarding data.
  KYC_PLATFORM         Identity and verification information.
  WEALTH_PLATFORM      Premium and HNI customer information.
  CORPORATE_BANKING    Business and institutional details.

Example: the same real-world customer may have CORE_BANKING customer ID
C10001 and CRM ID CRM88231. These identifiers do not prove there are two
people. Identity resolution and source mapping are separate modelling
concerns.

## 10.2 Proposed customer tables and grain

  -----------------------------------------------------------------------
  Proposed table                      Grain / purpose
  ----------------------------------- -----------------------------------
  customer.customers                  One row per enterprise customer;
                                      central master.

  customer.individual_profiles        One row per individual customer,
                                      with individual-specific
                                      attributes.

  customer.business_profiles          One row per business/legal-entity
                                      customer, with business-specific
                                      attributes.

  customer.customer_addresses         One row per address record, with
                                      address type and validity period.

  customer.customer_identifiers       One row per identity document or
                                      identifier.

  customer.customer_relationships     One row per relationship between
                                      two customers, e.g. director,
                                      beneficial owner or related party.

  customer.customer_source_mappings   One row per source-system customer
                                      identifier mapped to the enterprise
                                      customer.

  customer.customer_profile_history   One row per profile-change event or
                                      historical version, depending on
                                      final design.

  customer.customer_status_history    One row per status-change event or
                                      historical status period, depending
                                      on final design.
  -----------------------------------------------------------------------

## 10.3 Why separate these tables?

-   A customer may have several addresses; storing all addresses in one
    customers row would create repeating groups and poor updateability.

-   A customer may have several identifiers, such as a passport and tax
    identifier. Identity attributes have their own lifecycle, issuing
    country, issue/expiry dates and verification status.

-   Individual and business customers have different attributes.
    Separate profile tables avoid a wide table full of irrelevant NULL
    columns and help express subtype-specific rules.

-   Customer relationships are not merely attributes of one customer.
    They connect two customer entities and may have roles and effective
    dates.

-   Source-system IDs are not necessarily globally unique. A mapping
    should identify the source system as well as the source identifier.

-   Current status and status history have different purposes. The
    current state supports operational access; history supports audit
    and point-in-time analysis.

## 10.4 Initial scale targets

  Customer-domain dataset    Initial target
  -------------------------- ----------------
  Customers                  100,000+
  Customer addresses         150,000
  Customer identifiers       120,000
  Customer relationships     40,000
  Customer profile history   250,000
  Customer status history    200,000

These are synthetic-data targets for future loading, not current row
counts. We will generate data with realistic distributions, referential
integrity, missing values, duplicates, multiple source systems,
overlapping effective dates where deliberately introduced as a
data-quality defect, and other testable edge cases.

# 11. Proposed customer master table

## 11.1 Grain and columns

Grain: one row represents one uniquely identified enterprise customer.

  ------------------------------------------------------------------------------
  Column                  Proposed type           Purpose / rule
  ----------------------- ----------------------- ------------------------------
  customer_id             BIGINT identity         Internal surrogate primary
                                                  key.

  customer_number         VARCHAR(30)             Business-facing customer
                                                  reference; required and
                                                  unique.

  customer_type_code      VARCHAR(20)             FK to
                                                  reference.customer_types.

  segment_code            VARCHAR(20)             FK to
                                                  reference.customer_segments.

  status_code             VARCHAR(20)             FK to
                                                  reference.customer_statuses;
                                                  current status.

  risk_code               VARCHAR(20)             FK to reference.risk_ratings;
                                                  current risk classification.

  country_code            CHAR(2)                 FK to reference.countries.

  onboarding_date         DATE                    Required customer onboarding
                                                  date.

  created_at              TIMESTAMPTZ             Creation timestamp, default
                                                  CURRENT_TIMESTAMP.

  updated_at              TIMESTAMPTZ             Last-update timestamp; default
                                                  on insert, but requires update
                                                  logic.
  ------------------------------------------------------------------------------

## 11.2 Proposed CREATE TABLE statement

``` sql
CREATE TABLE customer.customers (

    customer_id BIGINT GENERATED ALWAYS AS IDENTITY,
    customer_number VARCHAR(30) NOT NULL,

    customer_type_code VARCHAR(20) NOT NULL,
    segment_code VARCHAR(20) NOT NULL,

    status_code VARCHAR(20) NOT NULL,
    risk_code VARCHAR(20) NOT NULL,

    country_code CHAR(2) NOT NULL,
    onboarding_date DATE NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_customers
        PRIMARY KEY (customer_id),

    CONSTRAINT uq_customers_customer_number
        UNIQUE (customer_number),

    CONSTRAINT fk_customers_type
        FOREIGN KEY (customer_type_code)
        REFERENCES reference.customer_types(customer_type_code),

    CONSTRAINT fk_customers_segment
        FOREIGN KEY (segment_code)
        REFERENCES reference.customer_segments(segment_code),

    CONSTRAINT fk_customers_status
        FOREIGN KEY (status_code)
        REFERENCES reference.customer_statuses(status_code),

    CONSTRAINT fk_customers_risk
        FOREIGN KEY (risk_code)
        REFERENCES reference.risk_ratings(risk_code),

    CONSTRAINT fk_customers_country
        FOREIGN KEY (country_code)
        REFERENCES reference.countries(country_code),

    CONSTRAINT chk_customer_number_not_blank
        CHECK (LENGTH(BTRIM(customer_number)) > 0)
);
```

## 11.3 Explain the design choices

-   BIGINT GENERATED ALWAYS AS IDENTITY: PostgreSQL generates an
    internal integer key. ALWAYS discourages ordinary explicit values
    being supplied; overriding requires an explicit OVERRIDING SYSTEM
    VALUE clause.

-   customer_number is separate from customer_id: the business
    identifier can be exposed to business users without making it the
    internal relational key.

-   Named constraints: explicit names make schema inspection, error
    interpretation and future migrations easier.

-   Foreign keys: a customer cannot refer to a customer type, segment,
    status, risk rating or country absent from its corresponding
    reference table.

-   CHECK with BTRIM: rejects an empty or whitespace-only
    customer_number. NOT NULL separately rejects NULL.

-   created_at default: supplies a timestamp if the INSERT omits the
    column. It does not automatically update on later changes.

-   updated_at default: also only supplies an insert-time default. A
    trigger or application-managed UPDATE is needed to maintain it on
    subsequent updates.

Indexing nuance --- PostgreSQL automatically creates indexes to enforce
PRIMARY KEY and UNIQUE constraints. It does not automatically create
indexes on the referencing (foreign-key) columns. Add such indexes when
workload and query plans justify them; they can also improve parent-row
update/delete checks.

Date/time nuance --- TIMESTAMPTZ stores an instant and renders it
according to the session time zone. It does not preserve the original
time-zone name entered by a user. If the originating zone itself
matters, store it separately.

Model refinement --- A production customer master may need legal name,
preferred name, customer lifecycle dates, source lineage, data-quality
status, survivorship rules, soft-delete/closure handling and regulatory
classifications. These were not included in the first draft because we
are building the model incrementally. They should be assessed before
calling the schema production-ready.

## 11.4 Validation queries for the customer table

``` sql
-- Inspect columns and defaults:
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'customer'
  AND table_name = 'customers'
ORDER BY ordinal_position;

-- Inspect constraints:
SELECT
    conname AS constraint_name,
    contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'customer.customers'::regclass
ORDER BY conname;
```

  Constraint type code   Meaning
  ---------------------- -------------
  p                      Primary key
  f                      Foreign key
  u                      Unique
  c                      Check

Expected for the proposed table: 10 columns and 8 constraints: one
primary key, five foreign keys, one unique constraint and one check
constraint. This is the expected design result, not a confirmed
execution result.

Current checkpoint --- The user has not yet reported executing this
CREATE TABLE statement or its metadata checks. Treat customer.customers
as pending until verified.

# 12. Senior developer checklist

-   Confirm the target database before running DDL or DML: SELECT
    current_database(), current_user.

-   Use schema-qualified object names in scripts.

-   Define and document each table's grain.

-   Choose data types based on business semantics and volume, not habit.

-   Use primary keys and foreign keys to enforce entity identity and
    referential integrity.

-   Use NOT NULL, UNIQUE and CHECK constraints for appropriate row-level
    rules.

-   Name constraints consistently.

-   Do not assume foreign keys automatically create indexes on the
    referencing columns.

-   Use transactions for multi-step loads where atomicity is required.

-   Plan repeatable loads and explicit duplicate/conflict handling.

-   Keep secrets and real customer data out of training scripts and
    screenshots.

-   Use migrations/version-controlled SQL for changes rather than
    undocumented manual edits.

-   Test both valid and invalid inserts to prove constraints behave as
    expected.

-   Consider permissions and least privilege; do not use the superuser
    for normal application access.

# 13. Senior data analyst checklist

-   State the grain of every table before joining or aggregating.

-   Know whether the requested metric counts customers, applications,
    accounts, transactions or events.

-   Understand one-to-many joins and the risk of row multiplication.

-   Define numerator, denominator and exclusions explicitly for
    percentages.

-   Distinguish NULL from zero, blank and unknown.

-   Validate row counts after loads and transformations.

-   Reconcile source totals to target totals.

-   Check duplicate business keys and missing mandatory attributes.

-   Use COUNT(\*) and COUNT(column) appropriately.

-   Check the effective date and event timestamp when analysing
    historical records.

-   Do not infer that the latest row is the current row without a
    documented ordering and tie-breaking rule.

-   Do not treat illustrative training risk bands or statuses as
    regulatory policy.

# 14. Practice exercises and knowledge checks

## 14.1 Concept questions

1.  Explain the difference between PostgreSQL, a PostgreSQL server, a
    database, a schema, a table and pgAdmin.

2.  Why did we create banking_db instead of placing project tables
    inside postgres?

3.  What is the purpose of port 5432?

4.  Why is Stack Builder optional for this project?

5.  Explain the difference between the installation directory and data
    directory.

6.  What does a schema provide, and why do we qualify names such as
    customer.customers?

7.  What is the public schema? Why did our ten-schema query return ten
    rows even if other schemas exist?

8.  Define table grain. What could go wrong if you count customers after
    joining to multiple applications?

9.  Explain 1:1, 1:M and M:M relationships using banking examples.

10. Why do many-to-many relationships use a junction table?

11. Compare a natural key and a surrogate key.

12. Explain PRIMARY KEY versus FOREIGN KEY versus UNIQUE.

13. Explain 1NF, 2NF and 3NF in your own words.

14. Why are customer addresses and customer identifiers separate tables?

15. Why does a DEFAULT not prevent an explicit NULL?

16. What is the difference between COUNT(\*) and COUNT(column)?

17. Compare UNION and UNION ALL.

18. What does ON CONFLICT DO NOTHING do, and when could it hide a data
    issue?

19. Why doesn't updated_at automatically change when a row is updated?

20. Why can a table have valid row-level risk ranges but still have
    overlapping ranges across rows?

## 14.2 SQL practice tasks

1.  Run the environment verification query and explain each returned
    value.

2.  Query information_schema.schemata and identify the ten project
    schemas.

3.  Query information_schema.tables to list all base tables in the
    reference schema.

4.  Query information_schema.columns for reference.currencies and
    explain its data types and nullability.

5.  Query pg_constraint for each reference table and classify the
    constraints.

6.  Re-run the six-table count query and reconcile to 75.

7.  Write a query to identify any NULL currency names or decimal-place
    values.

8.  Write a query to identify duplicate currency names, even though the
    current schema has a UNIQUE constraint.

9.  Write a query that checks whether risk bands cover 0 through 100
    without gaps or overlaps.

10. Test an invalid decimal_places value and observe the CHECK
    constraint error. Do this only in a controlled statement that you
    allow to fail; inspect transaction state afterwards.

11. Attempt to insert a duplicate country_code and explain the error.

12. Demonstrate ON CONFLICT DO NOTHING on an already-existing country
    code and verify the row count remains unchanged.

13. After creating customer.customers, inspect its ten columns and eight
    constraints.

14. Attempt a customer insert with an invalid customer_type_code and
    explain the foreign key violation.

15. Attempt a whitespace-only customer_number and explain why the CHECK
    rejects it.

## 14.3 Suggested negative test patterns

``` sql
-- Example: test an invalid currency precision.
-- Expected: CHECK constraint violation.
INSERT INTO reference.currencies (
    currency_code, currency_name, decimal_places
)
VALUES ('XTS', 'Training Test Currency', 9);

-- Example: test a duplicate country key.
-- Expected: primary-key/unique violation.
INSERT INTO reference.countries (
    country_code, country_name
)
VALUES ('IN', 'India Duplicate Test');

-- Example: test an invalid customer type after customer.customers exists.
-- Expected: foreign-key violation.
-- Use a unique customer_number if this test is run.
INSERT INTO customer.customers (
    customer_number, customer_type_code, segment_code,
    status_code, risk_code, country_code, onboarding_date
)
VALUES (
    'TEST-INVALID-001', 'NOT_A_TYPE', 'RETAIL',
    'ACTIVE', 'LOW', 'IN', DATE '2026-01-01'
);
```

These are intentionally invalid test cases. Run them individually and
understand that a failed statement inside an explicit transaction can
leave the transaction in an aborted state until ROLLBACK. Do not run
destructive tests against real or production databases.

# 15. Progress tracker and next steps

  -----------------------------------------------------------------------
  Milestone                           Status
  ----------------------------------- -----------------------------------
  Install PostgreSQL 19 and pgAdmin 4 Completed / verified by user

  Connect to PostgreSQL on port 5432  Completed / verified by user

  Create banking_db owned by postgres Completed / verified by user

  Create ten business schemas         Completed / verified by user

  Create six reference tables         Completed / verified by user

  Load 75 reference records           Completed / verified by user

  Validate risk bands and record      Completed / verified by user
  counts                              

  Create customer.customers           Provided as exercise; execution
                                      pending confirmation

  Create individual and business      Upcoming
  profile tables                      

  Create address and identifier       Upcoming
  tables                              

  Create relationships and source     Upcoming
  mappings                            

  Create customer profile/status      Upcoming
  history                             

  Generate large synthetic customer   Upcoming
  datasets                            

  Build KYC, accounts, payments,      Future project phases
  lending and operations domains      
  -----------------------------------------------------------------------

## 15.1 Immediate next sequence

1.  Execute the proposed CREATE TABLE customer.customers statement.

2.  Inspect its columns using information_schema.columns.

3.  Inspect its constraints using pg_constraint; confirm one PK, five
    FKs, one UNIQUE and one CHECK.

4.  Review and refine the customer master requirements before loading
    customer records.

5.  Design individual_profiles and business_profiles with appropriate
    1:1 relationships.

6.  Design customer_addresses and customer_identifiers as one-to-many
    child tables.

7.  Design customer_source_mappings with source-system-aware uniqueness.

8.  Design customer_relationships as a self-referencing junction table.

9.  Design profile and status history with clear
    effective-time/event-time semantics.

10. Only after the model is agreed, generate large synthetic data and
    run referential-integrity and data-quality checks.

# Appendix A -- Quick SQL reference

  -----------------------------------------------------------------------
  Command / expression    Category                Purpose
  ----------------------- ----------------------- -----------------------
  CREATE DATABASE         DDL                     Create a database.

  CREATE SCHEMA           DDL                     Create a schema.

  CREATE TABLE            DDL                     Create a table.

  ALTER TABLE             DDL                     Change table definition
                                                  or constraints.

  DROP TABLE / DROP       DDL                     Remove objects;
  SCHEMA                                          potentially
                                                  destructive.

  INSERT INTO             DML                     Insert rows.

  UPDATE                  DML                     Modify existing rows.

  DELETE                  DML                     Delete selected rows.

  TRUNCATE                DML (commonly grouped   Remove all rows
                          with data-removal       efficiently; has
                          commands)               different
                                                  transactional/trigger
                                                  semantics from DELETE.

  SELECT                  Query                   Retrieve data.

  BEGIN / COMMIT /        Transaction control     Control transaction
  ROLLBACK                                        boundaries.

  PRIMARY KEY             Constraint              Unique, non-null row
                                                  identity.

  FOREIGN KEY             Constraint              Referential integrity.

  UNIQUE                  Constraint              Prevent duplicate key
                                                  values.

  CHECK                   Constraint              Enforce a row-level
                                                  predicate.

  DEFAULT                 Column definition       Supply a value when
                                                  omitted.

  COUNT(\*)               Aggregate               Count rows.

  COUNT(column)           Aggregate               Count non-NULL values.

  UNION                   Set operation           Combine and remove
                                                  duplicate rows.

  UNION ALL               Set operation           Combine and preserve
                                                  all rows.
  -----------------------------------------------------------------------

# Appendix B -- Key reminders

-   Always verify current_database() before executing project DDL or
    DML.

-   Never share the postgres password.

-   Use schema-qualified names, lowercase snake_case and explicit INSERT
    column lists.

-   One row must have a clearly defined meaning (grain).

-   Joins can multiply rows; count the correct business entity.

-   Constraints protect data even when it is inserted by a different
    client or application.

-   Record counts are necessary but not sufficient: validate keys,
    NULLs, relationships, ranges and business rules.

-   Use synthetic data only, especially for identity, financial and KYC
    examples.

-   Do not confuse the proposed model with implemented objects; confirm
    each DDL statement and its validation output.

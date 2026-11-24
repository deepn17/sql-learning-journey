SQL FOUNDATIONS

Introduction to SQL & Foundational Terminologies

A starter reference for database development, data analysis and
financial-services use cases

Purpose: Build a clear mental model of SQL and relational databases
before progressing into hands-on PostgreSQL querying. This is a
foundation guide, not a substitute for the detailed lessons that will
cover each topic with exercises.

Technology context --- Examples use PostgreSQL syntax where
dialect-specific behaviour matters. SQL is standardized in important
ways, but database products implement features and syntax differently.

# Contents

-   1.  What is data, a database and a DBMS?
-   2.  What is SQL?
-   3.  Relational database fundamentals
-   4.  Database architecture and terminology
-   5.  SQL command families
-   6.  Anatomy of a SQL query
-   7.  Data types and values
-   8.  Keys, constraints and integrity
-   9.  NULL and missing information
-   10. Core SQL concepts at a glance
-   11. Transactions and ACID
-   12. Indexes, views and other database objects
-   13. OLTP, OLAP and analytical data
-   14. SQL thinking for analysts and developers
-   15. Common beginner mistakes
-   16. Security, performance and production discipline
-   17. Glossary and revision questions

# 1. What is data, a database and a DBMS?

## 1.1 Data

Data is a recorded representation of facts, observations, events or
measurements. In a banking context, examples include a customer
reference, account opening date, transaction amount, payment status,
branch code and KYC verification timestamp.

Raw data becomes useful when it is structured, interpreted in context
and converted into information that supports decisions.

## 1.2 Database

A database is an organized collection of data that can be stored,
accessed, managed and maintained. A relational database organizes data
into relations (commonly represented as tables) and defines
relationships between them.

## 1.3 DBMS and RDBMS

  -----------------------------------------------------------------------
  Term                    Meaning                 Examples / notes
  ----------------------- ----------------------- -----------------------
  DBMS                    Database Management     A broad category that
                          System: software that   includes relational and
                          manages storage,        non-relational systems.
                          access, updates,        
                          concurrency, security   
                          and recovery of data.   

  RDBMS                   Relational DBMS:        PostgreSQL, Microsoft
                          manages data using      SQL Server, Oracle
                          relational structures,  Database, MySQL.
                          tables, keys and        
                          integrity rules.        

  Database engine         The software component  PostgreSQL server is
                          that processes queries  the engine in our
                          and manages database    learning environment.
                          operations.             

  Database client         An application used to  pgAdmin, psql,
                          connect to and interact application drivers and
                          with a database server. BI tools.
  -----------------------------------------------------------------------

A DBMS does much more than store rows. It controls concurrent access,
checks constraints, manages transactions, provides permissions,
maintains indexes, records logs and supports backup and recovery.

# 2. What is SQL?

SQL stands for Structured Query Language. It is the language used to
define relational database structures, insert and modify data, retrieve
information, control permissions and manage transactions.

SQL is declarative: in most queries, you describe the result you want
rather than writing every low-level step the database must perform. The
database optimizer chooses an execution strategy.

``` sql
SELECT
    transaction_status,
    COUNT(*) AS transaction_count
FROM payments.financial_transactions
GROUP BY transaction_status;
```

This query describes the desired result: count transactions for each
status. PostgreSQL determines how to access the data and perform the
aggregation.

## 2.1 Is SQL a programming language?

SQL is a domain-specific language for working with relational data. It
supports expressions, conditions, functions, variables or procedural
extensions in some products, but ordinary SQL querying is primarily
declarative. PostgreSQL also provides procedural capabilities such as
PL/pgSQL for functions and procedures.

## 2.2 SQL standard and database dialects

SQL has standards published by ANSI/ISO, but products implement features
at different times and add vendor-specific syntax. PostgreSQL SQL is the
dialect used in this project.

  Database product       Common procedural / dialect context
  ---------------------- ---------------------------------------------------
  PostgreSQL             PostgreSQL SQL; PL/pgSQL for procedural routines.
  Microsoft SQL Server   T-SQL.
  Oracle Database        Oracle SQL and PL/SQL.
  MySQL                  MySQL SQL dialect and stored-program syntax.

Career advice --- Learn portable SQL concepts first---joins, grouping,
subqueries, CTEs and window functions---then learn the dialect-specific
details of the platform used at work.

# 3. Relational database fundamentals

## 3.1 Tables, rows and columns

  ---------------------------------------------------------------------------------
  Term                    Meaning                 Example
  ----------------------- ----------------------- ---------------------------------
  Table                   A named structure       payments.financial_transactions
                          containing rows and     
                          columns.                

  Row / record            One occurrence          One payment transaction.
                          represented by the      
                          table.                  

  Column / attribute      A property of each row. transaction_amount,
                                                  transaction_status.

  Cell / field value      The value at a          12500.00 in transaction_amount.
                          row-column              
                          intersection.           

  Relation                The formal relational   A relation has attributes and
                          concept represented by  tuples.
                          a table-like set of     
                          tuples.                 
  ---------------------------------------------------------------------------------

## 3.2 Example table

  transaction_id   customer_id   amount     currency   status
  ---------------- ------------- ---------- ---------- ---------
  90001            1001          12500.00   INR        SUCCESS
  90002            1002          750.00     USD        FAILED
  90003            1001          4200.00    INR        PENDING

Each row represents one transaction. This statement defines the table's
grain. A table's grain must be understood before joining or aggregating
it.

## 3.3 Entity, attribute and relationship

-   Entity: a business object or concept about which data is stored,
    such as Customer, Account, KYC Application or Transaction.

-   Attribute: a property of an entity, such as customer_name,
    account_open_date or transaction_amount.

-   Relationship: an association between entities, such as a customer
    owning an account or an account having many transactions.

-   Entity modelling: identifying entities, their attributes,
    identifiers and relationships before creating tables.

## 3.4 Grain

Grain answers: what does exactly one row represent? Examples: one
customer, one account, one KYC application, one verification event, one
transaction or one transaction lifecycle event.

Analyst warning --- A one-to-many join can multiply rows. If one
customer has four accounts and each account has many transactions,
joining all three tables can produce multiple rows per customer. The
analyst must know the grain at every stage and count the correct
business entity.

# 4. Database architecture and foundational terminology

  -----------------------------------------------------------------------
  Term                                Definition
  ----------------------------------- -----------------------------------
  Database server / instance          A running database service that
                                      accepts connections and manages a
                                      database cluster. Terminology
                                      varies slightly across products.

  Database                            A logical database within the
                                      PostgreSQL cluster.

  Schema                              A namespace within a database that
                                      organizes objects.

  Table                               A named relational structure
                                      containing records.

  View                                A stored query definition presented
                                      as a virtual table; ordinary views
                                      do not store their result rows.

  Materialized view                   A database object that stores a
                                      query result and must be refreshed
                                      to reflect later source changes.

  Index                               An auxiliary data structure that
                                      can speed up selected access
                                      patterns at the cost of storage and
                                      write overhead.

  Sequence / identity                 A mechanism for generating numeric
                                      values, often used for surrogate
                                      keys.

  Constraint                          A rule enforced by the database,
                                      such as primary key, foreign key,
                                      unique, not null or check.

  Function                            A reusable database routine that
                                      returns a value or set of values.

  Procedure                           A stored routine invoked to perform
                                      an operation; capabilities vary by
                                      database product.

  Trigger                             A database routine automatically
                                      invoked in response to specified
                                      table or database events.

  Role                                A database identity or group of
                                      privileges in PostgreSQL.

  Tablespace                          A named storage location that can
                                      influence where database objects
                                      are stored.

  Catalog / metadata                  Information describing database
                                      objects, definitions, permissions
                                      and internal structures.
  -----------------------------------------------------------------------

## 4.1 PostgreSQL object hierarchy

PostgreSQL server / cluster ├── Database: banking_db │ ├── Schema:
customer │ │ ├── Table: customers │ │ ├── Table: customer_addresses │ │
└── View: customer_summary │ ├── Schema: payments │ │ ├── Table:
financial_transactions │ │ └── Table: transaction_events │ └── Schema:
reference │ ├── Table: countries │ └── Table: currencies └── Database:
postgres

In PostgreSQL, a schema belongs to a database. Ordinary SQL sessions
connect to one database at a time. A schema-qualified object name has
the form schema_name.object_name.

## 4.2 Client-server model

A client sends a connection request and SQL statements to the database
server. The server authenticates the user, checks permissions, parses
and plans the SQL, executes it, and returns results or an error.

-   pgAdmin is a graphical client.

-   psql is a command-line client.

-   Python applications can connect through database drivers such as
    psycopg.

-   BI and reporting applications can connect through supported drivers
    or connectors.

-   The server remains responsible for executing SQL and enforcing
    database rules.

# 5. SQL command families

SQL commands are often grouped into families for learning. These labels
are useful, although exact classification can vary among references and
database products.

  -----------------------------------------------------------------------
  Family                  Purpose                 Common commands
  ----------------------- ----------------------- -----------------------
  DDL -- Data Definition  Define or change        CREATE, ALTER, DROP,
  Language                database objects.       TRUNCATE.

  DML -- Data             Insert, change or       INSERT, UPDATE, DELETE,
  Manipulation Language   delete data.            MERGE (where
                                                  supported).

  DQL -- Data Query       Retrieve data.          SELECT. Often treated
  Language                                        as part of DML in some
                                                  classifications.

  DCL -- Data Control     Manage privileges and   GRANT, REVOKE.
  Language                access.                 

  TCL -- Transaction      Control transaction     BEGIN, COMMIT,
  Control Language        boundaries.             ROLLBACK, SAVEPOINT.
  -----------------------------------------------------------------------

## 5.1 DDL examples

``` sql
CREATE TABLE customer.customers (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL
);

ALTER TABLE customer.customers
ADD COLUMN onboarding_date DATE;

-- DROP removes the object and its data:
-- DROP TABLE customer.customers;
```

## 5.2 DML examples

``` sql
INSERT INTO customer.customers (
    customer_id, customer_name
)
VALUES (1001, 'Asha Rao');

UPDATE customer.customers
SET customer_name = 'Asha R.'
WHERE customer_id = 1001;

DELETE FROM customer.customers
WHERE customer_id = 1001;
```

Safety --- An UPDATE or DELETE without a WHERE clause affects every row
in the target table. Before running data-changing statements, verify the
target rows with a SELECT and use a transaction where appropriate.

## 5.3 DQL example

``` sql
SELECT customer_id, customer_name
FROM customer.customers
WHERE customer_id = 1001;
```

## 5.4 DCL example

``` sql
-- Illustrative permission examples:
GRANT SELECT ON customer.customers TO analyst_role;
REVOKE SELECT ON customer.customers FROM analyst_role;
```

## 5.5 TCL example

``` sql
BEGIN;

UPDATE accounts.bank_accounts
SET available_balance = available_balance - 500
WHERE account_id = 101;

UPDATE accounts.bank_accounts
SET available_balance = available_balance + 500
WHERE account_id = 202;

COMMIT;

-- Use ROLLBACK instead of COMMIT if the
-- transaction must be undone before commit.
```

The balance-transfer example is conceptual. A real payment system
requires stronger controls, concurrency handling, ledger entries,
idempotency, validation, and carefully designed transaction semantics.

# 6. Anatomy of a SQL query

``` sql
SELECT
    currency_code,
    COUNT(*) AS transaction_count,
    SUM(transaction_amount) AS total_amount
FROM payments.financial_transactions
WHERE transaction_status = 'SUCCESS'
GROUP BY currency_code
HAVING COUNT(*) >= 100
ORDER BY total_amount DESC
LIMIT 10;
```

  -----------------------------------------------------------------------
  Clause                              Role
  ----------------------------------- -----------------------------------
  SELECT                              Choose expressions/columns to
                                      return.

  FROM                                Choose source tables, views or
                                      other row sources.

  WHERE                               Filter individual input rows before
                                      grouping.

  GROUP BY                            Create groups for aggregate
                                      calculations.

  HAVING                              Filter groups after aggregation.

  ORDER BY                            Sort the final result.

  LIMIT / OFFSET                      Limit or skip returned rows; syntax
                                      and alternatives vary by product.
  -----------------------------------------------------------------------

## 6.1 Logical processing order

A useful conceptual order for a simple SELECT is:

FROM / JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

This is a logical model for understanding query behaviour, not a promise
about the physical execution order. The optimizer may choose a different
physical plan while preserving the query's semantics.

## 6.2 Aliases and expressions

``` sql
SELECT
    transaction_amount,
    transaction_amount * 0.02 AS estimated_fee
FROM payments.financial_transactions;
```

An alias gives a result column or table a temporary name within the
query. An expression calculates a value from columns, literals,
operators or functions.

## 6.3 Comments and formatting

``` sql
-- Single-line comment

/*
   Multi-line comment
*/

SELECT customer_id, customer_name
FROM customer.customers
WHERE status_code = 'ACTIVE';
```

SQL keywords are commonly written in uppercase for readability, but
PostgreSQL does not require this. Consistent indentation, explicit
column lists and meaningful aliases make SQL easier to review and
maintain.

# 7. Data types and values

A data type defines what kind of value a column can store and influences
validation, storage, operators and functions.

  -----------------------------------------------------------------------
  Category                PostgreSQL examples     Typical use
  ----------------------- ----------------------- -----------------------
  Integer                 SMALLINT, INTEGER,      Counts, identifiers,
                          BIGINT                  whole-number
                                                  quantities.

  Exact numeric           NUMERIC(p,s),           Money and exact decimal
                          DECIMAL(p,s)            values.

  Approximate numeric     REAL, DOUBLE PRECISION  Scientific or
                                                  approximate
                                                  calculations where
                                                  floating-point
                                                  behaviour is
                                                  acceptable.

  Character               CHAR(n), VARCHAR(n),    Codes, names,
                          TEXT                    descriptions and text.

  Boolean                 BOOLEAN                 True/false states.

  Date/time               DATE, TIME, TIMESTAMP,  Business dates, event
                          TIMESTAMPTZ, INTERVAL   times, time-zone-aware
                                                  instants and durations.

  UUID                    UUID                    Globally unique
                                                  identifiers.

  Binary                  BYTEA                   Binary data such as
                                                  file content, when
                                                  appropriate.

  Structured              JSON, JSONB             JSON documents or
  semi-structured                                 flexible attributes;
                                                  use thoughtfully rather
                                                  than replacing
                                                  relational design.
  -----------------------------------------------------------------------

## 7.1 Important data type distinctions

-   INTEGER versus BIGINT: choose enough range for expected volume and
    growth; BIGINT uses more storage than INTEGER.

-   NUMERIC versus FLOAT: NUMERIC provides exact decimal arithmetic;
    floating-point types are approximate.

-   DATE versus TIMESTAMP: DATE has no time-of-day; TIMESTAMP includes
    date and time.

-   TIMESTAMP versus TIMESTAMPTZ: PostgreSQL TIMESTAMPTZ represents an
    instant and displays it in the session time zone; it does not
    preserve the original zone label.

-   CHAR versus VARCHAR/TEXT: CHAR(n) is blank-padded; variable-length
    types are often more convenient for ordinary text.

-   JSONB: useful for flexible document-like attributes and querying
    JSON, but core business entities and relationships should still be
    modelled deliberately.

Financial data rule --- For monetary values, use an exact numeric type
and define currency, precision, scale, rounding and conversion rules. A
number without its currency is often incomplete business information.

# 8. Keys, constraints and data integrity

  -----------------------------------------------------------------------
  Concept                             Meaning
  ----------------------------------- -----------------------------------
  Primary key                         Uniquely identifies a row; in
                                      PostgreSQL it enforces uniqueness
                                      and NOT NULL.

  Foreign key                         Requires a referenced key to exist
                                      in the parent/referenced table,
                                      subject to the chosen referential
                                      action.

  Candidate key                       A minimal set of attributes that
                                      can uniquely identify a row.

  Natural key                         A business-meaningful identifier,
                                      such as a standardized code.

  Surrogate key                       An internally generated identifier
                                      without business meaning.

  Composite key                       A key made from more than one
                                      column.

  UNIQUE constraint                   Prevents duplicate key values or
                                      combinations.

  NOT NULL                            Requires a value in the column.

  CHECK constraint                    Enforces a Boolean row-level
                                      condition.

  DEFAULT                             Supplies a value when a column is
                                      omitted or DEFAULT is requested.
  -----------------------------------------------------------------------

## 8.1 Referential actions

A foreign key can specify what should happen when a referenced parent
key is updated or deleted. Common actions include NO ACTION, RESTRICT,
CASCADE, SET NULL and SET DEFAULT. Choose these based on business
lifecycle rules; CASCADE can be dangerous if it deletes large dependent
datasets unexpectedly.

## 8.2 Integrity categories

-   Entity integrity: every row has a reliable identity, commonly
    enforced by a primary key.

-   Referential integrity: child references point to valid parent
    records.

-   Domain integrity: values satisfy the data type and allowed-value
    rules.

-   Business-rule integrity: data follows rules specific to the business
    process.

# 9. NULL and missing information

NULL is a marker for missing, unknown or not-applicable information. Its
exact business meaning should be documented. NULL is not the same as
zero, an empty string, false or the word 'NULL'.

  Value    Possible meaning
  -------- -------------------------------------
  NULL     Unknown, missing or not applicable.
  0        Known numeric value equal to zero.
  ''       Known empty text string.
  FALSE    Known Boolean false.
  'NULL'   Four-character text value N-U-L-L.

## 9.1 Testing NULL

``` sql
-- Correct:
SELECT *
FROM customer.customers
WHERE onboarding_date IS NULL;

-- Incorrect:
-- WHERE onboarding_date = NULL
```

## 9.2 Three-valued logic

SQL conditions can evaluate to TRUE, FALSE or UNKNOWN. A comparison
involving NULL commonly evaluates to UNKNOWN. WHERE retains only rows
for which the predicate is TRUE.

``` sql
SELECT
    COUNT(*) AS all_rows,
    COUNT(customer_id) AS non_null_ids,
    COUNT(country_code) AS non_null_countries
FROM customer.customers;
```

## 9.3 Useful NULL functions

  Function                Purpose
  ----------------------- -----------------------------------------------------------
  COALESCE(a,b,...)       Returns the first non-NULL expression.
  NULLIF(a,b)             Returns NULL when a equals b; otherwise returns a.
  IS NULL / IS NOT NULL   Tests whether an expression is NULL.
  CASE                    Applies conditional logic and can explicitly handle NULL.

``` sql
SELECT
    COALESCE(preferred_name, legal_name, 'Unknown') AS display_name
FROM customer.customers;

-- Avoid division by zero:
SELECT completed_cases::NUMERIC / NULLIF(total_cases, 0)
FROM kyc.case_metrics;
```

# 10. Core SQL concepts at a glance

  -----------------------------------------------------------------------
  Concept                 What it does            Example / use
  ----------------------- ----------------------- -----------------------
  SELECT                  Retrieves columns and   Select customer IDs and
                          expressions.            names.

  WHERE                   Filters rows.           Only completed KYC
                                                  cases.

  DISTINCT                Removes duplicate       List unique country
                          result rows.            codes.

  ORDER BY                Sorts results.          Largest transactions
                                                  first.

  LIMIT                   Restricts returned row  Preview 20 rows.
                          count.                  

  AND / OR / NOT          Combines or negates     Active AND premium; or
                          conditions.             failed OR reversed.

  IN                      Tests membership in a   status_code IN
                          list or subquery.       ('ACTIVE','DORMANT').

  BETWEEN                 Tests an inclusive      transaction_date
                          range.                  BETWEEN start_date AND
                                                  end_date.

  LIKE / ILIKE            Pattern matching; ILIKE Find names beginning
                          is PostgreSQL           with a prefix.
                          case-insensitive        
                          matching.               

  CASE                    Conditional expression. Map scores to risk
                                                  bands.

  Aggregate functions     Summarize multiple      COUNT, SUM, AVG, MIN,
                          rows.                   MAX.

  GROUP BY                Groups rows for         Transaction totals by
                          aggregates.             currency.

  HAVING                  Filters groups after    Currencies with more
                          aggregation.            than 1,000
                                                  transactions.

  JOIN                    Combines related row    Customers with their
                          sources.                accounts.

  Subquery                Query nested inside     Find customers above
                          another query.          average balance.

  CTE                     Named query expression  Break a complex
                          using WITH.             transformation into
                                                  readable steps.

  Set operations          Combine compatible      UNION, UNION ALL,
                          result sets.            INTERSECT, EXCEPT.

  Window function         Calculates across       Rank transactions per
                          related rows without    customer.
                          collapsing them into    
                          one row per group.      

  DML                     Changes stored data.    INSERT, UPDATE, DELETE.

  DDL                     Changes database        CREATE, ALTER, DROP.
                          structures.             
  -----------------------------------------------------------------------

These topics will be taught in sequence with increasingly complex
financial-services scenarios. This section is an orientation, not a full
syntax reference.

# 11. Transactions and ACID

A transaction is a logical unit of work. It can contain one or more
statements and is committed as a unit or rolled back.

  -----------------------------------------------------------------------
  ACID property           Meaning                 Banking illustration
  ----------------------- ----------------------- -----------------------
  Atomicity               All operations in the   A transfer must not
                          transaction succeed     debit one account
                          together or are rolled  without the
                          back.                   corresponding credit
                                                  being recorded.

  Consistency             A committed transaction Constraints and
                          preserves defined       business controls
                          database rules and      remain satisfied.
                          invariants.             

  Isolation               Concurrent transactions Two simultaneous
                          are controlled so they  withdrawals must not
                          do not produce          spend the same
                          unacceptable            available balance.
                          interference.           

  Durability              Once committed, changes A committed payment
                          survive a crash         record should survive
                          according to the        server restart.
                          database's durability   
                          guarantees.             
  -----------------------------------------------------------------------

PostgreSQL supports transaction isolation levels, locks and MVCC
(Multi-Version Concurrency Control). These topics matter when multiple
users or applications read and update the same data concurrently.

Important --- ACID is a database transaction property set. It does not
by itself guarantee a complete payment system, external bank settlement,
message delivery, or end-to-end exactly-once processing.

# 12. Indexes, views and other database objects

## 12.1 Indexes

An index is an auxiliary structure that can help the database locate
rows without scanning an entire table. Indexes are not automatically
beneficial for every column.

-   Indexes can speed up selective filters, joins, ordering and
    uniqueness enforcement.

-   Indexes consume storage and add work to INSERT, UPDATE and DELETE
    operations.

-   An index on a low-selectivity column may not help every query.

-   Composite index column order matters for many access patterns.

-   Use EXPLAIN and EXPLAIN ANALYZE to inspect query plans and measured
    execution behaviour; EXPLAIN ANALYZE actually executes the
    statement.

## 12.2 Views

A view stores a query definition and exposes it as a named virtual
table. It can simplify repeated logic and provide a controlled interface
to underlying tables. A normal view generally does not store a separate
copy of its result.

## 12.3 Materialized views

A materialized view stores query results. It can make expensive
reporting reads faster, but the stored result can become stale until
refreshed. Refresh strategy and freshness requirements must be designed.

## 12.4 Sequences and identity columns

PostgreSQL identity columns use sequence-backed value generation. They
are useful for surrogate keys. Generated IDs should not be assumed to be
gapless: rollbacks, caching and other behaviour can produce gaps.

## 12.5 Functions, procedures and triggers

-   Functions encapsulate reusable database logic and return a value or
    set of values.

-   Procedures perform database operations and can support procedural
    workflows; exact capabilities vary by product.

-   Triggers automatically run in response to specified events, for
    example to maintain audit history or updated_at values.

-   Triggers should be documented and tested carefully because they
    introduce behaviour that may not be visible in the calling SQL
    statement.

# 13. OLTP, OLAP and analytical data

  -----------------------------------------------------------------------
  Dimension               OLTP                    OLAP
  ----------------------- ----------------------- -----------------------
  Primary goal            Run day-to-day          Analyse business
                          transactions.           performance and trends.

  Typical workload        Frequent small reads    Large scans,
                          and writes.             aggregations and
                                                  complex joins.

  Data shape              Often normalized        Often dimensional or
                          operational tables.     denormalized analytical
                                                  structures.

  Examples                Post payment, open      Monthly transaction
                          account, update KYC     trends, customer
                          status.                 segmentation, SLA
                                                  analysis.

  Users / systems         Applications and        Analysts, BI tools,
                          operational users.      reporting and data
                                                  science.
  -----------------------------------------------------------------------

A data warehouse often organizes information into facts and dimensions.
A fact table stores measurable events at a defined grain; dimensions
provide descriptive context such as customer, product, date, branch or
geography.

A star schema typically has a central fact table connected to dimension
tables. A snowflake schema further normalizes some dimensions. These
models will be covered when the project reaches analytics and reporting.

Project connection --- Our banking_db training environment begins with
operational-style relational modelling. Later we will build
reporting-oriented structures and compare the trade-offs between
normalized OLTP designs and analytical models.

# 14. SQL thinking for analysts and developers

## 14.1 Senior data analyst approach

1.  Clarify the business question and the definition of the metric.

2.  Identify the population: which records are in scope and which are
    excluded?

3.  Define the numerator and denominator for rates and percentages.

4.  Identify the grain of every source table.

5.  Understand relationships and possible row multiplication.

6.  Check NULLs, duplicates, invalid values and late-arriving records.

7.  Choose the correct time field and reporting period.

8.  Write the query in readable steps and validate intermediate results.

9.  Reconcile totals to an independent source or control total.

10. Explain the result and its limitations in business language.

## 14.2 Senior developer approach

1.  Understand requirements, volume, workload and lifecycle before
    designing tables.

2.  Define entities, grain, keys, relationships and constraints.

3.  Choose data types and nullability deliberately.

4.  Plan permissions and protect sensitive information.

5.  Use version-controlled migrations and repeatable deployment scripts.

6.  Use transactions and safe error handling.

7.  Test valid cases, invalid cases, edge cases and concurrent
    behaviour.

8.  Inspect query plans and optimize based on evidence.

9.  Plan backup, recovery, monitoring and operational ownership.

10. Document assumptions, business rules and data lineage.

## 14.3 Business analyst approach

-   Ask what each status means and whether statuses are mutually
    exclusive.

-   Clarify whether pending, cancelled, rejected or reopened records
    belong in a denominator.

-   Determine whether the metric is customer-level, application-level or
    event-level.

-   Clarify effective dates, business calendars, time zones and cut-off
    times.

-   Define treatment of corrections, reversals, duplicates and missing
    records.

-   Turn requirements into testable acceptance criteria and example
    scenarios.

# 15. Common beginner mistakes

  -----------------------------------------------------------------------
  Mistake                             Why it is a problem / better habit
  ----------------------------------- -----------------------------------
  Using SELECT \* in every query      Retrieves unnecessary columns and
                                      makes downstream dependencies
                                      fragile. Select the columns needed.

  Forgetting WHERE on UPDATE/DELETE   Can change or remove every row.
                                      Preview target rows and use a
                                      controlled transaction.

  Using = NULL                        NULL uses three-valued logic. Use
                                      IS NULL or IS NOT NULL.

  Assuming joins preserve row counts  One-to-many joins multiply rows.
                                      Know the grain and cardinality.

  Counting joined rows as entities    May overcount customers or
                                      accounts. Count the correct key or
                                      aggregate before joining.

  Using FLOAT for money               Floating-point values are
                                      approximate. Prefer NUMERIC with
                                      defined precision/scale.

  Relying only on application         Other clients can bypass
  validation                          application code. Enforce critical
                                      rules in the database too.

  Creating indexes on every column    Indexes cost space and slow writes.
                                      Index based on actual workload and
                                      query plans.

  Assuming row order without ORDER BY SQL result order is not guaranteed
                                      without an explicit ORDER BY.

  Assuming DEFAULT replaces explicit  A supplied NULL is a value; the
  NULL                                default is used when the column is
                                      omitted or DEFAULT is specified.

  Treating successful execution as    Validate counts, keys,
  proof of correctness                relationships, edge cases and
                                      business outcomes.
  -----------------------------------------------------------------------

# 16. Security, performance and production discipline

## 16.1 Security basics

-   Use least privilege: grant each role only the permissions required
    for its work.

-   Separate administrative, application, ETL and analyst roles where
    appropriate.

-   Protect credentials; do not hard-code passwords in scripts or commit
    them to source control.

-   Use parameterized queries in applications to reduce SQL injection
    risk.

-   Mask or tokenize sensitive identifiers in non-production
    environments.

-   Use synthetic training data; do not copy real personal or financial
    data into a learning database.

-   Audit privileged access and sensitive data access according to
    organizational policy.

## 16.2 Performance basics

-   Return only required columns and rows.

-   Filter as early as the business logic permits, while understanding
    optimizer behaviour.

-   Use appropriate join keys and data types.

-   Avoid unnecessary functions or casts on indexed columns when they
    prevent efficient index use.

-   Use EXPLAIN to inspect estimated plans and EXPLAIN ANALYZE for
    measured execution.

-   Consider table statistics, indexes, partitioning and data
    distribution for large datasets.

-   Measure before optimizing; do not guess based solely on query
    appearance.

## 16.3 Reliability and operations

-   Use backups and test restoration; a backup that has never been
    restored is not fully proven.

-   Understand logging, monitoring, storage growth and connection
    limits.

-   Use migrations to track schema changes.

-   Design data loads to be repeatable, auditable and recoverable.

-   Validate row counts and key relationships after each load.

-   Plan for concurrent updates, deadlocks, retries and idempotency in
    application workflows.

# 17. Glossary and revision questions

  -----------------------------------------------------------------------
  Term                                Short definition
  ----------------------------------- -----------------------------------
  ACID                                Atomicity, Consistency, Isolation,
                                      Durability.

  Aggregate                           A calculation over multiple rows,
                                      e.g. COUNT or SUM.

  Alias                               Temporary name for a table or
                                      result expression.

  Cardinality                         Can describe relationship
                                      multiplicity or the number of
                                      distinct values, depending on
                                      context.

  CTE                                 Common Table Expression; a named
                                      query expression introduced with
                                      WITH.

  Data dictionary                     Documentation or metadata
                                      describing data elements and
                                      structures.

  Data lineage                        Record of where data came from and
                                      how it was transformed.

  Data quality                        Fitness of data for its intended
                                      use, including accuracy,
                                      completeness, consistency, validity
                                      and timeliness.

  Deadlock                            A situation where transactions wait
                                      on each other in a cycle; the DBMS
                                      detects and aborts one transaction.

  Execution plan                      The strategy the optimizer selects
                                      to execute a query.

  Idempotency                         A repeated operation has the same
                                      intended effect as performing it
                                      once, under defined conditions.

  Join cardinality                    How rows from joined sources relate
                                      and how many output rows may
                                      result.

  MVCC                                Multi-Version Concurrency Control;
                                      PostgreSQL's concurrency mechanism
                                      using row versions.

  Normalization                       Organizing relational structures to
                                      reduce undesirable dependency and
                                      update anomalies.

  Query optimizer                     Database component that evaluates
                                      possible execution strategies and
                                      chooses a plan.

  Referential integrity               Guarantee that references between
                                      related tables remain valid.

  Schema                              Namespace grouping database
                                      objects.

  Surrogate key                       Internally generated identifier
                                      without direct business meaning.

  Transaction                         A logical unit of database work.

  Tuple                               Formal relational term for a row.

  View                                Named query presented as a virtual
                                      table.
  -----------------------------------------------------------------------

## 17.1 Self-check questions

1.  What does SQL stand for, and what does declarative mean?

2.  What is the difference between a database and a DBMS?

3.  How do a PostgreSQL server, database, schema and table relate?

4.  What is the grain of a transaction table?

5.  Why can a join increase the number of rows?

6.  What is the difference between a primary key and a foreign key?

7.  When would a junction table be required?

8.  Why should monetary values generally use NUMERIC rather than DOUBLE
    PRECISION?

9.  What is the difference between NULL and zero?

10. What is the difference between WHERE and HAVING?

11. What is the difference between UNION and UNION ALL?

12. What does an index trade off?

13. What does ACID stand for?

14. How does OLTP differ from OLAP?

15. What checks should be performed after loading a dataset?

## 17.2 Suggested learning sequence

  -----------------------------------------------------------------------
  Stage                               Topics to study in depth
  ----------------------------------- -----------------------------------
  Foundation                          SELECT, FROM, WHERE, aliases,
                                      expressions, operators, NULL.

  Filtering and sorting               AND/OR, IN, BETWEEN, LIKE/ILIKE,
                                      DISTINCT, ORDER BY, LIMIT.

  Aggregation                         COUNT, SUM, AVG, MIN, MAX, GROUP
                                      BY, HAVING.

  Relationships                       INNER, LEFT, RIGHT and FULL joins;
                                      self joins; many-to-many.

  Conditional logic                   CASE, COALESCE, NULLIF, type
                                      casting and date/time functions.

  Query composition                   Subqueries, correlated subqueries,
                                      CTEs and set operations.

  Advanced analysis                   Window functions, ranking, running
                                      totals, LAG, LEAD and moving
                                      averages.

  Engineering                         Indexes, query plans, transactions,
                                      constraints, locking and
                                      performance.

  Data engineering                    Staging, incremental loads,
                                      deduplication, late-arriving data,
                                      reconciliation and lineage.

  Analytics architecture              Facts, dimensions, star schemas,
                                      slowly changing dimensions and
                                      reporting models.
  -----------------------------------------------------------------------

# Final perspective

SQL is not just a way to retrieve information. It is the language
through which you express data requirements, enforce rules, connect
business entities, transform records and produce evidence for decisions.

A strong SQL practitioner does not only ask, "Does this query run?" They
also ask:

-   Does it answer the correct business question?

-   Does it count the correct entity at the correct grain?

-   Are NULLs, duplicates, reversals and historical records handled
    correctly?

-   Are the relationships and constraints sound?

-   Will the query remain understandable and maintainable?

-   Does it perform acceptably at realistic data volumes?

-   Can the result be reconciled and explained?

Use this guide as your orientation manual. The next lessons will turn
these concepts into working SQL against the enterprise banking dataset.

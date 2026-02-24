# Simple DB Search API

## Overview

This project is a simple ASP.NET Core Web API that provides search and paginated retrieval of records from a SQL Server database. The implementation focuses on clean schema design, appropriate indexing, efficient pagination, and awareness of performance trade-offs. The solution is suitable for assignment/demo purposes and is designed with scalability considerations in mind.

---

## 1. Schema & Index Choices

### Schema Design

The database schema follows standard relational design principles:

- `Id` (INT, Primary Key) – uniquely identifies each record.
- `Name` (NVARCHAR) – searchable/display field.
- `Description` (NVARCHAR, nullable) – optional details.
- `Category` (NVARCHAR) – filterable field.
- `CreatedAt` (DATETIME) – used for sorting and pagination.

### Index Strategy

Indexes were created based on query patterns:

1. Primary Key Index
   - Ensures fast lookups by `Id`.

2. Index on CreatedAt
   - Optimizes `ORDER BY CreatedAt DESC` used in pagination.
   - Improves performance of sorted queries.

3. Index on Category (or other filter columns)
   - Improves performance when filtering by category.

Rationale:

- Reduce full table scans.
- Improve sorting performance.

## 2. How Pagination Works

Pagination is implemented using SQL Server’s `OFFSET / FETCH`:

1. The client sends `PageNumber` and `PageSize`.
2. The API calculates the offset:

## 3. Performance Assumptions

The solution assumes:

- A moderate to large dataset (potentially hundreds of thousands to millions of rows).
- Queries frequently involve sorting by `CreatedAt`.
- Page sizes are kept within reasonable limits.
- Proper indexes exist on sorting and filtering columns.

Expected behavior:

- Good performance for early and mid-range pages.
- Efficient execution plans due to indexing.
- Reduced IO compared to full table scans.

## 4. What Would Change in Production

For a production-grade system, the following improvements would be implemented:

### 1. Keyset Pagination (Seek Method)

Replace OFFSET-based pagination with a seek-based approach:

- Use `WHERE CreatedAt < @LastSeenCreatedAt`
- Avoid large row skipping.

### 2. Caching Layer

Introduce caching (e.g., Redis):

- Cache frequently requested pages.
- Reduce database load.
- Improve response time for repeated queries.

### 4. Optimized Count Strategy

- Cache total record counts.
- Use approximate counts if exact precision is not required.
- Avoid expensive full table counts on every request.

### 5. Security Improvements

- Store connection strings securely (environment variables or secret manager).
- Enforce HTTPS.
- Add authentication and authorization.
- Validate input parameters.

### 7. Rate Limiting & Validation

- Enforce maximum `PageSize`.
- Prevent abusive or overly expensive queries.

### 8. Scalability Enhancements

- Introduce read replicas for heavy read workloads.
- Support horizontal scaling.
- Improve deployment via CI/CD pipelines.
# API Documentation

## Overview

The TTSHUB REST API uses JSON for all request and response bodies. All endpoints are prefixed with `/api`.

**Base URL:** `https://api.ttshub.com` (production) | `http://localhost:3000` (development)

---

## Authentication

TTSHUB uses **JWT (JSON Web Token)** bearer authentication.

### Obtaining a Token

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expiresIn": 900
  }
}
```

### Using the Token

Include the token in the `Authorization` header for all protected endpoints:

```http
Authorization: Bearer <accessToken>
```

### Refreshing a Token

```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

---

## Response Format

All API responses follow this envelope structure:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional human-readable message",
  "errors": []
}
```

On error:

```json
{
  "success": false,
  "data": null,
  "message": "A description of what went wrong",
  "errors": [
    { "field": "email", "message": "Invalid email format" }
  ]
}
```

---

## Error Codes

| HTTP Status | Code | Description |
|-------------|------|-------------|
| `400` | `VALIDATION_ERROR` | Request body failed validation |
| `401` | `UNAUTHORIZED` | Missing or invalid authentication token |
| `403` | `FORBIDDEN` | Authenticated but not authorized |
| `404` | `NOT_FOUND` | Resource does not exist |
| `409` | `CONFLICT` | Resource already exists (e.g. duplicate email) |
| `422` | `UNPROCESSABLE` | Request understood but cannot be processed |
| `429` | `RATE_LIMITED` | Too many requests — back off and retry |
| `500` | `INTERNAL_ERROR` | Unexpected server error |

---

## Pagination

List endpoints support cursor-based pagination via query parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `page` | `1` | Page number |
| `limit` | `20` | Items per page (max: 100) |

**Example:**
```
GET /api/users?page=2&limit=10
```

**Paginated Response:**
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "pagination": {
      "page": 2,
      "limit": 10,
      "total": 150,
      "totalPages": 15
    }
  }
}
```

---

## User Endpoints

### 1. Get All Users

- **Endpoint:** `GET /api/users`
- **Auth:** Required (admin only)
- **Description:** Retrieves a paginated list of all registered users.

**Request:**
```http
GET /api/users?page=1&limit=20
Authorization: Bearer <token>
```

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "usr_01HXYZ123",
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "role": "provider",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 42, "totalPages": 3 }
  }
}
```

---

### 2. Get User by ID

- **Endpoint:** `GET /api/users/{id}`
- **Auth:** Required
- **Description:** Retrieves a single user profile by their ID.

**Request:**
```http
GET /api/users/usr_01HXYZ123
Authorization: Bearer <token>
```

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "id": "usr_01HXYZ123",
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "role": "provider",
    "bio": "DevOps engineer with 8 years of AWS experience.",
    "skills": ["AWS", "Terraform", "Kubernetes"],
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

**Response `404 Not Found`:**
```json
{
  "success": false,
  "data": null,
  "message": "User not found",
  "errors": []
}
```

---

### 3. Create User

- **Endpoint:** `POST /api/users`
- **Auth:** Not required (public registration)
- **Description:** Registers a new user account.

**Request:**
```http
POST /api/users
Content-Type: application/json

{
  "name": "Bob Smith",
  "email": "bob@example.com",
  "password": "securepassword123",
  "role": "client"
}
```

**Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "usr_01HABC456",
    "name": "Bob Smith",
    "email": "bob@example.com",
    "role": "client",
    "createdAt": "2024-06-01T09:00:00Z"
  },
  "message": "User created successfully"
}
```

---

## Service Endpoints

### 1. Get All Services

- **Endpoint:** `GET /api/services`
- **Auth:** Not required
- **Description:** Retrieves a paginated list of all available services. Supports filtering.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | string | Filter by category (e.g. `devops`, `webdev`) |
| `minPrice` | number | Minimum price filter |
| `maxPrice` | number | Maximum price filter |
| `search` | string | Full-text search on title/description |

**Request:**
```http
GET /api/services?category=devops&minPrice=100&maxPrice=500
```

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "svc_01HDEF789",
        "providerId": "usr_01HXYZ123",
        "title": "AWS Infrastructure Setup",
        "description": "Full VPC, EC2, RDS setup with Terraform.",
        "category": "devops",
        "price": 350,
        "currency": "USD",
        "rating": 4.8,
        "createdAt": "2024-02-10T12:00:00Z"
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 5, "totalPages": 1 }
  }
}
```

---

### 2. Get Service by ID

- **Endpoint:** `GET /api/services/{id}`
- **Auth:** Not required
- **Description:** Retrieves full details of a single service listing.

---

### 3. Create Service

- **Endpoint:** `POST /api/services`
- **Auth:** Required (provider only)
- **Description:** Creates a new service listing.

**Request:**
```http
POST /api/services
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "CI/CD Pipeline Setup",
  "description": "Full GitHub Actions or GitLab CI setup with deployment automation.",
  "category": "devops",
  "price": 200,
  "currency": "USD",
  "deliveryDays": 5
}
```

**Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "svc_01HGHI012",
    "providerId": "usr_01HXYZ123",
    "title": "CI/CD Pipeline Setup",
    "category": "devops",
    "price": 200,
    "currency": "USD",
    "createdAt": "2024-06-01T11:00:00Z"
  }
}
```

---

## Project Endpoints

### 1. Get All Projects

- **Endpoint:** `GET /api/projects`
- **Auth:** Required
- **Description:** Retrieves projects belonging to the authenticated user.

---

### 2. Get Project by ID

- **Endpoint:** `GET /api/projects/{id}`
- **Auth:** Required
- **Description:** Retrieves a single project by its ID.

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "id": "prj_01HJKL345",
    "clientId": "usr_01HABC456",
    "title": "E-commerce Platform Build",
    "description": "Need a full-stack e-commerce site with Stripe payments.",
    "status": "in_progress",
    "budget": 2500,
    "currency": "USD",
    "createdAt": "2024-05-20T08:00:00Z"
  }
}
```

---

### 3. Create Project

- **Endpoint:** `POST /api/projects`
- **Auth:** Required (client only)
- **Description:** Creates a new project request.

**Request:**
```http
POST /api/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "E-commerce Platform Build",
  "description": "Need a full-stack e-commerce site with Stripe payments.",
  "budget": 2500,
  "currency": "USD",
  "deadline": "2024-08-01"
}
```

---

## Proposal Endpoints

### 1. Get All Proposals

- **Endpoint:** `GET /api/proposals`
- **Auth:** Required
- **Description:** Retrieves proposals associated with the authenticated user.

---

### 2. Get Proposal by ID

- **Endpoint:** `GET /api/proposals/{id}`
- **Auth:** Required
- **Description:** Retrieves a single proposal by its ID.

---

### 3. Create Proposal

- **Endpoint:** `POST /api/proposals`
- **Auth:** Required (provider only)
- **Description:** Submits a proposal for a project.

**Request:**
```http
POST /api/proposals
Authorization: Bearer <token>
Content-Type: application/json

{
  "projectId": "prj_01HJKL345",
  "content": "I can deliver this in 4 weeks using React, Node.js, and PostgreSQL.",
  "price": 2200,
  "currency": "USD",
  "deliveryDays": 28
}
```

**Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "prp_01HMNO678",
    "projectId": "prj_01HJKL345",
    "providerId": "usr_01HXYZ123",
    "content": "I can deliver this in 4 weeks using React, Node.js, and PostgreSQL.",
    "price": 2200,
    "currency": "USD",
    "status": "pending",
    "createdAt": "2024-05-21T09:00:00Z"
  }
}
```

---

## Payment Endpoints

### 1. Get All Payments

- **Endpoint:** `GET /api/payments`
- **Auth:** Required
- **Description:** Retrieves a list of all payments for the authenticated user.

---

### 2. Get Payment by ID

- **Endpoint:** `GET /api/payments/{id}`
- **Auth:** Required
- **Description:** Retrieves a single payment by its ID.

---

### 3. Create Payment

- **Endpoint:** `POST /api/payments`
- **Auth:** Required (client only)
- **Description:** Records a new payment for a project milestone.

**Request:**
```http
POST /api/payments
Authorization: Bearer <token>
Content-Type: application/json

{
  "projectId": "prj_01HJKL345",
  "amount": 1100,
  "currency": "USD",
  "paymentMethod": "stripe",
  "description": "Milestone 1: Frontend complete"
}
```

**Response `201 Created`:**
```json
{
  "success": true,
  "data": {
    "id": "pay_01HPQR901",
    "projectId": "prj_01HJKL345",
    "amount": 1100,
    "currency": "USD",
    "status": "pending",
    "checkoutUrl": "https://checkout.stripe.com/pay/cs_test_..."
  }
}
```

---

## AI Integration Endpoints

### 1. Get AI Predictions

- **Endpoint:** `GET /api/ai/predictions`
- **Auth:** Required
- **Description:** Retrieves AI-generated service or provider recommendations based on user activity.

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "serviceId": "svc_01HDEF789",
        "score": 0.94,
        "reason": "Matches your recent cloud infrastructure projects"
      }
    ]
  }
}
```

---

### 2. Generate AI Proposal

- **Endpoint:** `POST /api/ai/proposals/generate`
- **Auth:** Required
- **Description:** Uses AI to auto-generate a proposal draft for a given project.

**Request:**
```http
POST /api/ai/proposals/generate
Authorization: Bearer <token>
Content-Type: application/json

{
  "projectId": "prj_01HJKL345"
}
```

**Response `200 OK`:**
```json
{
  "success": true,
  "data": {
    "draft": "Based on your project requirements, I propose to build...",
    "estimatedPrice": 2200,
    "estimatedDays": 28
  }
}
```

---

### 3. Submit Data for Training

- **Endpoint:** `POST /api/ai/train`
- **Auth:** Required (admin only)
- **Description:** Submits anonymized interaction data for model fine-tuning.

**Request:**
```http
POST /api/ai/train
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "datasetId": "ds_2024_q2",
  "type": "matching"
}
```

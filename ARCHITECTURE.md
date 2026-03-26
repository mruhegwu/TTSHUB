# System Architecture

This document provides an overview of the system architecture of the TTSHUB project.

## Overview

TTSHUB is a centralized digital service marketplace built on a modern, scalable full-stack architecture. The system separates concerns into three major tiers: a client-facing frontend, a RESTful backend API, and a persistent data layer — all enhanced with AI-powered services for automated matching and proposal generation.

```
┌─────────────────────────────────────────────────────────────┐
│                        Clients                              │
│            (Web Browser / Mobile App)                       │
└───────────────────────┬─────────────────────────────────────┘
                        │ HTTPS
┌───────────────────────▼─────────────────────────────────────┐
│                    Frontend Layer                           │
│              React / Vue.js SPA                             │
│    (Marketplace UI, Dashboard, Messaging, Payments)         │
└───────────────────────┬─────────────────────────────────────┘
                        │ REST / JSON
┌───────────────────────▼─────────────────────────────────────┐
│                    Backend API Layer                        │
│               Node.js / Python (FastAPI)                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────────┐  │
│  │  Users   │ │ Services │ │Projects  │ │  AI Services  │  │
│  │  Module  │ │  Module  │ │ Module   │ │    Module     │  │
│  └──────────┘ └──────────┘ └──────────┘ └───────────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │Proposals │ │ Payments │ │Messaging │                     │
│  │  Module  │ │  Module  │ │  Module  │                     │
│  └──────────┘ └──────────┘ └──────────┘                     │
└───────┬───────────────────────────────┬─────────────────────┘
        │ SQL / ORM                     │ HTTP
┌───────▼──────────┐         ┌──────────▼──────────────────────┐
│   Database Layer │         │     External Services           │
│   PostgreSQL     │         │  ┌──────────┐  ┌─────────────┐  │
│  (Primary Store) │         │  │  OpenAI  │  │  Anthropic  │  │
│                  │         │  │   API    │  │     API     │  │
│   Redis Cache    │         │  └──────────┘  └─────────────┘  │
│  (Sessions &     │         │  ┌──────────┐  ┌─────────────┐  │
│   Rate Limiting) │         │  │ Stripe / │  │  SendGrid / │  │
└──────────────────┘         │  │ PayPal   │  │    Email    │  │
                             │  └──────────┘  └─────────────┘  │
                             └────────────────────────────────-─┘
```

## Components

### 1. Frontend Layer

**Technology:** React.js (primary) with optional Vue.js support  
**Responsibilities:**
- Render the marketplace UI, user dashboards, and project views
- Handle authentication flows (JWT-based sessions)
- Provide real-time messaging via WebSocket connections
- Display AI-generated proposals and matching results

**Key Pages/Views:**
- `/` — Landing page with service categories
- `/services` — Browseable service marketplace
- `/dashboard` — User-specific dashboard (client or provider)
- `/projects` — Active and past project management
- `/messages` — Real-time messaging interface

---

### 2. Backend API Layer

**Technology:** Node.js (Express) or Python (FastAPI)  
**Style:** RESTful JSON API  
**Authentication:** JWT tokens with refresh-token rotation

The backend is organized into feature modules:

| Module | Responsibilities |
|--------|-----------------|
| **Users** | Registration, authentication, profile management |
| **Services** | Service listings, categories, search/filter |
| **Projects** | Project creation, status tracking, milestone management |
| **Proposals** | AI-assisted proposal generation, bidding system |
| **Payments** | Stripe/PayPal integration, escrow, invoicing |
| **Messaging** | Real-time chat via WebSocket |
| **AI Services** | OpenAI/Anthropic integrations, model inference |

---

### 3. Database Layer

**Primary Database:** PostgreSQL  
- Stores users, services, projects, proposals, payments, and messages
- Uses database migrations (Alembic for Python / Knex for Node.js)

**Cache Layer:** Redis  
- Session storage
- Rate limiting counters
- Short-lived AI response caching

**Schema Overview (Core Tables):**
```
users          — id, name, email, role (client | provider), created_at
services       — id, provider_id, title, description, price, category
projects       — id, client_id, title, status, budget, created_at
proposals      — id, project_id, provider_id, content, price, status
payments       — id, project_id, amount, status, payment_method, created_at
messages       — id, sender_id, receiver_id, content, timestamp
```

---

### 4. AI Services Module

**Integrations:** OpenAI API, Anthropic Claude API, custom ML models

**Capabilities:**
- **Proposal Generation** — Automatically draft project proposals based on client requirements
- **Freelancer Matching** — Score and rank service providers for a given project
- **Automated Troubleshooting** — AI-assisted support ticket resolution
- **Code/Template Generation** — Generate infrastructure templates and boilerplate code

---

### 5. External Services

| Service | Purpose |
|---------|---------|
| **Stripe / PayPal** | Payment processing and escrow |
| **SendGrid / SES** | Transactional email notifications |
| **AWS S3 / GCS** | File and asset storage |
| **OpenAI** | GPT-based proposal generation and chat |
| **Anthropic** | Claude-based AI matching and summarization |

---

## Communication

| Interaction | Protocol |
|-------------|----------|
| Frontend ↔ Backend | HTTPS REST (JSON) |
| Backend ↔ Frontend (real-time) | WebSocket (Socket.io / native WS) |
| Backend ↔ PostgreSQL | TCP via ORM (SQLAlchemy / Sequelize) |
| Backend ↔ Redis | TCP (ioredis / redis-py) |
| Backend ↔ External APIs | HTTPS REST |

All API responses follow a consistent envelope:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional human-readable message",
  "errors": []
}
```

---

## Deployment

### Cloud Infrastructure (AWS / GCP)

```
┌─────────────────────────────────────────────┐
│              Cloud Provider (AWS/GCP)        │
│                                             │
│  ┌──────────────┐    ┌─────────────────┐    │
│  │  CDN / Load  │    │   App Servers   │    │
│  │  Balancer    │───▶│  (EC2 / Cloud   │    │
│  │  (CloudFront │    │   Run / ECS)    │    │
│  │  / Cloud LB) │    └────────┬────────┘    │
│  └──────────────┘             │             │
│                       ┌───────▼───────┐     │
│                       │  PostgreSQL   │     │
│                       │  (RDS / Cloud │     │
│                       │   SQL)        │     │
│                       └───────────────┘     │
│                       ┌───────────────┐     │
│                       │  Redis Cache  │     │
│                       │  (ElastiCache │     │
│                       │  / Memorystore│     │
│                       └───────────────┘     │
└─────────────────────────────────────────────┘
```

### CI/CD Pipeline

1. **Code Push** → GitHub repository
2. **GitHub Actions** → Run linters, unit tests, integration tests
3. **Build** → Docker image built and pushed to container registry
4. **Deploy** → Rolling deployment to staging, then production

### Environment Tiers

| Environment | Purpose |
|-------------|---------|
| `development` | Local developer machines |
| `staging` | Pre-production testing, mirrors production |
| `production` | Live, customer-facing environment |

---

## Security Considerations

- All API endpoints require authentication except public listing endpoints
- Passwords are hashed with bcrypt (cost factor ≥ 12)
- JWT access tokens expire in 15 minutes; refresh tokens in 7 days
- Rate limiting applied on all auth endpoints (Redis-backed)
- Input validation on all user-supplied data
- PostgreSQL connections use SSL in staging and production
- Secrets managed via environment variables (never committed to source control)
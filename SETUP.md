# Installation and Setup Instructions for TTSHUB

## Prerequisites

Before setting up TTSHUB, ensure you have the following installed:

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | ≥ 18.x | [Download](https://nodejs.org/) |
| Python | ≥ 3.10 | [Download](https://python.org/) |
| PostgreSQL | ≥ 14 | [Download](https://postgresql.org/) |
| Redis | ≥ 7 | [Download](https://redis.io/) |
| Git | latest | [Download](https://git-scm.com/) |
| Docker (optional) | latest | For containerized setup |

---

## Quick Start (Docker — Recommended)

The fastest way to get up and running with all services:

```bash
# 1. Clone the repository
git clone https://github.com/mruhegwu/TTSHUB.git
cd TTSHUB

# 2. Copy environment variables
cp .env.example .env

# 3. Start all services with Docker Compose
docker compose up --build
```

The application will be available at `http://localhost:3000`.

---

## Manual Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mruhegwu/TTSHUB.git
cd TTSHUB
```

### 2. Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Open `.env` and configure the required variables (see `.env.example` for all available options). At minimum you need to set:

- `DATABASE_URL` — PostgreSQL connection string
- `REDIS_URL` — Redis connection string
- `JWT_SECRET` — A strong random secret for token signing
- `OPENAI_API_KEY` — Your OpenAI API key (for AI features)

### 3. Backend Setup (Node.js)

```bash
# Install dependencies
npm install

# Run database migrations
npm run db:migrate

# Seed the database with sample data (optional, development only)
npm run db:seed
```

### 4. Backend Setup (Python — Alternative)

```bash
# Create a virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run database migrations
alembic upgrade head

# Seed the database (optional)
python scripts/seed.py
```

### 5. Start the Development Server

**Node.js:**
```bash
npm run dev
```

**Python:**
```bash
uvicorn src.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000` (Python) or `http://localhost:3000` (Node.js).

---

## Running Tests

```bash
# Node.js tests
npm test

# Node.js tests in watch mode
npm run test:watch

# Python tests
pytest

# Python tests with coverage
pytest --cov=src --cov-report=html
```

---

## Linting and Formatting

```bash
# JavaScript/TypeScript
npm run lint
npm run format

# Python
flake8 src/
black src/
isort src/
```

---

## Environment Variable Reference

See `.env.example` for the full list. Below are the key variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | ✅ | PostgreSQL connection URI |
| `REDIS_URL` | ✅ | Redis connection URI |
| `JWT_SECRET` | ✅ | Secret key for JWT signing (min 32 chars) |
| `OPENAI_API_KEY` | ✅ (AI features) | OpenAI API key |
| `ANTHROPIC_API_KEY` | ✅ (AI features) | Anthropic API key |
| `STRIPE_SECRET_KEY` | ✅ (Payments) | Stripe secret key |
| `SMTP_HOST` | ✅ (Email) | SMTP server hostname |
| `PORT` | Optional | Server port (default: 3000) |
| `NODE_ENV` | Optional | `development` / `staging` / `production` |

---

## Troubleshooting

### PostgreSQL connection refused

Ensure PostgreSQL is running:
```bash
# macOS (Homebrew)
brew services start postgresql

# Linux (systemd)
sudo systemctl start postgresql
```

### Redis connection refused

Ensure Redis is running:
```bash
# macOS (Homebrew)
brew services start redis

# Linux (systemd)
sudo systemctl start redis
```

### Port already in use

Change the port in your `.env` file:
```
PORT=3001
```

### Module not found errors (Node.js)

Delete `node_modules` and reinstall:
```bash
rm -rf node_modules
npm install
```

### Virtual environment issues (Python)

Recreate the virtual environment:
```bash
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## Additional Resources

- [API Documentation](API.md)
- [Architecture Overview](ARCHITECTURE.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Project Structure](PROJECT_STRUCTURE.md)
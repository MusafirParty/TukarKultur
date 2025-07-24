# TukarKultur Backend API

A comprehensive backend system for a cultural exchange and meetup application built with Go, Gin framework, PostgreSQL, and integrated AI services.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Getting Started](#getting-started)
- [Database Schema](#database-schema)
- [API Endpoints](#api-endpoints)
- [Authentication](#authentication)
- [WebSocket Chat](#websocket-chat)
- [AI Integration](#ai-integration)
- [Environment Variables](#environment-variables)
- [Testing](#testing)
- [Deployment](#deployment)

## Overview

TukarKultur is a location-based cultural exchange platform that allows users to:
- Connect with people from different cultural backgrounds
- Organize and participate in cultural meetups
- Share experiences through ratings and reviews
- Chat in real-time to coordinate meetings
- Get AI-powered cultural insights and recommendations

## Architecture

The backend follows a clean, layered architecture:

```
BE/server/
├── main.go                 # Application entry point
├── database/              # Database connection
├── models/                # Data structures and DTOs
├── repository/            # Data access layer
├── handlers/              # HTTP request handlers
├── routes/                # Route definitions
├── services/              # Business logic and AI services
└── chat_socket/           # WebSocket implementation
```

### Components:

- **Models**: Define data structures for all entities (User, Meetup, Friend, etc.)
- **Repository**: Handle database operations with clean interfaces
- **Handlers**: Process HTTP requests and responses
- **Services**: Implement business logic and external API integrations
- **Routes**: Define API endpoints and middleware

## Technologies

- **Framework**: Go with Gin HTTP web framework
- **Database**: PostgreSQL with SQL driver
- **Authentication**: JWT-like token-based authentication
- **WebSocket**: Real-time chat using Gorilla WebSocket
- **AI Integration**: Gemini AI and OpenAI APIs
- **Password Hashing**: bcrypt
- **CORS**: Cross-origin resource sharing enabled

## Getting Started

### Prerequisites

- Go 1.19+ installed
- PostgreSQL database
- Environment variables configured

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd TukarKultur/BE/server
```

2. Install dependencies:
```bash
go mod tidy
```

3. Set up environment variables (create `.env` file):
```bash
DATABASE_URL=postgresql://username:password@localhost/tukarkultur_db
PORT=8080
GEMINI_API_KEY=your_gemini_api_key
OPENAI_API_KEY=your_openai_api_key
```

4. Run database migrations:
```bash
psql -d tukarkultur_db -f ../schema.sql
```

5. Start the server:
```bash
go run server.go
```

The server will start on `http://localhost:8080`

### Health Check

Test if the server is running:
```bash
curl http://localhost:8080/api/v1/health
```

## Database Schema

### Core Tables

#### Users
Stores user profiles and location data:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    profile_picture_url TEXT,
    bio TEXT,
    age INT,
    city VARCHAR(100),
    country VARCHAR(100),
    interests TEXT[],
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location_updated_at TIMESTAMP WITH TIME ZONE,
    total_interactions INT DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### Friends
Manages user connections:
```sql
CREATE TABLE friends (
    user_id_1 UUID REFERENCES users(id),
    user_id_2 UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_id_1, user_id_2)
);
```

#### Meetups
Stores meetup proposals and details:
```sql
CREATE TABLE meetups (
    id UUID PRIMARY KEY,
    proposed_by UUID REFERENCES users(id),
    proposed_to UUID REFERENCES users(id),
    location_name VARCHAR(255),
    location_address TEXT,
    meetup_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'proposed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### Interactions
Post-meetup reviews and ratings:
```sql
CREATE TABLE interactions (
    id UUID PRIMARY KEY,
    meetup_id UUID REFERENCES meetups(id),
    reviewer_id UUID REFERENCES users(id),
    reviewed_user_id UUID REFERENCES users(id),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    meetup_photo_url TEXT,
    meetup_photo_public_id VARCHAR(255),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### Auth Sessions
Manages user authentication tokens:
```sql
CREATE TABLE auth_sessions (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints

### Base URL: `/api/v1`

### Authentication Endpoints

#### Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "bio": "Love exploring different cultures",
  "age": 25,
  "city": "Jakarta",
  "country": "Indonesia",
  "interests": ["food", "music", "history"]
}
```

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer <token>
```

### User Management

#### Get All Users
```http
GET /api/v1/users
```

#### Get User by ID
```http
GET /api/v1/users/{id}
```

#### Update User
```http
PUT /api/v1/users/{id}
Content-Type: application/json

{
  "bio": "Updated bio",
  "city": "Bandung",
  "interests": ["art", "music"]
}
```

#### Delete User
```http
DELETE /api/v1/users/{id}
```

### Friend Management

#### Add Friend
```http
POST /api/v1/friends
Content-Type: application/json

{
  "user_id_1": "uuid1",
  "user_id_2": "uuid2"
}
```

#### Get User's Friends
```http
GET /api/v1/friends/user/{id}?include_details=true
```

#### Remove Friend
```http
DELETE /api/v1/friends
Content-Type: application/json

{
  "user_id_1": "uuid1",
  "user_id_2": "uuid2"
}
```

### Meetup Management

#### Create Meetup
```http
POST /api/v1/meetups
Content-Type: application/json

{
  "proposed_by": "uuid1",
  "proposed_to": "uuid2",
  "location_name": "Central Park Cafe",
  "location_address": "123 Main Street, Jakarta",
  "meetup_time": "2024-02-15T15:00:00Z"
}
```

#### Get All Meetups
```http
GET /api/v1/meetups?include_details=true&status=proposed
```

#### Get Meetup by ID
```http
GET /api/v1/meetups/{id}
```

#### Update Meetup
```http
PUT /api/v1/meetups/{id}
Content-Type: application/json

{
  "location_name": "Updated Location",
  "meetup_time": "2024-02-16T15:00:00Z"
}
```

#### Confirm Meetup
```http
PUT /api/v1/meetups/{id}/confirm
```

#### Complete Meetup
```http
PUT /api/v1/meetups/{id}/complete
```

### Interaction Management

#### Create Review/Rating
```http
POST /api/v1/interactions
Content-Type: application/json

{
  "meetup_id": "meetup_uuid",
  "reviewer_id": "reviewer_uuid",
  "reviewed_user_id": "reviewed_uuid",
  "rating": 5,
  "review_text": "Great cultural exchange experience!",
  "meetup_photo_url": "https://cloudinary.com/photo.jpg"
}
```

#### Get All Interactions
```http
GET /api/v1/interactions
```

#### Get Interaction by ID
```http
GET /api/v1/interactions/{id}
```

### AI Integration Endpoints

#### Gemini Text Generation
```http
POST /api/v1/gemini/generate
Content-Type: application/json

{
  "prompt": "Tell me about Indonesian traditional dance",
  "context": "Cultural learning platform",
  "user_id": "user123"
}
```

#### Gemini Chat
```http
POST /api/v1/gemini/chat
Content-Type: application/json

{
  "messages": [
    {
      "role": "user",
      "content": "What should I know about Japanese tea ceremony?"
    }
  ],
  "user_id": "user123"
}
```

#### OpenAI Endpoints
Similar structure available at:
- `POST /api/v1/openai/generate`
- `POST /api/v1/openai/chat`
- `GET /api/v1/openai/models`

## Authentication

The API uses token-based authentication:

1. **Register** or **Login** to receive a token
2. Include token in `Authorization` header: `Bearer <token>`
3. Tokens expire after 24 hours
4. Passwords are hashed using bcrypt

### Protected Routes
Most endpoints require authentication. Public endpoints:
- `POST /auth/register`
- `POST /auth/login`
- `GET /health`

## WebSocket Chat

Real-time chat functionality for coordinating meetups.

### Connection
```javascript
const ws = new WebSocket('ws://localhost:8080/api/v1/chat?id=user_id');
```

### Message Format
```json
{
  "sender": "sender_user_id",
  "receiver": "receiver_user_id",
  "text": "Hello! Ready for our meetup?",
  "image_url": "optional_image_url"
}
```

### Features
- Real-time messaging between users
- Image sharing support
- Connection management per user ID
- Message broadcasting to intended recipients

## AI Integration

### Supported Providers

#### 1. Gemini AI (Google)
- **Endpoints**: `/api/v1/gemini/*`
- **Models**: Flash (fast), Pro (advanced)
- **Features**: Text generation, chat conversations
- **Use Cases**: Cultural information, travel advice

#### 2. OpenAI (ChatGPT)
- **Endpoints**: `/api/v1/openai/*`
- **Models**: GPT-3.5 Turbo, GPT-4
- **Features**: Text completion, chat with system prompts
- **Use Cases**: Conversation assistance, content generation

### AI Service Features
- Cultural information and advice
- Travel recommendations
- Language learning support
- Meetup activity suggestions
- Cross-cultural communication tips

## Environment Variables

Create a `.env` file in the server directory:

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/tukarkultur_db

# Server
PORT=8080

# AI APIs (Optional)
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# CORS (Optional)
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

## Testing

### Manual Testing with cURL

Health check:
```bash
curl http://localhost:8080/api/v1/health
```

Register user:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User"
  }'
```

Login:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### AI API Testing

Test Gemini:
```bash
curl -X POST http://localhost:8080/api/v1/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Tell me about Balinese culture",
    "context": "Cultural learning"
  }'
```

### Running Tests
```bash
go test ./...
```

## Deployment

### Production Setup

1. **Environment Configuration**:
   - Set production database URL
   - Configure proper CORS origins
   - Set secure token secrets

2. **Database Migration**:
   ```bash
   psql -d production_db -f schema.sql
   ```

3. **Build and Run**:
   ```bash
   go build -o tukarkultur-server server.go
   ./tukarkultur-server
   ```

### Docker Deployment (Optional)

Create `Dockerfile`:
```dockerfile
FROM golang:1.19-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod tidy && go build -o server server.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .
CMD ["./server"]
```

### Performance Considerations

- Use connection pooling for database
- Implement rate limiting for AI APIs
- Add caching for frequently accessed data
- Monitor database query performance
- Implement proper logging and monitoring

## Error Handling

The API returns consistent error responses:

```json
{
  "error": "Error description",
  "code": "ERROR_CODE",
  "details": "Additional details if available"
}
```

### Common HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

## Contributing

1. Follow Go conventions and best practices
2. Add tests for new features
3. Update documentation for API changes
4. Use meaningful commit messages
5. Ensure proper error handling

## License

[Add your license information here]

---

For more detailed API documentation and examples, refer to:
- `AI_API_DOCS.md` - Comprehensive AI integration guide
- `CURL_TESTS.md` - Complete cURL testing commands
- `GEMINI_README.md` - Gemini AI specific documentation
# TukarKultur

# TukarKultur API Documentation

## Overview

TukarKultur is a cultural exchange platform with a comprehensive REST API built with Go and Gin framework. The API provides endpoints for user management, cultural meetups, AI-powered assistance, chat functionality, and file uploads.

**Base URL:** `http://localhost:8080`

## Authentication

Most endpoints require authentication. Include the authorization token in the header:
```
Authorization: Bearer <your-token>
```

## Endpoint Categories

- [Health Check](#health-check)
- [Authentication](#authentication-endpoints)
- [User Management](#user-management)
- [Friends](#friends-management)
- [Meetups](#meetups-management)
- [Interactions](#interactions-management)
- [AI Services](#ai-services)
- [File Upload](#file-upload)
- [Chat](#chat)

---

## Health Check

### Get Server Health
Check if the server is running.

**Endpoint:** `GET /api/v1/health`

**Response:**
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

**Example:**
```bash
curl -X GET http://localhost:8080/api/v1/health
```

---

## Authentication Endpoints

### Register User
Register a new user account.

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword123",
  "full_name": "John Doe",
  "bio": "Cultural enthusiast",
  "age": 25,
  "city": "Jakarta",
  "country": "Indonesia",
  "interests": ["cooking", "music", "art"]
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "user_id": "uuid-here",
  "token": "jwt-token-here"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "securepassword123",
    "full_name": "John Doe",
    "bio": "Cultural enthusiast",
    "age": 25,
    "city": "Jakarta",
    "country": "Indonesia",
    "interests": ["cooking", "music", "art"]
  }'
```

### Login User
Authenticate user and get access token.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "username": "johndoe",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "jwt-token-here",
  "user": {
    "id": "uuid-here",
    "username": "johndoe",
    "email": "john@example.com"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "password": "securepassword123"
  }'
```

### Logout User
Logout user and invalidate token.

**Endpoint:** `POST /api/v1/auth/logout`

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Logout successful"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/logout \
  -H "Authorization: Bearer <your-token>"
```

---

## User Management

### Create User
Create a new user profile.

**Endpoint:** `POST /api/v1/users`

**Request Body:**
```json
{
  "username": "jane_doe",
  "email": "jane@example.com",
  "password": "password123",
  "full_name": "Jane Doe",
  "bio": "Travel enthusiast",
  "age": 28,
  "city": "Bali",
  "country": "Indonesia",
  "interests": ["photography", "culture", "food"]
}
```

**Response:**
```json
{
  "id": "uuid-here",
  "username": "jane_doe",
  "email": "jane@example.com",
  "full_name": "Jane Doe",
  "bio": "Travel enthusiast",
  "age": 28,
  "city": "Bali",
  "country": "Indonesia",
  "interests": ["photography", "culture", "food"],
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Get User by ID
Retrieve user information by ID.

**Endpoint:** `GET /api/v1/users/{id}`

**Response:**
```json
{
  "id": "uuid-here",
  "username": "jane_doe",
  "email": "jane@example.com",
  "full_name": "Jane Doe",
  "bio": "Travel enthusiast",
  "age": 28,
  "city": "Bali",
  "country": "Indonesia",
  "interests": ["photography", "culture", "food"]
}
```

**Example:**
```bash
curl -X GET http://localhost:8080/api/v1/users/uuid-here
```

### Get All Users
Retrieve all users with optional filtering.

**Endpoint:** `GET /api/v1/users`

**Query Parameters:**
- `city` (optional): Filter by city
- `country` (optional): Filter by country
- `age_min` (optional): Minimum age
- `age_max` (optional): Maximum age

**Response:**
```json
{
  "users": [
    {
      "id": "uuid-1",
      "username": "user1",
      "full_name": "User One",
      "city": "Jakarta",
      "country": "Indonesia"
    },
    {
      "id": "uuid-2",
      "username": "user2",
      "full_name": "User Two",
      "city": "Bali",
      "country": "Indonesia"
    }
  ]
}
```

**Example:**
```bash
curl -X GET "http://localhost:8080/api/v1/users?city=Jakarta&country=Indonesia"
```

### Update User
Update user profile information.

**Endpoint:** `PUT /api/v1/users/{id}`

**Request Body:**
```json
{
  "full_name": "Updated Name",
  "bio": "Updated bio",
  "age": 30,
  "city": "Yogyakarta",
  "interests": ["art", "history", "culture"]
}
```

**Example:**
```bash
curl -X PUT http://localhost:8080/api/v1/users/uuid-here \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Updated Name",
    "bio": "Updated bio",
    "city": "Yogyakarta"
  }'
```

### Delete User
Delete a user account.

**Endpoint:** `DELETE /api/v1/users/{id}`

**Response:**
```json
{
  "message": "User deleted successfully"
}
```

---

## Friends Management

### Add Friend
Send or accept a friend request.

**Endpoint:** `POST /api/v1/friends`

**Request Body:**
```json
{
  "user_id": "uuid-user1",
  "friend_id": "uuid-user2"
}
```

**Response:**
```json
{
  "id": "friendship-uuid",
  "user_id": "uuid-user1",
  "friend_id": "uuid-user2",
  "status": "pending",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/friends \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "uuid-user1",
    "friend_id": "uuid-user2"
  }'
```

### Get All Friends
Get all friendship relationships.

**Endpoint:** `GET /api/v1/friends`

**Response:**
```json
{
  "friendships": [
    {
      "id": "friendship-uuid",
      "user_id": "uuid-user1",
      "friend_id": "uuid-user2",
      "status": "accepted"
    }
  ]
}
```

### Get Friends by User ID
Get all friends for a specific user.

**Endpoint:** `GET /api/v1/friends/user/{id}`

**Response:**
```json
{
  "friends": [
    {
      "id": "uuid-friend1",
      "username": "friend1",
      "full_name": "Friend One",
      "city": "Jakarta"
    }
  ]
}
```

### Remove Friend
Remove a friendship.

**Endpoint:** `DELETE /api/v1/friends`

**Request Body:**
```json
{
  "user_id": "uuid-user1",
  "friend_id": "uuid-user2"
}
```

---

## Meetups Management

### Create Meetup
Create a new cultural meetup event.

**Endpoint:** `POST /api/v1/meetups`

**Request Body:**
```json
{
  "title": "Indonesian Cooking Class",
  "description": "Learn to cook traditional Indonesian dishes",
  "location": "Jakarta Cultural Center",
  "datetime": "2024-02-15T14:00:00Z",
  "max_participants": 10,
  "organizer_id": "uuid-organizer",
  "category": "cooking",
  "requirements": ["Bring apron", "Basic cooking knowledge"],
  "latitude": -6.2088,
  "longitude": 106.8456
}
```

**Response:**
```json
{
  "id": "meetup-uuid",
  "title": "Indonesian Cooking Class",
  "description": "Learn to cook traditional Indonesian dishes",
  "location": "Jakarta Cultural Center",
  "datetime": "2024-02-15T14:00:00Z",
  "max_participants": 10,
  "organizer_id": "uuid-organizer",
  "status": "pending",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/meetups \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Indonesian Cooking Class",
    "description": "Learn to cook traditional Indonesian dishes",
    "location": "Jakarta Cultural Center",
    "datetime": "2024-02-15T14:00:00Z",
    "max_participants": 10,
    "organizer_id": "uuid-organizer"
  }'
```

### Get All Meetups
Retrieve all meetups with optional filtering.

**Endpoint:** `GET /api/v1/meetups`

**Query Parameters:**
- `include_details=true`: Include detailed user information
- `status`: Filter by status (pending, confirmed, completed, cancelled)

**Response:**
```json
{
  "meetups": [
    {
      "id": "meetup-uuid",
      "title": "Indonesian Cooking Class",
      "description": "Learn to cook traditional Indonesian dishes",
      "location": "Jakarta Cultural Center",
      "datetime": "2024-02-15T14:00:00Z",
      "status": "confirmed",
      "organizer": {
        "id": "uuid-organizer",
        "username": "chef_indo",
        "full_name": "Chef Indonesia"
      }
    }
  ]
}
```

**Examples:**
```bash
# Get all meetups
curl -X GET http://localhost:8080/api/v1/meetups

# Get meetups with detailed user info
curl -X GET "http://localhost:8080/api/v1/meetups?include_details=true"

# Get meetups by status
curl -X GET "http://localhost:8080/api/v1/meetups?status=confirmed"
```

### Get Meetup by ID
Get detailed information about a specific meetup.

**Endpoint:** `GET /api/v1/meetups/{id}`

**Response:**
```json
{
  "id": "meetup-uuid",
  "title": "Indonesian Cooking Class",
  "description": "Learn to cook traditional Indonesian dishes",
  "location": "Jakarta Cultural Center",
  "datetime": "2024-02-15T14:00:00Z",
  "max_participants": 10,
  "current_participants": 5,
  "organizer": {
    "id": "uuid-organizer",
    "username": "chef_indo",
    "full_name": "Chef Indonesia"
  },
  "participants": [
    {
      "id": "uuid-participant1",
      "username": "foodlover",
      "full_name": "Food Lover"
    }
  ]
}
```

### Get Meetups by User ID
Get all meetups organized by a specific user.

**Endpoint:** `GET /api/v1/meetups/user/{id}`

**Response:**
```json
{
  "meetups": [
    {
      "id": "meetup-uuid",
      "title": "Indonesian Cooking Class",
      "status": "confirmed",
      "datetime": "2024-02-15T14:00:00Z"
    }
  ]
}
```

### Update Meetup
Update meetup information.

**Endpoint:** `PUT /api/v1/meetups/{id}`

**Request Body:**
```json
{
  "title": "Updated Indonesian Cooking Class",
  "description": "Updated description",
  "max_participants": 15
}
```

### Confirm Meetup
Confirm a pending meetup.

**Endpoint:** `PUT /api/v1/meetups/{id}/confirm`

**Response:**
```json
{
  "message": "Meetup confirmed successfully",
  "meetup": {
    "id": "meetup-uuid",
    "status": "confirmed"
  }
}
```

### Complete Meetup
Mark a meetup as completed.

**Endpoint:** `PUT /api/v1/meetups/{id}/complete`

**Response:**
```json
{
  "message": "Meetup completed successfully",
  "meetup": {
    "id": "meetup-uuid",
    "status": "completed"
  }
}
```

### Delete Meetup
Cancel/delete a meetup.

**Endpoint:** `DELETE /api/v1/meetups/{id}`

**Response:**
```json
{
  "message": "Meetup deleted successfully"
}
```

---

## Interactions Management

### Create Interaction
Create a new interaction/review for a meetup.

**Endpoint:** `POST /api/v1/interactions`

**Request Body:**
```json
{
  "meetup_id": "meetup-uuid",
  "reviewer_id": "uuid-reviewer",
  "reviewee_id": "uuid-reviewee",
  "rating": 5,
  "comment": "Great cultural exchange experience!",
  "interaction_type": "review"
}
```

**Response:**
```json
{
  "id": "interaction-uuid",
  "meetup_id": "meetup-uuid",
  "reviewer_id": "uuid-reviewer",
  "reviewee_id": "uuid-reviewee",
  "rating": 5,
  "comment": "Great cultural exchange experience!",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Get All Interactions
Retrieve all interactions.

**Endpoint:** `GET /api/v1/interactions`

### Get Interaction by ID
Get specific interaction details.

**Endpoint:** `GET /api/v1/interactions/{id}`

### Get Interactions by Meetup ID
Get all interactions for a specific meetup.

**Endpoint:** `GET /api/v1/interactions/meetup/{id}`

### Get Interactions by User ID
Get all interactions involving a specific user.

**Endpoint:** `GET /api/v1/interactions/user/{id}`

### Get Reviews for User
Get all reviews received by a user.

**Endpoint:** `GET /api/v1/interactions/reviews/{id}`

**Response:**
```json
{
  "reviews": [
    {
      "id": "interaction-uuid",
      "rating": 5,
      "comment": "Excellent cultural guide!",
      "reviewer": {
        "username": "traveler123",
        "full_name": "John Traveler"
      },
      "meetup": {
        "title": "City Cultural Tour"
      }
    }
  ],
  "average_rating": 4.8,
  "total_reviews": 15
}
```

### Get User Rating Stats
Get statistical information about user ratings.

**Endpoint:** `GET /api/v1/interactions/stats/{id}`

**Response:**
```json
{
  "user_id": "uuid-user",
  "average_rating": 4.8,
  "total_reviews": 15,
  "rating_distribution": {
    "5": 10,
    "4": 3,
    "3": 2,
    "2": 0,
    "1": 0
  }
}
```

### Update Interaction
Update an existing interaction.

**Endpoint:** `PUT /api/v1/interactions/{id}`

### Delete Interaction
Delete an interaction.

**Endpoint:** `DELETE /api/v1/interactions/{id}`

---

## AI Services

The API provides two AI services: Gemini (Google) and OpenAI for cultural assistance and content generation.

### Gemini AI Endpoints

#### Gemini Health Check
**Endpoint:** `GET /api/v1/gemini/health`

**Response:**
```json
{
  "status": "ok",
  "service": "Gemini AI",
  "version": "1.0.0"
}
```

#### Get Gemini Models
**Endpoint:** `GET /api/v1/gemini/models`

**Response:**
```json
{
  "models": [
    {
      "id": "gemini-1.5-flash-latest",
      "name": "Gemini 1.5 Flash",
      "description": "Fast text generation model"
    },
    {
      "id": "gemini-1.5-pro-latest",
      "name": "Gemini 1.5 Pro",
      "description": "Advanced reasoning model"
    }
  ]
}
```

#### Gemini Text Generation
**Endpoint:** `POST /api/v1/gemini/generate`

**Request Body:**
```json
{
  "prompt": "Explain the cultural significance of Batik in Indonesian heritage",
  "context": "TukarKultur cultural education platform",
  "user_id": "uuid-user",
  "metadata": {
    "topic": "batik",
    "country": "Indonesia"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "response-uuid",
    "response": "Batik is a traditional Indonesian art form that holds deep cultural significance...",
    "prompt": "Explain the cultural significance of Batik in Indonesian heritage",
    "status": "completed",
    "model": "gemini-1.5-flash-latest",
    "usage": {
      "prompt_tokens": 25,
      "completion_tokens": 150,
      "total_tokens": 175
    }
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/gemini/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What are important cultural etiquette rules when visiting Bali?",
    "context": "Cultural exchange preparation"
  }'
```

#### Gemini Chat
**Endpoint:** `POST /api/v1/gemini/chat`

**Request Body:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "I want to learn about traditional Indonesian music. Where should I start?"
    }
  ],
  "context": "Cultural learning through TukarKultur",
  "user_id": "uuid-user"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "chat-uuid",
    "messages": [
      {
        "role": "user",
        "content": "I want to learn about traditional Indonesian music. Where should I start?"
      },
      {
        "role": "model",
        "content": "Traditional Indonesian music is incredibly diverse. I'd recommend starting with gamelan..."
      }
    ],
    "response": "Traditional Indonesian music is incredibly diverse. I'd recommend starting with gamelan...",
    "status": "completed"
  }
}
```

### OpenAI Endpoints

#### OpenAI Health Check
**Endpoint:** `GET /api/v1/openai/health`

#### Get OpenAI Models
**Endpoint:** `GET /api/v1/openai/models`

#### OpenAI Text Generation
**Endpoint:** `POST /api/v1/openai/generate`

**Request Body:**
```json
{
  "prompt": "Create a guide for Japanese tea ceremony etiquette",
  "model": "gpt-3.5-turbo-instruct",
  "max_tokens": 200,
  "temperature": 0.7,
  "context": "Cultural preparation guide",
  "user_id": "uuid-user"
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/openai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain Korean business card exchange etiquette",
    "model": "gpt-3.5-turbo-instruct",
    "max_tokens": 150
  }'
```

#### OpenAI Chat
**Endpoint:** `POST /api/v1/openai/chat`

**Request Body:**
```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a cultural exchange expert helping people understand different cultures."
    },
    {
      "role": "user",
      "content": "What should I know about dining etiquette in Thailand?"
    }
  ],
  "model": "gpt-3.5-turbo",
  "max_tokens": 200,
  "temperature": 0.8
}
```

---

## File Upload

### Upload Image
Upload an image file to Cloudinary.

**Endpoint:** `POST /api/v1/upload/image`

**Request:** Multipart form data
- `file`: Image file
- `folder` (optional): Cloudinary folder

**Response:**
```json
{
  "success": true,
  "data": {
    "public_id": "sample_image_id",
    "url": "https://res.cloudinary.com/demo/image/upload/sample_image_id",
    "secure_url": "https://res.cloudinary.com/demo/image/upload/sample_image_id",
    "width": 1024,
    "height": 768,
    "format": "jpg"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:8080/api/v1/upload/image \
  -F "file=@/path/to/your/image.jpg" \
  -F "folder=meetup_photos"
```

### Upload Profile Image
Upload a profile image (requires authentication).

**Endpoint:** `POST /api/v1/upload/profile-image`

**Headers:** `Authorization: Bearer <token>`

### Delete Image
Delete an image from Cloudinary.

**Endpoint:** `DELETE /api/v1/upload/image/{public_id}`

### Get Optimized Image URL
Get an optimized version of an uploaded image.

**Endpoint:** `GET /api/v1/upload/optimized-url/{public_id}`

**Query Parameters:**
- `width` (optional): Target width
- `height` (optional): Target height
- `quality` (optional): Image quality (1-100)

---

## Chat

### WebSocket Connection
Connect to real-time chat using WebSocket.

**Endpoint:** `GET /api/v1/chat`

This endpoint upgrades the HTTP connection to WebSocket for real-time messaging.

**Example (JavaScript):**
```javascript
const ws = new WebSocket('ws://localhost:8080/api/v1/chat');

ws.onopen = function(event) {
    console.log('Connected to chat');
};

ws.onmessage = function(event) {
    const message = JSON.parse(event.data);
    console.log('Received:', message);
};

ws.send(JSON.stringify({
    type: 'message',
    content: 'Hello from TukarKultur!',
    user_id: 'uuid-user',
    room_id: 'meetup-uuid'
}));
```

---

## Error Responses

All endpoints return consistent error formats:

**400 Bad Request:**
```json
{
  "error": "Validation failed",
  "details": "Email is required"
}
```

**401 Unauthorized:**
```json
{
  "error": "Unauthorized",
  "details": "Invalid or missing authentication token"
}
```

**404 Not Found:**
```json
{
  "error": "Resource not found",
  "details": "User with ID uuid-123 not found"
}
```

**500 Internal Server Error:**
```json
{
  "error": "Internal server error",
  "details": "Database connection failed"
}
```

---

## Rate Limiting

- AI endpoints have a 30-second timeout
- File upload endpoints have a 10MB size limit
- WebSocket connections are limited to 100 concurrent connections per IP

---

## Environment Variables

Required environment variables for the server:

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/tukarkultur

# Server
PORT=8080

# AI Services
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

---

## Testing

### Run All Tests
```bash
cd BE/server
./test_ai_apis.sh
```

### Quick Health Check
```bash
curl -X GET http://localhost:8080/api/v1/health
curl -X GET http://localhost:8080/api/v1/gemini/health
curl -X GET http://localhost:8080/api/v1/openai/health
```

### Test Authentication Flow
```bash
# Register
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'

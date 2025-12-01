# Forum API Documentation

## Base URL
```
http://127.0.0.1:5002/api/forum
```

## Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### Authentication

#### Register User
**POST** `/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "username": "john_farmer",
  "email": "john@example.com",
  "password": "securepassword123",
  "location": "Davao" (optional),
  "farmSize": "5 hectares" (optional),
  "bio": "Banana farmer for 10 years" (optional)
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "userId": "uuid-here",
    "username": "john_farmer",
    "email": "john@example.com",
    "location": "Davao",
    "farmSize": "5 hectares",
    "bio": "Banana farmer for 10 years",
    "role": "farmer",
    "reputation": 0,
    "createdAt": "2025-12-01T10:00:00",
    "updatedAt": "2025-12-01T10:00:00"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields or validation failed
- `409 Conflict` - Username or email already exists

---

#### Login
**POST** `/auth/login`

Login with username/email and password.

**Request Body:**
```json
{
  "username": "john_farmer",  // or email
  "password": "securepassword123"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { /* user object */ }
}
```

**Error Responses:**
- `400 Bad Request` - Missing fields
- `401 Unauthorized` - Invalid credentials

---

### Users

#### Get User Profile
**GET** `/users/{userId}`

Get user profile by ID. Authentication optional.

**Response:** `200 OK`
```json
{
  "success": true,
  "user": {
    "userId": "uuid-here",
    "username": "john_farmer",
    "email": "john@example.com",
    "profilePicture": "https://...",
    "location": "Davao",
    "farmSize": "5 hectares",
    "bio": "Banana farmer for 10 years",
    "role": "farmer",
    "reputation": 150,
    "createdAt": "2025-12-01T10:00:00",
    "updatedAt": "2025-12-01T10:00:00"
  }
}
```

**Error Responses:**
- `404 Not Found` - User not found

---

#### Update User Profile
**PUT** `/users/{userId}`

Update user profile. Requires authentication. Users can only update their own profile unless admin.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "username": "new_username" (optional),
  "location": "Manila" (optional),
  "farmSize": "10 hectares" (optional),
  "bio": "Updated bio" (optional),
  "profilePicture": "https://..." (optional)
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "User updated successfully",
  "user": { /* updated user object */ }
}
```

**Error Responses:**
- `400 Bad Request` - No valid fields to update
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Cannot update another user's profile
- `409 Conflict` - Username already taken

---

### Posts

#### Get Posts
**GET** `/posts`

Get list of posts with optional filtering. Authentication optional.

**Query Parameters:**
- `limit` (optional): Number of posts to return (default: 20, max: 100)
- `offset` (optional): Number of posts to skip (default: 0)
- `category` (optional): Filter by category (question, discussion, tip, problem)
- `authorId` (optional): Filter by author ID
- `deficiencyType` (optional): Filter by deficiency type

**Example:**
```
GET /posts?limit=10&category=question&offset=0
```

**Response:** `200 OK`
```json
{
  "success": true,
  "posts": [
    {
      "postId": "uuid-here",
      "authorId": "user-uuid",
      "title": "Yellow leaves on my banana plant",
      "content": "I noticed yellow leaves...",
      "category": "question",
      "images": ["https://..."],
      "deficiencyType": "nitrogen",
      "tags": ["yellowing", "nutrition"],
      "location": "Davao",
      "likes": 5,
      "views": 23,
      "commentCount": 3,
      "isPinned": false,
      "isSolved": false,
      "createdAt": "2025-12-01T10:00:00",
      "updatedAt": "2025-12-01T10:00:00"
    }
  ],
  "count": 1
}
```

---

#### Create Post
**POST** `/posts`

Create a new post. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "Yellow leaves on my banana plant",
  "content": "I noticed yellow leaves appearing on my banana plants...",
  "category": "question",
  "images": ["https://..."] (optional),
  "deficiencyType": "nitrogen" (optional),
  "tags": ["yellowing", "nutrition"] (optional),
  "location": "Davao" (optional)
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Post created successfully",
  "post": { /* post object */ }
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields or invalid category
- `401 Unauthorized` - Not authenticated

---

#### Get Single Post
**GET** `/posts/{postId}`

Get a single post by ID. Increments view count. Authentication optional.

**Response:** `200 OK`
```json
{
  "success": true,
  "post": { /* post object */ }
}
```

**Error Responses:**
- `404 Not Found` - Post not found

---

#### Update Post
**PUT** `/posts/{postId}`

Update a post. Requires authentication. Only author or admin can update.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "title": "Updated title" (optional),
  "content": "Updated content" (optional),
  "category": "discussion" (optional),
  "images": ["https://..."] (optional),
  "tags": ["new", "tags"] (optional),
  "deficiencyType": "potassium" (optional),
  "location": "Manila" (optional)
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Post updated successfully",
  "post": { /* updated post object */ }
}
```

**Error Responses:**
- `400 Bad Request` - No valid fields or invalid category
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not the author or admin
- `404 Not Found` - Post not found

---

#### Delete Post
**DELETE** `/posts/{postId}`

Delete a post. Requires authentication. Only author or admin can delete.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```

**Error Responses:**
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not the author or admin
- `404 Not Found` - Post not found

---

#### Mark Post as Solved
**POST** `/posts/{postId}/solve`

Mark a question post as solved. Requires authentication. Only author or admin.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Post marked as solved"
}
```

---

### Comments

#### Get Comments
**GET** `/posts/{postId}/comments`

Get all comments for a post. Authentication optional.

**Response:** `200 OK`
```json
{
  "success": true,
  "comments": [
    {
      "commentId": "uuid-here",
      "postId": "post-uuid",
      "authorId": "user-uuid",
      "content": "This looks like nitrogen deficiency...",
      "images": ["https://..."],
      "likes": 2,
      "isMarkedAsAnswer": false,
      "createdAt": "2025-12-01T10:00:00",
      "updatedAt": "2025-12-01T10:00:00"
    }
  ],
  "count": 1
}
```

---

#### Create Comment
**POST** `/posts/{postId}/comments`

Create a comment on a post. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "content": "This looks like nitrogen deficiency...",
  "images": ["https://..."] (optional)
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Comment created successfully",
  "comment": { /* comment object */ }
}
```

**Error Responses:**
- `400 Bad Request` - Missing content
- `401 Unauthorized` - Not authenticated
- `404 Not Found` - Post not found

---

#### Update Comment
**PUT** `/comments/{commentId}`

Update a comment. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "content": "Updated comment" (optional),
  "images": ["https://..."] (optional)
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Comment updated successfully"
}
```

---

#### Delete Comment
**DELETE** `/comments/{commentId}`

Delete a comment. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "postId": "post-uuid"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Comment deleted successfully"
}
```

---

### Likes

#### Like/Unlike Post
**POST** `/posts/{postId}/like`

Toggle like on a post. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Post liked",  // or "Post unliked"
  "liked": true  // or false
}
```

---

#### Like/Unlike Comment
**POST** `/comments/{commentId}/like`

Toggle like on a comment. Requires authentication.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Comment liked",  // or "Comment unliked"
  "liked": true  // or false
}
```

---

### Search

#### Search Posts
**GET** `/search`

Search posts by title or content. Authentication optional.

**Query Parameters:**
- `q` (required): Search query
- `limit` (optional): Max results (default: 20, max: 100)

**Example:**
```
GET /search?q=yellow%20leaves&limit=10
```

**Response:** `200 OK`
```json
{
  "success": true,
  "posts": [ /* array of matching posts */ ],
  "count": 5
}
```

**Error Responses:**
- `400 Bad Request` - Missing search query

---

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error message description"
}
```

Common HTTP status codes:
- `400 Bad Request` - Invalid input or missing required fields
- `401 Unauthorized` - Authentication required or invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists (e.g., duplicate username)
- `500 Internal Server Error` - Server error

---

## Rate Limiting

The API implements rate limiting:
- **200 requests per day**
- **50 requests per hour**

Exceeding these limits will result in a `429 Too Many Requests` response.

---

## Testing with cURL

### Register
```bash
curl -X POST http://127.0.0.1:5002/api/forum/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_farmer",
    "email": "john@example.com",
    "password": "password123",
    "location": "Davao"
  }'
```

### Login
```bash
curl -X POST http://127.0.0.1:5002/api/forum/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_farmer",
    "password": "password123"
  }'
```

### Create Post (with token)
```bash
curl -X POST http://127.0.0.1:5002/api/forum/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Yellow leaves problem",
    "content": "I have yellow leaves on my banana plants",
    "category": "question"
  }'
```

### Get Posts
```bash
curl http://127.0.0.1:5002/api/forum/posts?limit=10&category=question
```

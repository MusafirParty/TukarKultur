package handlers

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "golang.org/x/crypto/bcrypt"
    "your-project/models"
    "your-project/repository"
)

type UserHandler struct {
    userRepo *repository.UserRepository
}

func NewUserHandler(userRepo *repository.UserRepository) *UserHandler {
    return &UserHandler{userRepo: userRepo}
}

// POST /users
func (h *UserHandler) CreateUser(c *gin.Context) {
    var req models.CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Hash password
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
        return
    }

    user := &models.User{
        Username:          req.Username,
        Email:             req.Email,
        PasswordHash:      string(hashedPassword),
        FullName:          req.FullName,
        Bio:               req.Bio,
        Age:               req.Age,
        City:              req.City,
        Country:           req.Country,
        Interests:         req.Interests,
    }

    if err := h.userRepo.Create(user); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
        return
    }

    // Remove password hash from response
    user.PasswordHash = ""
    c.JSON(http.StatusCreated, gin.H{"user": user})
}

// GET /users/:id
func (h *UserHandler) GetUser(c *gin.Context) {
    idStr := c.Param("id")
    id, err := uuid.Parse(idStr)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }

    user, err := h.userRepo.GetByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
        return
    }

    // Remove password hash from response
    user.PasswordHash = ""
    c.JSON(http.StatusOK, gin.H{"user": user})
}

// GET /users
func (h *UserHandler) GetAllUsers(c *gin.Context) {
    users, err := h.userRepo.GetAll()
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
        return
    }

    // Remove password hashes from response
    for _, user := range users {
        user.PasswordHash = ""
    }

    c.JSON(http.StatusOK, gin.H{"users": users})
}

// PUT /users/:id
func (h *UserHandler) UpdateUser(c *gin.Context) {
    idStr := c.Param("id")
    id, err := uuid.Parse(idStr)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }

    // Get existing user
    user, err := h.userRepo.GetByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
        return
    }

    var updateData map[string]interface{}
    if err := c.ShouldBindJSON(&updateData); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Update only provided fields
    if username, exists := updateData["username"]; exists {
        if str, ok := username.(string); ok {
            user.Username = str
        }
    }
    if email, exists := updateData["email"]; exists {
        if str, ok := email.(string); ok {
            user.Email = str
        }
    }
    if fullName, exists := updateData["full_name"]; exists {
        if str, ok := fullName.(string); ok {
            user.FullName = str
        }
    }
    if bio, exists := updateData["bio"]; exists {
        if str, ok := bio.(string); ok {
            user.Bio = &str
        }
    }
    if city, exists := updateData["city"]; exists {
        if str, ok := city.(string); ok {
            user.City = &str
        }
    }
    if country, exists := updateData["country"]; exists {
        if str, ok := country.(string); ok {
            user.Country = &str
        }
    }

    if err := h.userRepo.Update(user); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
        return
    }

    user.PasswordHash = ""
    c.JSON(http.StatusOK, gin.H{"user": user})
}

// DELETE /users/:id
func (h *UserHandler) DeleteUser(c *gin.Context) {
    idStr := c.Param("id")
    id, err := uuid.Parse(idStr)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }

    if err := h.userRepo.Delete(id); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}
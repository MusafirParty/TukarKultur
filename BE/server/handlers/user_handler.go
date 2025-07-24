package handlers

import (
	"fmt"
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/repository"
	"tukarkultur/api/services"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type UserHandler struct {
	userRepo          *repository.UserRepository
	cloudinaryService *services.CloudinaryService
}

func NewUserHandler(userRepo *repository.UserRepository, cloudinaryService *services.CloudinaryService) *UserHandler {
	return &UserHandler{
		userRepo:          userRepo,
		cloudinaryService: cloudinaryService,
	}
}

// POST /users
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
		ID:           uuid.New(), // Generate UUID here
		Username:     req.Username,
		Email:        req.Email,
		PasswordHash: string(hashedPassword),
		FullName:     req.FullName,
		Bio:          req.Bio,
		Age:          req.Age,
		City:         req.City,
		Country:      req.Country,
		Interests:    req.Interests,
		// Latitude and Longitude will be nil by default, which is fine
	}

	if err := h.userRepo.Create(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprint("Failed to create user: ", err)})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprint("Failed to fetch users: ", err)})
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

	fmt.Print(user)
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

	if lat, exists := updateData["latitude"]; exists {
		if f, ok := lat.(float64); ok {
			user.Latitude = &f
		}
	}
	if lng, exists := updateData["longitude"]; exists {
		if f, ok := lng.(float64); ok {
			user.Longitude = &f
		}
	}

	if err := h.userRepo.Update(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprint("Failed to update user: ", err)})
		return
	}

	user.PasswordHash = ""
	c.JSON(http.StatusOK, gin.H{"user": user})
}

func (h *UserHandler) UploadProfilePicture(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	file, _, err := c.Request.FormFile("profile_picture")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}
	defer file.Close()

	// Upload to Cloudinary
	result, err := h.cloudinaryService.UploadImage(file, "profiles")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload image"})
		return
	}

	// Update user profile picture URL
	user, err := h.userRepo.GetByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.ProfilePictureURL = &result.SecureURL
	err = h.userRepo.Update(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":             "Profile picture updated successfully",
		"profile_picture_url": result.SecureURL,
	})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprint("Failed to delete user: ", err)})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}

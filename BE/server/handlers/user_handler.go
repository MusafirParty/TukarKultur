package handlers

import (
	"math"
	"net/http"
	"sort"
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

// PUT /users/location/:id
func (h *UserHandler) UpdateLocation(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	var req models.UpdateLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Latitude < -90 || req.Latitude > 90 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "latitude must be between -90 and 90"})
		return
	}
	if req.Longitude < -180 || req.Longitude > 180 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "longitude must be between -180 and 180"})
		return
	}

	lat, lon := req.Latitude, req.Longitude
	if err := h.userRepo.UpdateLocation(&id, &lat, &lon); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update location"})
		return
	}

	// Fetch all users
	users, err := h.userRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch users"})
		return
	}

	const maxKm = 5.0
	var nearby []models.NearbyUserResponse

	for _, u := range users {
		// skip self, and users with no coords
		if u.ID == id || u.Latitude == nil || u.Longitude == nil {
			continue
		}

		d := haversineKm(lat, lon, *u.Latitude, *u.Longitude)
		if d <= maxKm {
			nearby = append(nearby, models.NearbyUserResponse{
				ID:                u.ID,
				Username:          u.Username,
				FullName:          u.FullName,
				ProfilePictureURL: u.ProfilePictureURL,
				City:              u.City,
				Country:           u.Country,
				DistanceKm:        roundTo(d, 0.001), // 3 decimal places
				UpdatedAt:         u.UpdatedAt,
				LocationUpdatedAt: u.LocationUpdatedAt,
			})
		}
	}

	// sort by distance asc
	sort.Slice(nearby, func(i, j int) bool { return nearby[i].DistanceKm < nearby[j].DistanceKm })

	c.JSON(http.StatusOK, gin.H{
		"nearby_users": nearby,
		"count":        len(nearby),
	})
}

func haversineKm(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371.0 // Earth radius in km
	dLat := deg2rad(lat2 - lat1)
	dLon := deg2rad(lon2 - lon1)
	lat1r := deg2rad(lat1)
	lat2r := deg2rad(lat2)

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1r)*math.Cos(lat2r)*math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	return R * c
}

func deg2rad(d float64) float64 { return d * math.Pi / 180 }

func roundTo(v, step float64) float64 {
	return math.Round(v/step) * step
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}

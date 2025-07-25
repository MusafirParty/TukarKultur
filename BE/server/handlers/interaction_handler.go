package handlers

import (
	"net/http"
	"strconv"
	"tukarkultur/api/models"
	"tukarkultur/api/repository"
	"tukarkultur/api/services"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type InteractionHandler struct {
	interactionRepo   *repository.InteractionRepository
	meetupRepo        *repository.MeetupRepository
	cloudinaryService *services.CloudinaryService
}

func NewInteractionHandler(interactionRepo *repository.InteractionRepository, meetupRepo *repository.MeetupRepository) *InteractionHandler {
	return &InteractionHandler{
		interactionRepo:   interactionRepo,
		meetupRepo:        meetupRepo,
		cloudinaryService: services.NewCloudinaryService(),
	}
}

// GET /interactions
func (h *InteractionHandler) GetAllInteractions(c *gin.Context) {
	interactions, err := h.interactionRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve interactions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"interactions": interactions})
}

// GET /interactions/:id
func (h *InteractionHandler) GetInteraction(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interaction ID"})
		return
	}

	interaction, err := h.interactionRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Interaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve interaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"interaction": interaction})
}

// GET /interactions/meetup/:id
func (h *InteractionHandler) GetInteractionsByMeetupID(c *gin.Context) {
	idStr := c.Param("id")
	meetupID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	interactions, err := h.interactionRepo.GetByMeetupID(meetupID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup interactions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"interactions": interactions})
}

// GET /interactions/user/:id
func (h *InteractionHandler) GetInteractionsByUserID(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	interactions, err := h.interactionRepo.GetByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user interactions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"interactions": interactions})
}

// GET /interactions/reviews/:id
func (h *InteractionHandler) GetReviewsForUser(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	reviews, err := h.interactionRepo.GetReviewsForUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user reviews"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"reviews": reviews})
}

// GET /interactions/stats/:id
func (h *InteractionHandler) GetUserRatingStats(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	stats, err := h.interactionRepo.GetUserRatingStats(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user rating stats"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"stats": stats})
}

func (h *InteractionHandler) CreateInteraction(c *gin.Context) {
	// Parse form data
	meetupIDStr := c.PostForm("meetup_id")
	reviewerIDStr := c.PostForm("reviewer_id")
	reviewedUserIDStr := c.PostForm("reviewed_user_id")
	ratingStr := c.PostForm("rating")
	reviewText := c.PostForm("review_text")

	// Validate required fields
	if meetupIDStr == "" || reviewerIDStr == "" || reviewedUserIDStr == "" || ratingStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required fields"})
		return
	}

	// Convert and validate form data
	meetupID, err := uuid.Parse(meetupIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	reviewerID, err := uuid.Parse(reviewerIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid reviewer ID"})
		return
	}

	reviewedUserID, err := uuid.Parse(reviewedUserIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid reviewed user ID"})
		return
	}

	rating, err := strconv.Atoi(ratingStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid rating"})
		return
	}

	interaction := &models.Interaction{
		ID:             uuid.New(),
		MeetupID:       meetupID,
		ReviewerID:     reviewerID,
		ReviewedUserID: reviewedUserID,
		Rating:         rating,
	}

	if reviewText != "" {
		interaction.ReviewText = &reviewText
	}

	// Handle file upload if present
	file, _, err := c.Request.FormFile("meetup_photo")
	if err == nil {
		defer file.Close()

		result, err := h.cloudinaryService.UploadImage(file, "meetups")
		if err == nil {
			interaction.MeetupPhotoURL = &result.SecureURL
			interaction.MeetupPhotoPublicID = &result.PublicID
		}
	}

	// Save interaction
	if err := h.interactionRepo.Create(interaction); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create interaction"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"interaction": interaction})
}

// Add method to update interaction with file upload
func (h *InteractionHandler) UpdateInteractionWithPhoto(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interaction ID"})
		return
	}

	// Get existing interaction
	existingInteraction, err := h.interactionRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Interaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve interaction"})
		return
	}

	// Parse form data
	ratingStr := c.PostForm("rating")
	reviewText := c.PostForm("review_text")

	// Update rating if provided
	if ratingStr != "" {
		rating, err := strconv.Atoi(ratingStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid rating"})
			return
		}
		existingInteraction.Rating = rating
	}

	// Update review text if provided
	if reviewText != "" {
		existingInteraction.ReviewText = &reviewText
	}

	// Handle file upload if present
	file, _, err := c.Request.FormFile("meetup_photo")
	if err == nil {
		defer file.Close()

		result, err := h.cloudinaryService.UploadImage(file, "meetups")
		if err == nil {
			existingInteraction.MeetupPhotoURL = &result.SecureURL
			existingInteraction.MeetupPhotoPublicID = &result.PublicID
		}
	}

	if err := h.interactionRepo.Update(existingInteraction); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update interaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"interaction": existingInteraction})
}

// DELETE /interactions/:id
func (h *InteractionHandler) DeleteInteraction(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interaction ID"})
		return
	}

	// Check if interaction exists
	_, err = h.interactionRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Interaction not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve interaction"})
		return
	}

	if err := h.interactionRepo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete interaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Interaction deleted successfully"})
}

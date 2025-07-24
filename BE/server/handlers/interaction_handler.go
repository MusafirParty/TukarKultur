package handlers

import (
	"log"
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/repository"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type InteractionHandler struct {
	interactionRepo *repository.InteractionRepository
	meetupRepo      *repository.MeetupRepository
}

func NewInteractionHandler(interactionRepo *repository.InteractionRepository, meetupRepo *repository.MeetupRepository) *InteractionHandler {
	return &InteractionHandler{
		interactionRepo: interactionRepo,
		meetupRepo:      meetupRepo,
	}
}

// POST /interactions
func (h *InteractionHandler) CreateInteraction(c *gin.Context) {
	var req models.CreateInteractionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("Error binding JSON for create interaction: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	log.Printf("Received create interaction request: %+v", req)

	// Validate that reviewer and reviewed user are different
	if req.ReviewerID == req.ReviewedUserID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot review yourself"})
		return
	}

	// Check if meetup exists and is completed
	meetup, err := h.meetupRepo.GetByID(req.MeetupID)
	if err != nil {
		log.Printf("Error getting meetup: %v", err)
		c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
		return
	}

	log.Printf("Meetup found - ID: %s, Status: '%s'", meetup.ID, meetup.Status)

	if meetup.Status != "completed" {
		log.Printf("Meetup status is '%s', expected 'completed'", meetup.Status)
		c.JSON(http.StatusBadRequest, gin.H{
			"error":          "Can only review completed meetups",
			"current_status": meetup.Status,
		})
		return
	}

	// Check if interaction already exists for this meetup and reviewer
	exists, err := h.interactionRepo.ExistsForMeetupAndReviewer(req.MeetupID, req.ReviewerID)
	if err != nil {
		log.Printf("Error checking if interaction exists: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check interaction status"})
		return
	}

	if exists {
		c.JSON(http.StatusConflict, gin.H{"error": "You have already reviewed this meetup"})
		return
	}

	interaction := &models.Interaction{
		MeetupID:            req.MeetupID,
		ReviewerID:          req.ReviewerID,
		ReviewedUserID:      req.ReviewedUserID,
		Rating:              req.Rating,
		MeetupPhotoURL:      req.MeetupPhotoURL,
		MeetupPhotoPublicID: req.MeetupPhotoPublicID,
		ReviewText:          req.ReviewText,
	}

	if err := h.interactionRepo.Create(interaction); err != nil {
		log.Printf("Error creating interaction in handler: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create interaction",
			"details": err.Error(),
		})
		return
	}

	log.Printf("Successfully created interaction: %+v", interaction)
	c.JSON(http.StatusCreated, gin.H{"interaction": interaction})
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

// PUT /interactions/:id
func (h *InteractionHandler) UpdateInteraction(c *gin.Context) {
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

	var req models.UpdateInteractionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update only provided fields
	if req.Rating != nil {
		existingInteraction.Rating = *req.Rating
	}
	if req.MeetupPhotoURL != nil {
		existingInteraction.MeetupPhotoURL = req.MeetupPhotoURL
	}
	if req.MeetupPhotoPublicID != nil {
		existingInteraction.MeetupPhotoPublicID = req.MeetupPhotoPublicID
	}
	if req.ReviewText != nil {
		existingInteraction.ReviewText = req.ReviewText
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

package handlers

import (
	"log"
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/repository"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MeetupHandler struct {
	meetupRepo *repository.MeetupRepository
}

func NewMeetupHandler(meetupRepo *repository.MeetupRepository) *MeetupHandler {
	return &MeetupHandler{meetupRepo: meetupRepo}
}

// POST /meetups
func (h *MeetupHandler) CreateMeetup(c *gin.Context) {
	var req models.CreateMeetupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("Error binding JSON for create meetup: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	log.Printf("Received create meetup request: %+v", req)

	// Validate that proposed_by and proposed_to are different (if proposed_to is provided)
	if req.ProposedTo != nil && req.ProposedBy == *req.ProposedTo {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot propose meetup to yourself"})
		return
	}

	meetup := &models.Meetup{
		ProposedBy:      req.ProposedBy,
		ProposedTo:      req.ProposedTo,
		LocationName:    req.LocationName,
		LocationAddress: req.LocationAddress,
		MeetupTime:      req.MeetupTime,
	}

	if err := h.meetupRepo.Create(meetup); err != nil {
		log.Printf("Error creating meetup in handler: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create meetup",
			"details": err.Error(),
		})
		return
	}

	log.Printf("Successfully created meetup: %+v", meetup)
	c.JSON(http.StatusCreated, gin.H{"meetup": meetup})
}

// GET /meetups
func (h *MeetupHandler) GetAllMeetups(c *gin.Context) {
	// Check if client wants detailed user info
	includeDetails := c.Query("include_details") == "true"
	status := c.Query("status") // Filter by status if provided

	if includeDetails {
		meetups, err := h.meetupRepo.GetMeetupsWithUserDetails()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetups with details"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"meetups": meetups})
	} else if status != "" {
		meetups, err := h.meetupRepo.GetByStatus(status)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetups by status"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"meetups": meetups})
	} else {
		meetups, err := h.meetupRepo.GetAll()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetups"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"meetups": meetups})
	}
}

// GET /meetups/:id
func (h *MeetupHandler) GetMeetup(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	meetup, err := h.meetupRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"meetup": meetup})
}

// GET /meetups/user/:id
func (h *MeetupHandler) GetMeetupsByUserID(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	meetups, err := h.meetupRepo.GetByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user meetups"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"meetups": meetups})
}

// PUT /meetups/:id
func (h *MeetupHandler) UpdateMeetup(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	// Get existing meetup
	existingMeetup, err := h.meetupRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup"})
		return
	}

	var req models.UpdateMeetupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update only provided fields
	if req.LocationName != nil {
		existingMeetup.LocationName = req.LocationName
	}
	if req.LocationAddress != nil {
		existingMeetup.LocationAddress = req.LocationAddress
	}
	if req.MeetupTime != nil {
		existingMeetup.MeetupTime = req.MeetupTime
	}
	if req.Status != nil {
		// Validate status
		validStatuses := map[string]bool{
			"proposed":  true,
			"confirmed": true,
			"completed": true,
			"cancelled": true,
		}
		if !validStatuses[*req.Status] {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid status. Must be: proposed, confirmed, completed, or cancelled"})
			return
		}
		existingMeetup.Status = *req.Status
	}

	if err := h.meetupRepo.Update(existingMeetup); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update meetup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"meetup": existingMeetup})
}

// DELETE /meetups/:id
func (h *MeetupHandler) DeleteMeetup(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	// Check if meetup exists
	_, err = h.meetupRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup"})
		return
	}

	if err := h.meetupRepo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete meetup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Meetup deleted successfully"})
}

// Add this new method to your MeetupHandler:

// PUT /meetups/:id/complete
func (h *MeetupHandler) CompleteMeetup(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	// Get existing meetup
	existingMeetup, err := h.meetupRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup"})
		return
	}

	log.Printf("Current meetup status: '%s'", existingMeetup.Status)

	// Only allow completing if current status is "confirmed"
	if existingMeetup.Status != "confirmed" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":          "Can only complete confirmed meetups",
			"current_status": existingMeetup.Status,
		})
		return
	}

	// Update status to completed
	existingMeetup.Status = "completed"

	if err := h.meetupRepo.Update(existingMeetup); err != nil {
		log.Printf("Error completing meetup: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete meetup"})
		return
	}

	log.Printf("Successfully completed meetup: %s", existingMeetup.ID)
	c.JSON(http.StatusOK, gin.H{
		"message": "Meetup completed successfully",
		"meetup":  existingMeetup,
	})
}

// PUT /meetups/:id/confirm
func (h *MeetupHandler) ConfirmMeetup(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid meetup ID"})
		return
	}

	// Get existing meetup
	existingMeetup, err := h.meetupRepo.GetByID(id)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Meetup not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meetup"})
		return
	}

	// Only allow confirming if current status is "proposed"
	if existingMeetup.Status != "proposed" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":          "Can only confirm proposed meetups",
			"current_status": existingMeetup.Status,
		})
		return
	}

	// Update status to confirmed
	existingMeetup.Status = "confirmed"

	if err := h.meetupRepo.Update(existingMeetup); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to confirm meetup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Meetup confirmed successfully",
		"meetup":  existingMeetup,
	})
}

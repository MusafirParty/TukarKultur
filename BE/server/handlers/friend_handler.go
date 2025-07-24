package handlers

import (
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/repository"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type FriendHandler struct {
	friendRepo *repository.FriendRepository
}

func NewFriendHandler(friendRepo *repository.FriendRepository) *FriendHandler {
	return &FriendHandler{friendRepo: friendRepo}
}

// POST /friends
func (h *FriendHandler) CreateFriend(c *gin.Context) {
	var req models.CreateFriendRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if users are trying to add themselves
	if req.UserID1 == req.UserID2 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot add yourself as friend"})
		return
	}

	// Check if friendship already exists
	exists, err := h.friendRepo.Exists(req.UserID1, req.UserID2)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check friendship status"})
		return
	}

	if exists {
		c.JSON(http.StatusConflict, gin.H{"error": "Friendship already exists"})
		return
	}

	friend := &models.Friend{
		UserID1: req.UserID1,
		UserID2: req.UserID2,
	}

	if err := h.friendRepo.Create(friend); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create friendship"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"friend": friend})
}

// GET /friends
func (h *FriendHandler) GetAllFriends(c *gin.Context) {
	friends, err := h.friendRepo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friends"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friends": friends})
}

// GET /friends/user/:id
func (h *FriendHandler) GetFriendsByUserID(c *gin.Context) {
	idStr := c.Param("id")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Check if client wants detailed user info
	includeDetails := c.Query("include_details") == "true"

	if includeDetails {
		friends, err := h.friendRepo.GetFriendsWithUserDetails(userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friends with details"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"friends": friends})
	} else {
		friends, err := h.friendRepo.GetFriendsByUserID(userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friends"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"friends": friends})
	}
}

// DELETE /friends
func (h *FriendHandler) DeleteFriend(c *gin.Context) {
	var req models.CreateFriendRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if friendship exists
	exists, err := h.friendRepo.Exists(req.UserID1, req.UserID2)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check friendship status"})
		return
	}

	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Friendship not found"})
		return
	}

	if err := h.friendRepo.Delete(req.UserID1, req.UserID2); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete friendship"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Friendship deleted successfully"})
}

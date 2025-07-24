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
	userRepo   *repository.UserRepository
}

func NewFriendHandler(friendRepo *repository.FriendRepository, userRepo *repository.UserRepository) *FriendHandler {
	return &FriendHandler{
		friendRepo: friendRepo,
		userRepo:   userRepo,
	}
}

func (h *FriendHandler) GetAllFriends(c *gin.Context) {
	// Temporary: use a hardcoded user ID for testing
	userID := uuid.MustParse("550e8400-e29b-41d4-a716-446655440001")

	friends, err := h.friendRepo.GetFriendsByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"friends": friends})
}

func (h *FriendHandler) CreateFriend(c *gin.Context) {
	var req models.CreateFriendRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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

func (h *FriendHandler) DeleteFriend(c *gin.Context) {
	userID1Str := c.Query("user_id_1")
	userID2Str := c.Query("user_id_2")

	userID1, err := uuid.Parse(userID1Str)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user_id_1"})
		return
	}

	userID2, err := uuid.Parse(userID2Str)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user_id_2"})
		return
	}

	if err := h.friendRepo.Delete(userID1, userID2); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete friendship"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Friendship deleted successfully"})
}

// New friend request methods
func (h *FriendHandler) SendFriendRequest(c *gin.Context) {
	var req models.SendFriendRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get requester ID from auth context (you'll need to implement this)
	requesterID := uuid.New() // Replace with actual auth user ID

	// Check if recipient exists
	_, err := h.userRepo.GetByID(req.RecipientID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recipient user not found"})
		return
	}

	// Check if users are the same
	if requesterID == req.RecipientID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot send friend request to yourself"})
		return
	}

	// Check if already friends
	areFriends, err := h.friendRepo.AreFriends(requesterID, req.RecipientID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check friendship status"})
		return
	}
	if areFriends {
		c.JSON(http.StatusConflict, gin.H{"error": "Already friends"})
		return
	}

	// Check if friend request already exists
	existingRequest, err := h.friendRepo.GetFriendRequestByUsers(requesterID, req.RecipientID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing requests"})
		return
	}
	if existingRequest != nil && existingRequest.Status == models.FriendRequestStatusPending {
		c.JSON(http.StatusConflict, gin.H{"error": "Friend request already exists"})
		return
	}

	// Create new friend request
	friendRequest := &models.FriendRequest{
		ID:          uuid.New(),
		RequesterID: requesterID,
		RecipientID: req.RecipientID,
		Status:      models.FriendRequestStatusPending,
	}

	if err := h.friendRepo.CreateFriendRequest(friendRequest); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create friend request"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"friend_request": friendRequest})
}

func (h *FriendHandler) RespondToFriendRequest(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid friend request ID"})
		return
	}

	var req models.RespondFriendRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user ID from auth context
	userID := uuid.New() // Replace with actual auth user ID

	// Get friend request
	friendRequest, err := h.friendRepo.GetFriendRequestByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Friend request not found"})
		return
	}

	// Check if user is the recipient
	if friendRequest.RecipientID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Not authorized to respond to this request"})
		return
	}

	// Check if request is still pending
	if friendRequest.Status != models.FriendRequestStatusPending {
		c.JSON(http.StatusConflict, gin.H{"error": "Friend request is no longer pending"})
		return
	}

	if req.Status == models.FriendRequestStatusAccepted {
		// Accept request and create friendship
		if err := h.friendRepo.AcceptFriendRequest(id); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to accept friend request"})
			return
		}
	} else {
		// Just update status to rejected
		if err := h.friendRepo.UpdateFriendRequestStatus(id, req.Status); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update friend request"})
			return
		}
	}

	// Get updated friend request
	updatedRequest, err := h.friendRepo.GetFriendRequestByID(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve updated request"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friend_request": updatedRequest})
}

func (h *FriendHandler) GetReceivedFriendRequests(c *gin.Context) {
	userID := uuid.New() // Replace with actual auth user ID

	requests, err := h.friendRepo.GetPendingFriendRequests(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friend requests"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friend_requests": requests})
}

func (h *FriendHandler) GetSentFriendRequests(c *gin.Context) {
	userID := uuid.New() // Replace with actual auth user ID

	requests, err := h.friendRepo.GetSentFriendRequests(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve sent requests"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friend_requests": requests})
}

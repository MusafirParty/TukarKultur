package models

import (
	"time"

	"github.com/google/uuid"
)

// Keep existing Friend model
type Friend struct {
	UserID1   uuid.UUID `json:"user_id_1" db:"user_id_1"`
	UserID2   uuid.UUID `json:"user_id_2" db:"user_id_2"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// Add FriendRequest model
type FriendRequest struct {
	ID          uuid.UUID `json:"id" db:"id"`
	RequesterID uuid.UUID `json:"requester_id" db:"requester_id"`
	RecipientID uuid.UUID `json:"recipient_id" db:"recipient_id"`
	Status      string    `json:"status" db:"status"` // pending, accepted, rejected
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// Keep existing CreateFriendRequest
type CreateFriendRequest struct {
	UserID1 uuid.UUID `json:"user_id_1" binding:"required"`
	UserID2 uuid.UUID `json:"user_id_2" binding:"required"`
}

// Add new request DTOs
type SendFriendRequestRequest struct {
	RecipientID uuid.UUID `json:"recipient_id" binding:"required"`
}

type RespondFriendRequestRequest struct {
	Status string `json:"status" binding:"required,oneof=accepted rejected"`
}

// Keep existing FriendResponse
type FriendResponse struct {
	UserID1   uuid.UUID `json:"user_id_1"`
	UserID2   uuid.UUID `json:"user_id_2"`
	CreatedAt time.Time `json:"created_at"`
	// Optional: Include user details
	User1 *User `json:"user_1,omitempty"`
	User2 *User `json:"user_2,omitempty"`
}

// Add FriendRequestResponse
type FriendRequestResponse struct {
	ID          uuid.UUID `json:"id"`
	RequesterID uuid.UUID `json:"requester_id"`
	RecipientID uuid.UUID `json:"recipient_id"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	// Optional: Include user details
	Requester *User `json:"requester,omitempty"`
	Recipient *User `json:"recipient,omitempty"`
}

// Friend request status constants
const (
	FriendRequestStatusPending  = "pending"
	FriendRequestStatusAccepted = "accepted"
	FriendRequestStatusRejected = "rejected"
)

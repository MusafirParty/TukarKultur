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

// FriendRequest model
type FriendRequest struct {
	ID          uuid.UUID `json:"id" db:"id"`
	RequesterID uuid.UUID `json:"requester_id" db:"requester_id"`
	RecipientID uuid.UUID `json:"recipient_id" db:"recipient_id"`
	Status      string    `json:"status" db:"status"` // pending, accepted, rejected
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// Simple request DTOs
type CreateFriendRequest struct {
	UserID1 uuid.UUID `json:"user_id_1" binding:"required"`
	UserID2 uuid.UUID `json:"user_id_2" binding:"required"`
}

// Friend request status constants
const (
	FriendRequestStatusPending  = "pending"
	FriendRequestStatusAccepted = "accepted"
	FriendRequestStatusRejected = "rejected"
)

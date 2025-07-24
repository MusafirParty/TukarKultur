package models

import (
	"time"

	"github.com/google/uuid"
)

type Friend struct {
	UserID1   uuid.UUID `json:"user_id_1" db:"user_id_1"`
	UserID2   uuid.UUID `json:"user_id_2" db:"user_id_2"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

type CreateFriendRequest struct {
	UserID1 uuid.UUID `json:"user_id_1" binding:"required"`
	UserID2 uuid.UUID `json:"user_id_2" binding:"required"`
}

type FriendResponse struct {
	UserID1   uuid.UUID `json:"user_id_1"`
	UserID2   uuid.UUID `json:"user_id_2"`
	CreatedAt time.Time `json:"created_at"`
	// Optional: Include user details
	User1 *User `json:"user_1,omitempty"`
	User2 *User `json:"user_2,omitempty"`
}

package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

type User struct {
	ID                uuid.UUID      `json:"id" db:"id"`
	Username          string         `json:"username" db:"username"`
	Email             string         `json:"email" db:"email"`
	PasswordHash      string         `json:"-" db:"password_hash"` // Hidden from JSON
	FullName          string         `json:"full_name" db:"full_name"`
	ProfilePictureURL *string        `json:"profile_picture_url,omitempty" db:"profile_picture_url"`
	Bio               *string        `json:"bio,omitempty" db:"bio"`
	Age               *int           `json:"age,omitempty" db:"age"`
	City              *string        `json:"city,omitempty" db:"city"`
	Country           *string        `json:"country,omitempty" db:"country"`
	Interests         pq.StringArray `json:"interests" db:"interests"`
	Latitude          *float64       `json:"latitude,omitempty" db:"latitude"`
	Longitude         *float64       `json:"longitude,omitempty" db:"longitude"`
	LocationUpdatedAt *time.Time     `json:"location_updated_at,omitempty" db:"location_updated_at"`
	TotalInteractions int            `json:"total_interactions" db:"total_interactions"`
	AverageRating     float64        `json:"average_rating" db:"average_rating"`
	UpdatedAt         time.Time      `json:"updated_at" db:"updated_at"`
	CreatedAt         time.Time      `json:"created_at" db:"created_at"`
}

type CreateUserRequest struct {
	Username  string         `json:"username" binding:"required,min=3,max=50"`
	Email     string         `json:"email" binding:"required,email"`
	Password  string         `json:"password" binding:"required,min=6"`
	FullName  string         `json:"full_name" binding:"required,max=150"`
	Bio       *string        `json:"bio,omitempty"`
	Age       *int           `json:"age,omitempty"`
	City      *string        `json:"city,omitempty"`
	Country   *string        `json:"country,omitempty"`
	Interests pq.StringArray `json:"interests,omitempty"`
}

package models

import (
	"time"

	"github.com/google/uuid"
)

type Interaction struct {
	ID                  uuid.UUID `json:"id" db:"id"`
	MeetupID            uuid.UUID `json:"meetup_id" db:"meetup_id"`
	ReviewerID          uuid.UUID `json:"reviewer_id" db:"reviewer_id"`
	ReviewedUserID      uuid.UUID `json:"reviewed_user_id" db:"reviewed_user_id"`
	Rating              int       `json:"rating" db:"rating"` // 1-5 stars
	MeetupPhotoURL      *string   `json:"meetup_photo_url,omitempty" db:"meetup_photo_url"`
	MeetupPhotoPublicID *string   `json:"meetup_photo_public_id,omitempty" db:"meetup_photo_public_id"`
	ReviewText          *string   `json:"review_text,omitempty" db:"review_text"`
	CreatedAt           time.Time `json:"created_at" db:"created_at"`
}

type CreateInteractionRequest struct {
	MeetupID            uuid.UUID `json:"meetup_id" binding:"required"`
	ReviewerID          uuid.UUID `json:"reviewer_id" binding:"required"`
	ReviewedUserID      uuid.UUID `json:"reviewed_user_id" binding:"required"`
	Rating              int       `json:"rating" binding:"required,min=1,max=5"`
	MeetupPhotoURL      *string   `json:"meetup_photo_url,omitempty"`
	MeetupPhotoPublicID *string   `json:"meetup_photo_public_id,omitempty"`
	ReviewText          *string   `json:"review_text,omitempty"`
}

type UpdateInteractionRequest struct {
	Rating              *int    `json:"rating,omitempty" binding:"omitempty,min=1,max=5"`
	MeetupPhotoURL      *string `json:"meetup_photo_url,omitempty"`
	MeetupPhotoPublicID *string `json:"meetup_photo_public_id,omitempty"`
	ReviewText          *string `json:"review_text,omitempty"`
}

type InteractionResponse struct {
	ID                  uuid.UUID `json:"id"`
	MeetupID            uuid.UUID `json:"meetup_id"`
	ReviewerID          uuid.UUID `json:"reviewer_id"`
	ReviewedUserID      uuid.UUID `json:"reviewed_user_id"`
	Rating              int       `json:"rating"`
	MeetupPhotoURL      *string   `json:"meetup_photo_url,omitempty"`
	MeetupPhotoPublicID *string   `json:"meetup_photo_public_id,omitempty"`
	ReviewText          *string   `json:"review_text,omitempty"`
	CreatedAt           time.Time `json:"created_at"`
	// Optional: Include related data
	Meetup       *Meetup `json:"meetup,omitempty"`
	Reviewer     *User   `json:"reviewer,omitempty"`
	ReviewedUser *User   `json:"reviewed_user,omitempty"`
}

type UserRatingStats struct {
	UserID            uuid.UUID `json:"user_id"`
	TotalInteractions int       `json:"total_interactions"`
	AverageRating     float64   `json:"average_rating"`
	FiveStars         int       `json:"five_stars"`
	FourStars         int       `json:"four_stars"`
	ThreeStars        int       `json:"three_stars"`
	TwoStars          int       `json:"two_stars"`
	OneStar           int       `json:"one_star"`
}

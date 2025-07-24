package models

import (
	"time"

	"github.com/google/uuid"
)

type Meetup struct {
	ID              uuid.UUID  `json:"id" db:"id"`
	ProposedBy      uuid.UUID  `json:"proposed_by" db:"proposed_by"`
	ProposedTo      *uuid.UUID `json:"proposed_to,omitempty" db:"proposed_to"`
	LocationName    *string    `json:"location_name,omitempty" db:"location_name"`
	LocationAddress *string    `json:"location_address,omitempty" db:"location_address"`
	MeetupTime      *time.Time `json:"meetup_time,omitempty" db:"meetup_time"`
	Status          string     `json:"status" db:"status"` // proposed, confirmed, completed, cancelled
	CreatedAt       time.Time  `json:"created_at" db:"created_at"`
}

type CreateMeetupRequest struct {
	ProposedBy      uuid.UUID  `json:"proposed_by" binding:"required"`
	ProposedTo      *uuid.UUID `json:"proposed_to,omitempty"`
	LocationName    *string    `json:"location_name,omitempty"`
	LocationAddress *string    `json:"location_address,omitempty"`
	MeetupTime      *time.Time `json:"meetup_time,omitempty"`
}

type UpdateMeetupRequest struct {
	ProposedTo      *uuid.UUID `json:"proposed_to,omitempty"`
	LocationName    *string    `json:"location_name,omitempty"`
	LocationAddress *string    `json:"location_address,omitempty"`
	MeetupTime      *time.Time `json:"meetup_time,omitempty"`
	Status          *string    `json:"status,omitempty"` // proposed, confirmed, completed, cancelled
}

type MeetupResponse struct {
	ID              uuid.UUID  `json:"id"`
	ProposedBy      uuid.UUID  `json:"proposed_by"`
	ProposedTo      *uuid.UUID `json:"proposed_to,omitempty"`
	LocationName    *string    `json:"location_name,omitempty"`
	LocationAddress *string    `json:"location_address,omitempty"`
	MeetupTime      *time.Time `json:"meetup_time,omitempty"`
	Status          string     `json:"status"`
	CreatedAt       time.Time  `json:"created_at"`
	// Optional: Include user details
	ProposerUser  *User `json:"proposer_user,omitempty"`
	RecipientUser *User `json:"recipient_user,omitempty"`
}

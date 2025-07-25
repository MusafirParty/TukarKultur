package repository

import (
	"database/sql"
	"fmt"
	"log"
	"time"
	"tukarkultur/api/models"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type MeetupRepository struct {
	db *sqlx.DB
}

func NewMeetupRepository(db *sqlx.DB) *MeetupRepository {
	return &MeetupRepository{db: db}
}

func (r *MeetupRepository) Create(meetup *models.Meetup) error {
	query := `
        INSERT INTO meetups (id, proposed_by, proposed_to, location_name, location_address, meetup_time, status, created_at) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING created_at`

	meetup.ID = uuid.New()
	meetup.Status = "proposed" // Default status
	meetup.CreatedAt = time.Now()

	log.Printf("Creating meetup with ID: %s, ProposedBy: %s, ProposedTo: %v",
		meetup.ID, meetup.ProposedBy, meetup.ProposedTo)

	err := r.db.QueryRow(
		query,
		meetup.ID,
		meetup.ProposedBy,
		meetup.ProposedTo,
		meetup.LocationName,
		meetup.LocationAddress,
		meetup.MeetupTime,
		meetup.Status,
		meetup.CreatedAt,
	).Scan(&meetup.CreatedAt)

	if err != nil {
		log.Printf("Error creating meetup: %v", err)
		return fmt.Errorf("failed to create meetup: %w", err)
	}

	log.Printf("Successfully created meetup with ID: %s", meetup.ID)
	return nil
}

func (r *MeetupRepository) GetByID(id uuid.UUID) (*models.Meetup, error) {
	query := `
        SELECT id, proposed_by, proposed_to, location_name, location_address, meetup_time, status, created_at
        FROM meetups WHERE id = $1`

	meetup := &models.Meetup{}
	err := r.db.QueryRow(query, id).Scan(
		&meetup.ID,
		&meetup.ProposedBy,
		&meetup.ProposedTo,
		&meetup.LocationName,
		&meetup.LocationAddress,
		&meetup.MeetupTime,
		&meetup.Status,
		&meetup.CreatedAt,
	)

	if err != nil {
		log.Printf("Error getting meetup by ID %s: %v", id, err)
		return nil, err
	}

	return meetup, nil
}

func (r *MeetupRepository) GetAll() ([]*models.Meetup, error) {
	query := `
        SELECT id, proposed_by, proposed_to, location_name, location_address, meetup_time, status, created_at
        FROM meetups ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		log.Printf("Error getting all meetups: %v", err)
		return nil, err
	}
	defer rows.Close()

	var meetups []*models.Meetup
	for rows.Next() {
		meetup := &models.Meetup{}
		err := rows.Scan(
			&meetup.ID,
			&meetup.ProposedBy,
			&meetup.ProposedTo,
			&meetup.LocationName,
			&meetup.LocationAddress,
			&meetup.MeetupTime,
			&meetup.Status,
			&meetup.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning meetup row: %v", err)
			return nil, err
		}
		meetups = append(meetups, meetup)
	}

	return meetups, nil
}

func (r *MeetupRepository) GetByUserID(userID uuid.UUID) ([]*models.Meetup, error) {
	query := `
        SELECT id, proposed_by, proposed_to, location_name, location_address, meetup_time, status, created_at
        FROM meetups WHERE proposed_by = $1 OR proposed_to = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		log.Printf("Error getting meetups for user %s: %v", userID, err)
		return nil, err
	}
	defer rows.Close()

	var meetups []*models.Meetup
	for rows.Next() {
		meetup := &models.Meetup{}
		err := rows.Scan(
			&meetup.ID,
			&meetup.ProposedBy,
			&meetup.ProposedTo,
			&meetup.LocationName,
			&meetup.LocationAddress,
			&meetup.MeetupTime,
			&meetup.Status,
			&meetup.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning meetup row for user: %v", err)
			return nil, err
		}
		meetups = append(meetups, meetup)
	}

	return meetups, nil
}

func (r *MeetupRepository) GetByStatus(status string) ([]*models.Meetup, error) {
	query := `
        SELECT id, proposed_by, proposed_to, location_name, location_address, meetup_time, status, created_at
        FROM meetups WHERE status = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(query, status)
	if err != nil {
		log.Printf("Error getting meetups by status %s: %v", status, err)
		return nil, err
	}
	defer rows.Close()

	var meetups []*models.Meetup
	for rows.Next() {
		meetup := &models.Meetup{}
		err := rows.Scan(
			&meetup.ID,
			&meetup.ProposedBy,
			&meetup.ProposedTo,
			&meetup.LocationName,
			&meetup.LocationAddress,
			&meetup.MeetupTime,
			&meetup.Status,
			&meetup.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning meetup row by status: %v", err)
			return nil, err
		}
		meetups = append(meetups, meetup)
	}

	return meetups, nil
}

func (r *MeetupRepository) Update(meetup *models.Meetup) error {
	query := `
        UPDATE meetups SET
            proposed_to = $2, location_name = $3, location_address = $4, meetup_time = $5, status = $6
        WHERE id = $1`

	_, err := r.db.Exec(
		query,
		meetup.ID,
		meetup.ProposedTo,
		meetup.LocationName,
		meetup.LocationAddress,
		meetup.MeetupTime,
		meetup.Status,
	)

	if err != nil {
		log.Printf("Error updating meetup %s: %v", meetup.ID, err)
		return fmt.Errorf("failed to update meetup: %w", err)
	}

	return nil
}

func (r *MeetupRepository) Delete(id uuid.UUID) error {
	query := `DELETE FROM meetups WHERE id = $1`
	_, err := r.db.Exec(query, id)

	if err != nil {
		log.Printf("Error deleting meetup %s: %v", id, err)
		return fmt.Errorf("failed to delete meetup: %w", err)
	}

	return nil
}

func (r *MeetupRepository) GetMeetupsWithUserDetails() ([]*models.MeetupResponse, error) {
	query := `
        SELECT m.id, m.proposed_by, m.proposed_to, m.location_name, m.location_address, m.meetup_time, m.status, m.created_at,
               u1.id, u1.username, u1.email, u1.full_name, u1.profile_picture_url, u1.bio, u1.city, u1.country,
               u2.id, u2.username, u2.email, u2.full_name, u2.profile_picture_url, u2.bio, u2.city, u2.country
        FROM meetups m
        JOIN users u1 ON m.proposed_by = u1.id
        LEFT JOIN users u2 ON m.proposed_to = u2.id
        ORDER BY m.created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		log.Printf("Error getting meetups with user details: %v", err)
		return nil, err
	}
	defer rows.Close()

	var meetups []*models.MeetupResponse
	for rows.Next() {
		meetup := &models.MeetupResponse{}
		proposer := &models.User{}
		var recipient *models.User

		// Handle nullable recipient user
		var recipientID, recipientUsername, recipientEmail, recipientFullName sql.NullString
		var recipientProfilePicture, recipientBio, recipientCity, recipientCountry sql.NullString

		err := rows.Scan(
			&meetup.ID, &meetup.ProposedBy, &meetup.ProposedTo, &meetup.LocationName, &meetup.LocationAddress,
			&meetup.MeetupTime, &meetup.Status, &meetup.CreatedAt,
			&proposer.ID, &proposer.Username, &proposer.Email, &proposer.FullName,
			&proposer.ProfilePictureURL, &proposer.Bio, &proposer.City, &proposer.Country,
			&recipientID, &recipientUsername, &recipientEmail, &recipientFullName,
			&recipientProfilePicture, &recipientBio, &recipientCity, &recipientCountry,
		)
		if err != nil {
			log.Printf("Error scanning meetup with user details: %v", err)
			return nil, err
		}

		meetup.ProposerUser = proposer

		// Only create recipient user if data exists
		if recipientID.Valid {
			recipient = &models.User{}
			uuid.Parse(recipientID.String)
			recipient.Username = recipientUsername.String
			recipient.Email = recipientEmail.String
			recipient.FullName = recipientFullName.String
			if recipientProfilePicture.Valid {
				recipient.ProfilePictureURL = &recipientProfilePicture.String
			}
			if recipientBio.Valid {
				recipient.Bio = &recipientBio.String
			}
			if recipientCity.Valid {
				recipient.City = &recipientCity.String
			}
			if recipientCountry.Valid {
				recipient.Country = &recipientCountry.String
			}
			meetup.RecipientUser = recipient
		}

		meetups = append(meetups, meetup)
	}

	return meetups, nil
}

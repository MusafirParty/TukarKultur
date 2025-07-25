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

type InteractionRepository struct {
	db *sqlx.DB
}

func NewInteractionRepository(db *sqlx.DB) *InteractionRepository {
	return &InteractionRepository{db: db}
}

func (r *InteractionRepository) Create(interaction *models.Interaction) error {
	query := `
        INSERT INTO interactions (id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING created_at`

	interaction.ID = uuid.New()
	interaction.CreatedAt = time.Now()

	log.Printf("Creating interaction with ID: %s, MeetupID: %s, ReviewerID: %s, ReviewedUserID: %s",
		interaction.ID, interaction.MeetupID, interaction.ReviewerID, interaction.ReviewedUserID)

	err := r.db.QueryRow(
		query,
		interaction.ID,
		interaction.MeetupID,
		interaction.ReviewerID,
		interaction.ReviewedUserID,
		interaction.Rating,
		interaction.MeetupPhotoURL,
		interaction.MeetupPhotoPublicID,
		interaction.ReviewText,
		interaction.CreatedAt,
	).Scan(&interaction.CreatedAt)

	if err != nil {
		log.Printf("Error creating interaction: %v", err)
		return fmt.Errorf("failed to create interaction: %w", err)
	}

	// Update user's average rating after creating interaction
	if err := r.updateUserRating(interaction.ReviewedUserID); err != nil {
		log.Printf("Warning: failed to update user rating: %v", err)
		// Don't fail the whole operation if rating update fails
	}

	log.Printf("Successfully created interaction with ID: %s", interaction.ID)
	return nil
}

func (r *InteractionRepository) GetByID(id uuid.UUID) (*models.Interaction, error) {
	query := `
        SELECT id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at
        FROM interactions WHERE id = $1`

	interaction := &models.Interaction{}
	err := r.db.QueryRow(query, id).Scan(
		&interaction.ID,
		&interaction.MeetupID,
		&interaction.ReviewerID,
		&interaction.ReviewedUserID,
		&interaction.Rating,
		&interaction.MeetupPhotoURL,
		&interaction.MeetupPhotoPublicID,
		&interaction.ReviewText,
		&interaction.CreatedAt,
	)

	if err != nil {
		log.Printf("Error getting interaction by ID %s: %v", id, err)
		return nil, err
	}

	return interaction, nil
}

func (r *InteractionRepository) GetAll() ([]*models.Interaction, error) {
	query := `
        SELECT id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at
        FROM interactions ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		log.Printf("Error getting all interactions: %v", err)
		return nil, err
	}
	defer rows.Close()

	var interactions []*models.Interaction
	for rows.Next() {
		interaction := &models.Interaction{}
		err := rows.Scan(
			&interaction.ID,
			&interaction.MeetupID,
			&interaction.ReviewerID,
			&interaction.ReviewedUserID,
			&interaction.Rating,
			&interaction.MeetupPhotoURL,
			&interaction.MeetupPhotoPublicID,
			&interaction.ReviewText,
			&interaction.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning interaction row: %v", err)
			return nil, err
		}
		interactions = append(interactions, interaction)
	}

	return interactions, nil
}

func (r *InteractionRepository) GetByMeetupID(meetupID uuid.UUID) ([]*models.Interaction, error) {
	query := `
        SELECT id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at
        FROM interactions WHERE meetup_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(query, meetupID)
	if err != nil {
		log.Printf("Error getting interactions for meetup %s: %v", meetupID, err)
		return nil, err
	}
	defer rows.Close()

	var interactions []*models.Interaction
	for rows.Next() {
		interaction := &models.Interaction{}
		err := rows.Scan(
			&interaction.ID,
			&interaction.MeetupID,
			&interaction.ReviewerID,
			&interaction.ReviewedUserID,
			&interaction.Rating,
			&interaction.MeetupPhotoURL,
			&interaction.MeetupPhotoPublicID,
			&interaction.ReviewText,
			&interaction.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning interaction row for meetup: %v", err)
			return nil, err
		}
		interactions = append(interactions, interaction)
	}

	return interactions, nil
}

func (r *InteractionRepository) GetByUserID(userID uuid.UUID) ([]*models.Interaction, error) {
	query := `
        SELECT id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at
        FROM interactions WHERE reviewer_id = $1 OR reviewed_user_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		log.Printf("Error getting interactions for user %s: %v", userID, err)
		return nil, err
	}
	defer rows.Close()

	var interactions []*models.Interaction
	for rows.Next() {
		interaction := &models.Interaction{}
		err := rows.Scan(
			&interaction.ID,
			&interaction.MeetupID,
			&interaction.ReviewerID,
			&interaction.ReviewedUserID,
			&interaction.Rating,
			&interaction.MeetupPhotoURL,
			&interaction.MeetupPhotoPublicID,
			&interaction.ReviewText,
			&interaction.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning interaction row for user: %v", err)
			return nil, err
		}
		interactions = append(interactions, interaction)
	}

	return interactions, nil
}

func (r *InteractionRepository) GetReviewsForUser(userID uuid.UUID) ([]*models.Interaction, error) {
	query := `
        SELECT id, meetup_id, reviewer_id, reviewed_user_id, rating, meetup_photo_url, meetup_photo_public_id, review_text, created_at
        FROM interactions WHERE reviewed_user_id = $1 ORDER BY created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		log.Printf("Error getting reviews for user %s: %v", userID, err)
		return nil, err
	}
	defer rows.Close()

	var interactions []*models.Interaction
	for rows.Next() {
		interaction := &models.Interaction{}
		err := rows.Scan(
			&interaction.ID,
			&interaction.MeetupID,
			&interaction.ReviewerID,
			&interaction.ReviewedUserID,
			&interaction.Rating,
			&interaction.MeetupPhotoURL,
			&interaction.MeetupPhotoPublicID,
			&interaction.ReviewText,
			&interaction.CreatedAt,
		)
		if err != nil {
			log.Printf("Error scanning review row: %v", err)
			return nil, err
		}
		interactions = append(interactions, interaction)
	}

	return interactions, nil
}

func (r *InteractionRepository) Update(interaction *models.Interaction) error {
	query := `
        UPDATE interactions SET
            rating = $2, meetup_photo_url = $3, meetup_photo_public_id = $4, review_text = $5
        WHERE id = $1`

	_, err := r.db.Exec(
		query,
		interaction.ID,
		interaction.Rating,
		interaction.MeetupPhotoURL,
		interaction.MeetupPhotoPublicID,
		interaction.ReviewText,
	)

	if err != nil {
		log.Printf("Error updating interaction %s: %v", interaction.ID, err)
		return fmt.Errorf("failed to update interaction: %w", err)
	}

	// Update user's average rating after updating interaction
	if err := r.updateUserRating(interaction.ReviewedUserID); err != nil {
		log.Printf("Warning: failed to update user rating: %v", err)
	}

	return nil
}

func (r *InteractionRepository) Delete(id uuid.UUID) error {
	// Get the interaction first to know which user's rating to update
	interaction, err := r.GetByID(id)
	if err != nil {
		return err
	}

	query := `DELETE FROM interactions WHERE id = $1`
	_, err = r.db.Exec(query, id)

	if err != nil {
		log.Printf("Error deleting interaction %s: %v", id, err)
		return fmt.Errorf("failed to delete interaction: %w", err)
	}

	// Update user's average rating after deleting interaction
	if err := r.updateUserRating(interaction.ReviewedUserID); err != nil {
		log.Printf("Warning: failed to update user rating after deletion: %v", err)
	}

	return nil
}

func (r *InteractionRepository) GetUserRatingStats(userID uuid.UUID) (*models.UserRatingStats, error) {
	query := `
        SELECT 
            COUNT(*) as total_interactions,
            AVG(rating::decimal) as average_rating,
            COUNT(CASE WHEN rating = 5 THEN 1 END) as five_stars,
            COUNT(CASE WHEN rating = 4 THEN 1 END) as four_stars,
            COUNT(CASE WHEN rating = 3 THEN 1 END) as three_stars,
            COUNT(CASE WHEN rating = 2 THEN 1 END) as two_stars,
            COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
        FROM interactions 
        WHERE reviewed_user_id = $1`

	stats := &models.UserRatingStats{UserID: userID}
	var avgRating sql.NullFloat64

	err := r.db.QueryRow(query, userID).Scan(
		&stats.TotalInteractions,
		&avgRating,
		&stats.FiveStars,
		&stats.FourStars,
		&stats.ThreeStars,
		&stats.TwoStars,
		&stats.OneStar,
	)

	if err != nil {
		log.Printf("Error getting rating stats for user %s: %v", userID, err)
		return nil, err
	}

	if avgRating.Valid {
		stats.AverageRating = avgRating.Float64
	}

	return stats, nil
}

func (r *InteractionRepository) updateUserRating(userID uuid.UUID) error {
	// Calculate new average rating and total interactions
	query := `
        UPDATE users SET 
            total_interactions = (SELECT COUNT(*) FROM interactions WHERE reviewed_user_id = $1),
            average_rating = COALESCE((SELECT AVG(rating::decimal) FROM interactions WHERE reviewed_user_id = $1), 0)
        WHERE id = $1`

	_, err := r.db.Exec(query, userID)
	if err != nil {
		return fmt.Errorf("failed to update user rating: %w", err)
	}

	return nil
}

func (r *InteractionRepository) ExistsForMeetupAndReviewer(meetupID, reviewerID uuid.UUID) (bool, error) {
	query := `SELECT COUNT(*) FROM interactions WHERE meetup_id = $1 AND reviewer_id = $2`

	var count int
	err := r.db.QueryRow(query, meetupID, reviewerID).Scan(&count)
	if err != nil {
		return false, err
	}

	return count > 0, nil
}

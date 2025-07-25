package repository

import (
	"database/sql"
	"fmt"
	"tukarkultur/api/models"

	"github.com/jmoiron/sqlx"

	"github.com/google/uuid"
)

type FriendRepository struct {
	db *sqlx.DB
}

func NewFriendRepository(db *sqlx.DB) *FriendRepository {
	return &FriendRepository{db: db}
}

// Existing friend methods (keep as is)
func (r *FriendRepository) Create(friend *models.Friend) error {
	query := `INSERT INTO friends (user_id_1, user_id_2, created_at) VALUES ($1, $2, NOW())`
	_, err := r.db.Exec(query, friend.UserID1, friend.UserID2)
	return err
}

func (r *FriendRepository) GetFriendsByUserID(userID uuid.UUID) ([]models.Friend, error) {
	var friends []models.Friend
	query := `
        SELECT user_id_1, user_id_2, created_at FROM friends 
        WHERE user_id_1 = $1 OR user_id_2 = $1
        ORDER BY created_at DESC
    `
	err := r.db.Select(&friends, query, userID)
	return friends, err
}

func (r *FriendRepository) Delete(userID1, userID2 uuid.UUID) error {
	query := `DELETE FROM friends WHERE (user_id_1 = $1 AND user_id_2 = $2) OR (user_id_1 = $2 AND user_id_2 = $1)`
	_, err := r.db.Exec(query, userID1, userID2)
	return err
}

func (r *FriendRepository) AreFriends(userID1, userID2 uuid.UUID) (bool, error) {
	var count int
	query := `SELECT COUNT(*) FROM friends WHERE (user_id_1 = $1 AND user_id_2 = $2) OR (user_id_1 = $2 AND user_id_2 = $1)`
	err := r.db.Get(&count, query, userID1, userID2)
	return count > 0, err
}

// New friend request methods
func (r *FriendRepository) CreateFriendRequest(friendRequest *models.FriendRequest) error {
	query := `
        INSERT INTO friend_requests (id, requester_id, recipient_id, status, created_at, updated_at)
        VALUES ($1, $2, $3, $4, NOW(), NOW())
    `
	_, err := r.db.Exec(query, friendRequest.ID, friendRequest.RequesterID, friendRequest.RecipientID, friendRequest.Status)
	return err
}

func (r *FriendRepository) GetFriendRequestByID(id uuid.UUID) (*models.FriendRequest, error) {
	var friendRequest models.FriendRequest
	query := `SELECT * FROM friend_requests WHERE id = $1`
	err := r.db.Get(&friendRequest, query, id)
	if err != nil {
		return nil, err
	}
	return &friendRequest, nil
}

func (r *FriendRepository) GetFriendRequestByUsers(requesterID, recipientID uuid.UUID) (*models.FriendRequest, error) {
	var friendRequest models.FriendRequest
	query := `
        SELECT * FROM friend_requests 
        WHERE (requester_id = $1 AND recipient_id = $2) 
           OR (requester_id = $2 AND recipient_id = $1)
    `
	err := r.db.Get(&friendRequest, query, requesterID, recipientID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &friendRequest, nil
}

func (r *FriendRepository) GetPendingFriendRequests(userID uuid.UUID) ([]models.FriendRequest, error) {
	var requests []models.FriendRequest
	query := `
        SELECT * FROM friend_requests 
        WHERE recipient_id = $1 AND status = 'pending'
        ORDER BY created_at DESC
    `
	err := r.db.Select(&requests, query, userID)
	return requests, err
}

func (r *FriendRepository) GetSentFriendRequests(userID uuid.UUID) ([]models.FriendRequest, error) {
	var requests []models.FriendRequest
	query := `
        SELECT * FROM friend_requests 
        WHERE requester_id = $1
        ORDER BY created_at DESC
    `
	err := r.db.Select(&requests, query, userID)
	return requests, err
}

func (r *FriendRepository) UpdateFriendRequestStatus(id uuid.UUID, status string) error {
	query := `
        UPDATE friend_requests 
        SET status = $1, updated_at = NOW()
        WHERE id = $2
    `
	result, err := r.db.Exec(query, status, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("friend request not found")
	}

	return nil
}

func (r *FriendRepository) DeleteFriendRequest(id uuid.UUID) error {
	query := `DELETE FROM friend_requests WHERE id = $1`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("friend request not found")
	}

	return nil
}

// Helper method to accept friend request and create friendship
func (r *FriendRepository) AcceptFriendRequest(requestID uuid.UUID) error {
	tx, err := r.db.Beginx()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Get the friend request
	var friendRequest models.FriendRequest
	query := `SELECT * FROM friend_requests WHERE id = $1 AND status = 'pending'`
	err = tx.Get(&friendRequest, query, requestID)
	if err != nil {
		return err
	}

	// Update request status to accepted
	query = `UPDATE friend_requests SET status = 'accepted', updated_at = NOW() WHERE id = $1`
	_, err = tx.Exec(query, requestID)
	if err != nil {
		return err
	}

	// Create friendship (both directions for easier querying)
	query = `INSERT INTO friends (user_id_1, user_id_2, created_at) VALUES ($1, $2, NOW())`
	_, err = tx.Exec(query, friendRequest.RequesterID, friendRequest.RecipientID)
	if err != nil {
		return err
	}

	query = `INSERT INTO friends (user_id_1, user_id_2, created_at) VALUES ($1, $2, NOW())`
	_, err = tx.Exec(query, friendRequest.RecipientID, friendRequest.RequesterID)
	if err != nil {
		return err
	}

	return tx.Commit()
}

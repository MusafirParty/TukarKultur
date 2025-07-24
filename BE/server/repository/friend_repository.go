package repository

import (
	"database/sql"
	"time"
	"tukarkultur/api/models"

	"github.com/google/uuid"
)

type FriendRepository struct {
	db *sql.DB
}

func NewFriendRepository(db *sql.DB) *FriendRepository {
	return &FriendRepository{db: db}
}

func (r *FriendRepository) Create(friend *models.Friend) error {
	query := `
        INSERT INTO friends (user_id_1, user_id_2, created_at) 
        VALUES ($1, $2, $3)
        RETURNING created_at`

	friend.CreatedAt = time.Now()

	err := r.db.QueryRow(
		query,
		friend.UserID1,
		friend.UserID2,
		friend.CreatedAt,
	).Scan(&friend.CreatedAt)

	return err
}

func (r *FriendRepository) GetFriendsByUserID(userID uuid.UUID) ([]*models.Friend, error) {
	query := `
        SELECT user_id_1, user_id_2, created_at 
        FROM friends 
        WHERE user_id_1 = $1 OR user_id_2 = $1
        ORDER BY created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var friends []*models.Friend
	for rows.Next() {
		friend := &models.Friend{}
		err := rows.Scan(
			&friend.UserID1,
			&friend.UserID2,
			&friend.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		friends = append(friends, friend)
	}

	return friends, nil
}

func (r *FriendRepository) GetAll() ([]*models.Friend, error) {
	query := `
        SELECT user_id_1, user_id_2, created_at 
        FROM friends 
        ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var friends []*models.Friend
	for rows.Next() {
		friend := &models.Friend{}
		err := rows.Scan(
			&friend.UserID1,
			&friend.UserID2,
			&friend.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		friends = append(friends, friend)
	}

	return friends, nil
}

func (r *FriendRepository) Delete(userID1, userID2 uuid.UUID) error {
	query := `
        DELETE FROM friends 
        WHERE (user_id_1 = $1 AND user_id_2 = $2) 
           OR (user_id_1 = $2 AND user_id_2 = $1)`

	_, err := r.db.Exec(query, userID1, userID2)
	return err
}

func (r *FriendRepository) Exists(userID1, userID2 uuid.UUID) (bool, error) {
	query := `
        SELECT COUNT(*) FROM friends 
        WHERE (user_id_1 = $1 AND user_id_2 = $2) 
           OR (user_id_1 = $2 AND user_id_2 = $1)`

	var count int
	err := r.db.QueryRow(query, userID1, userID2).Scan(&count)
	if err != nil {
		return false, err
	}

	return count > 0, nil
}

func (r *FriendRepository) GetFriendsWithUserDetails(userID uuid.UUID) ([]*models.FriendResponse, error) {
	query := `
        SELECT f.user_id_1, f.user_id_2, f.created_at,
               u1.id, u1.username, u1.email, u1.full_name, u1.profile_picture_url, u1.bio, u1.city, u1.country,
               u2.id, u2.username, u2.email, u2.full_name, u2.profile_picture_url, u2.bio, u2.city, u2.country
        FROM friends f
        JOIN users u1 ON f.user_id_1 = u1.id
        JOIN users u2 ON f.user_id_2 = u2.id
        WHERE f.user_id_1 = $1 OR f.user_id_2 = $1
        ORDER BY f.created_at DESC`

	rows, err := r.db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var friends []*models.FriendResponse
	for rows.Next() {
		friend := &models.FriendResponse{}
		user1 := &models.User{}
		user2 := &models.User{}

		err := rows.Scan(
			&friend.UserID1, &friend.UserID2, &friend.CreatedAt,
			&user1.ID, &user1.Username, &user1.Email, &user1.FullName, &user1.ProfilePictureURL, &user1.Bio, &user1.City, &user1.Country,
			&user2.ID, &user2.Username, &user2.Email, &user2.FullName, &user2.ProfilePictureURL, &user2.Bio, &user2.City, &user2.Country,
		)
		if err != nil {
			return nil, err
		}

		friend.User1 = user1
		friend.User2 = user2
		friends = append(friends, friend)
	}

	return friends, nil
}

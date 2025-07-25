package repository

import (
	"time"
	"tukarkultur/api/models"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type UserRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(user *models.User) error {
	query := `
        INSERT INTO users (
            id, username, email, password_hash, full_name, 
            profile_picture_url, bio, age, city, country, interests,
            latitude, longitude, location_updated_at, 
            total_interactions, average_rating, updated_at, created_at
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
        ) RETURNING created_at, updated_at`

	now := time.Now()
	user.CreatedAt = now
	user.UpdatedAt = now

	err := r.db.QueryRow(
		query,
		user.ID, user.Username, user.Email, user.PasswordHash, user.FullName,
		user.ProfilePictureURL, user.Bio, user.Age, user.City, user.Country, user.Interests,
		user.Latitude, user.Longitude, user.LocationUpdatedAt,
		user.TotalInteractions, user.AverageRating, user.UpdatedAt, user.CreatedAt,
	).Scan(&user.CreatedAt, &user.UpdatedAt)

	return err
}

func (r *UserRepository) GetByID(id uuid.UUID) (*models.User, error) {
	query := `
        SELECT id, username, email, password_hash, full_name,
               profile_picture_url, bio, age, city, country, interests,
               latitude, longitude, location_updated_at,
               total_interactions, average_rating, updated_at, created_at
        FROM users WHERE id = $1`

	user := &models.User{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.FullName,
		&user.ProfilePictureURL, &user.Bio, &user.Age, &user.City, &user.Country, &user.Interests,
		&user.Latitude, &user.Longitude, &user.LocationUpdatedAt,
		&user.TotalInteractions, &user.AverageRating, &user.UpdatedAt, &user.CreatedAt,
	)

	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *UserRepository) GetAll() ([]*models.User, error) {
	query := `
        SELECT id, username, email, password_hash, full_name,
               profile_picture_url, bio, age, city, country, interests,
               latitude, longitude, location_updated_at,
               total_interactions, average_rating, updated_at, created_at
        FROM users ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*models.User
	for rows.Next() {
		user := &models.User{}
		err := rows.Scan(
			&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.FullName,
			&user.ProfilePictureURL, &user.Bio, &user.Age, &user.City, &user.Country, &user.Interests,
			&user.Latitude, &user.Longitude, &user.LocationUpdatedAt,
			&user.TotalInteractions, &user.AverageRating, &user.UpdatedAt, &user.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil
}

func (r *UserRepository) Update(user *models.User) error {
	query := `
        UPDATE users SET
            username = $2, email = $3, full_name = $4,
            profile_picture_url = $5, bio = $6, age = $7, city = $8, country = $9,
            interests = $10, latitude = $11, longitude = $12, location_updated_at = $13,
            updated_at = $14
        WHERE id = $1`

	user.UpdatedAt = time.Now()

	_, err := r.db.Exec(
		query,
		user.ID, user.Username, user.Email, user.FullName,
		user.ProfilePictureURL, user.Bio, user.Age, user.City, user.Country,
		user.Interests, user.Latitude, user.Longitude, user.LocationUpdatedAt,
		user.UpdatedAt,
	)

	return err
}

func (r *UserRepository) UpdateLocation(id *uuid.UUID, latitude *float64, longitude *float64) error {
	query := `
        UPDATE users 
        SET latitude = $2, 
            longitude = $3, 
            location_updated_at = $4, 
            updated_at = $4
        WHERE id = $1`

	now := time.Now()
	_, err := r.db.Exec(query, id, latitude, longitude, now)
	return err
}
func (r *UserRepository) Delete(id uuid.UUID) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.Exec(query, id)
	return err
}

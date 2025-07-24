package repository

import (
	"database/sql"
	"tukarkultur/api/models"

	"github.com/google/uuid"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(user *models.User) error {
	query := `
        INSERT INTO users (username, email, password_hash, full_name, profile_picture_url, bio, age, city, country, interests, latitude, longitude)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
        RETURNING id, created_at, updated_at, total_interactions, average_rating`

	return r.db.QueryRow(query,
		user.Username, user.Email, user.PasswordHash, user.FullName,
		user.ProfilePictureURL, user.Bio, user.Age, user.City, user.Country,
		user.Interests, user.Latitude, user.Longitude,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt, &user.TotalInteractions, &user.AverageRating)
}

func (r *UserRepository) GetByID(id uuid.UUID) (*models.User, error) {
	user := &models.User{}
	query := `
        SELECT id, username, email, password_hash, full_name, profile_picture_url, bio, age, city, country,
               interests, latitude, longitude, location_updated_at, total_interactions, average_rating,
               updated_at, created_at
        FROM users WHERE id = $1`

	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.FullName,
		&user.ProfilePictureURL, &user.Bio, &user.Age, &user.City, &user.Country,
		&user.Interests, &user.Latitude, &user.Longitude, &user.LocationUpdatedAt,
		&user.TotalInteractions, &user.AverageRating, &user.UpdatedAt, &user.CreatedAt)

	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) Update(user *models.User) error {
	query := `
        UPDATE users SET 
            username = $2, email = $3, full_name = $4, profile_picture_url = $5,
            bio = $6, age = $7, city = $8, country = $9, interests = $10, 
            latitude = $11, longitude = $12, updated_at = CURRENT_TIMESTAMP
        WHERE id = $1`

	_, err := r.db.Exec(query, user.ID, user.Username, user.Email, user.FullName,
		user.ProfilePictureURL, user.Bio, user.Age, user.City, user.Country,
		user.Interests, user.Latitude, user.Longitude)
	return err
}

func (r *UserRepository) Delete(id uuid.UUID) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.Exec(query, id)
	return err
}

func (r *UserRepository) GetAll() ([]*models.User, error) {
	query := `
        SELECT id, username, email, full_name, profile_picture_url, bio, age, city, country,
               interests, latitude, longitude, total_interactions, average_rating, created_at
        FROM users ORDER BY created_at DESC`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*models.User
	for rows.Next() {
		user := &models.User{}
		err := rows.Scan(&user.ID, &user.Username, &user.Email, &user.FullName,
			&user.ProfilePictureURL, &user.Bio, &user.Age, &user.City, &user.Country,
			&user.Interests, &user.Latitude, &user.Longitude,
			&user.TotalInteractions, &user.AverageRating, &user.CreatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}

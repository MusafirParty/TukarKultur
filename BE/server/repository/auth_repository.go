package repository

import (
	"fmt"
	"time"
	"tukarkultur/api/models"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type AuthRepository struct {
	db *sqlx.DB
}

func NewAuthRepository(db *sqlx.DB) *AuthRepository {
	return &AuthRepository{db: db}
}

func (r *AuthRepository) CreateSession(userID uuid.UUID, token string) error {
	expiresAt := time.Now().Add(24 * time.Hour)
	query := `INSERT INTO auth_sessions (user_id, token, expires_at) VALUES ($1, $2, $3)`

	_, err := r.db.Exec(query, userID, token, expiresAt)
	return err
}

func (r *AuthRepository) DeleteSession(token string) error {
	query := `DELETE FROM auth_sessions WHERE token = $1`
	_, err := r.db.Exec(query, token)
	return err
}

func (r *AuthRepository) GetPasswordHash(email string) (string, error) {
	var passwordHash string
	query := `SELECT password_hash FROM users WHERE email = $1`

	err := r.db.QueryRow(query, email).Scan(&passwordHash)
	return passwordHash, err
}

func (r *AuthRepository) GetSessionByToken(token string) (*models.AuthSession, error) {
	var session models.AuthSession
	query := `SELECT id, user_id, token, expires_at, created_at, updated_at 
              FROM auth_sessions 
              WHERE token = $1 AND expires_at > NOW()`

	err := r.db.QueryRow(query, token).Scan(
		&session.ID, &session.UserID, &session.Token,
		&session.ExpiresAt, &session.CreatedAt, &session.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to get session: %w", err)
	}
	return &session, nil
}

func (r *AuthRepository) DeleteUserSessions(userID uuid.UUID) error {
	query := `DELETE FROM auth_sessions WHERE user_id = $1`
	_, err := r.db.Exec(query, userID)
	return err
}

func (r *AuthRepository) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	query := `SELECT id, username, email, full_name, profile_picture_url, bio, age, city, country, 
              interests, latitude, longitude, location_updated_at, total_interactions, 
              average_rating, created_at, updated_at FROM users WHERE email = $1`

	err := r.db.QueryRow(query, email).Scan(
		&user.ID, &user.Username, &user.Email, &user.FullName, &user.ProfilePictureURL,
		&user.Bio, &user.Age, &user.City, &user.Country, &user.Interests,
		&user.Latitude, &user.Longitude, &user.LocationUpdatedAt,
		&user.TotalInteractions, &user.AverageRating, &user.CreatedAt, &user.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return &user, nil
}

func (r *AuthRepository) CreateUserWithPassword(user *models.User, passwordHash string) error {
	// Generate UUID for new user
	user.ID = uuid.New()

	query := `INSERT INTO users (id, username, email, password_hash, full_name, bio, age, city, country, interests) 
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
              RETURNING created_at, updated_at`

	err := r.db.QueryRow(query,
		user.ID, user.Username, user.Email, passwordHash, user.FullName,
		user.Bio, user.Age, user.City, user.Country, user.Interests,
	).Scan(&user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	return nil
}

func (r *AuthRepository) EmailExists(email string) (bool, error) {
	var count int
	query := `SELECT COUNT(*) FROM users WHERE email = $1`
	err := r.db.QueryRow(query, email).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("failed to check email existence: %w", err)
	}
	return count > 0, nil
}

func (r *AuthRepository) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	query := `SELECT id, username, email, full_name, profile_picture_url, bio, age, city, country, 
              interests, latitude, longitude, location_updated_at, total_interactions, 
              average_rating, created_at, updated_at FROM users WHERE username = $1`

	err := r.db.QueryRow(query, username).Scan(
		&user.ID, &user.Username, &user.Email, &user.FullName, &user.ProfilePictureURL,
		&user.Bio, &user.Age, &user.City, &user.Country, &user.Interests,
		&user.Latitude, &user.Longitude, &user.LocationUpdatedAt,
		&user.TotalInteractions, &user.AverageRating, &user.CreatedAt, &user.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return &user, nil
}

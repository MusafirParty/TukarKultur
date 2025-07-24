package models

import (
    "database/sql/driver"
    "encoding/json"
    "errors"
    "time"
    "github.com/google/uuid"
)

type StringArray []string

func (s *StringArray) Scan(value interface{}) error {
    if value == nil {
        *s = nil
        return nil
    }
    switch v := value.(type) {
    case []byte:
        return json.Unmarshal(v, s)
    case string:
        return json.Unmarshal([]byte(v), s)
    }
    return errors.New("cannot scan into StringArray")
}

func (s StringArray) Value() (driver.Value, error) {
    return json.Marshal(s)
}

type User struct {
    ID                  uuid.UUID    `json:"id" db:"id"`
    Username            string       `json:"username" db:"username"`
    Email               string       `json:"email" db:"email"`
    PasswordHash        string       `json:"-" db:"password_hash"`
    FullName            string       `json:"full_name" db:"full_name"`
    ProfilePictureURL   *string      `json:"profile_picture_url" db:"profile_picture_url"`
    Bio                 *string      `json:"bio" db:"bio"`
    Age                 *int         `json:"age" db:"age"`
    City                *string      `json:"city" db:"city"`
    Country             *string      `json:"country" db:"country"`
    Interests           StringArray  `json:"interests" db:"interests"`
    Latitude            *float64     `json:"latitude" db:"latitude"`
    Longitude           *float64     `json:"longitude" db:"longitude"`
    LocationUpdatedAt   *time.Time   `json:"location_updated_at" db:"location_updated_at"`
    TotalInteractions   int          `json:"total_interactions" db:"total_interactions"`
    AverageRating       float64      `json:"average_rating" db:"average_rating"`
    UpdatedAt           time.Time    `json:"updated_at" db:"updated_at"`
    CreatedAt           time.Time    `json:"created_at" db:"created_at"`
}

type CreateUserRequest struct {
    Username  string      `json:"username" binding:"required"`
    Email     string      `json:"email" binding:"required"`
    Password  string      `json:"password" binding:"required"`
    FullName  string      `json:"full_name" binding:"required"`
    Bio       *string     `json:"bio"`
    Age       *int        `json:"age"`
    City      *string     `json:"city"`
    Country   *string     `json:"country"`
    Interests StringArray `json:"interests"`
}
package database

import (
    "database/sql"
    "log"
    _ "github.com/lib/pq" // PostgreSQL driver
)

func NewConnection(databaseURL string) (*sql.DB, error) {
    db, err := sql.Open("postgres", databaseURL)
    if err != nil {
        return nil, err
    }

    if err := db.Ping(); err != nil {
        return nil, err
    }

    log.Println("Database connected successfully")
    return db, nil
}
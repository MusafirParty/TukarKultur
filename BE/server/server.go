package main

import (
    "log"
    "os"
    "github.com/gin-gonic/gin"
    "github.com/joho/godotenv"
    "your-project/database"
    "your-project/handlers"
    "your-project/repository"
    "your-project/routes"
)

func main() {
    // Load environment variables
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found, using system environment variables")
    }

    // Get environment variables
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    databaseURL := os.Getenv("DATABASE_URL")
    if databaseURL == "" {
        log.Fatal("DATABASE_URL environment variable is required")
    }

    // Initialize database
    db, err := database.NewConnection(databaseURL)
    if err != nil {
        log.Fatal("Failed to connect to database:", err)
    }
    defer db.Close()

    // Initialize repositories
    userRepo := repository.NewUserRepository(db)

    // Initialize handlers
    userHandler := handlers.NewUserHandler(userRepo)

    // Setup Gin router
    router := gin.Default()

    // CORS middleware (simple version)
    router.Use(func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        
        c.Next()
    })

    // Setup routes
    routes.SetupRoutes(router, userHandler)

    // Start server
    log.Printf("🚀 Server starting on port %s", port)
    log.Printf("📊 Health check: http://localhost:%s/api/v1/health", port)
    log.Fatal(router.Run(":" + port))
}
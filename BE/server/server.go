package main

import (
	"log"
	"os"
	"tukarkultur/api/chat_socket"
	"tukarkultur/api/chat_socket"
	"tukarkultur/api/database"
	"tukarkultur/api/handlers"
	"tukarkultur/api/repository"
	"tukarkultur/api/routes"
	"tukarkultur/api/services"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Get environment variables
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
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
	friendRepo := repository.NewFriendRepository(db)
	meetupRepo := repository.NewMeetupRepository(db)
	interactionRepo := repository.NewInteractionRepository(db)
	authRepo := repository.NewAuthRepository(db)
	authRepo := repository.NewAuthRepository(db)

	// Initialize AI services
	geminiService := services.NewGeminiService()
	openaiService := services.NewOpenAIService()
	cloudinaryService := services.NewCloudinaryService()

	// Initialize handlers
	userHandler := handlers.NewUserHandler(userRepo)
	friendHandler := handlers.NewFriendHandler(friendRepo)
	meetupHandler := handlers.NewMeetupHandler(meetupRepo)
	interactionHandler := handlers.NewInteractionHandler(interactionRepo, meetupRepo)
	geminiHandler := handlers.NewGeminiHandler(geminiService)
	openaiHandler := handlers.NewOpenAIHandler(openaiService)
	authHandler := handlers.NewAuthHandler(authRepo)
	geminiHandler := handlers.NewGeminiHandler(geminiService)
	openaiHandler := handlers.NewOpenAIHandler(openaiService)
	authHandler := handlers.NewAuthHandler(authRepo)

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

	chat_socket.Run()

	chat_socket.Run()

	// Setup routes
	routes.SetupRoutes(router, userHandler, geminiHandler, openaiHandler, friendHandler, meetupHandler, interactionHandler, authHandler)
	routes.SetupRoutes(router, userHandler, geminiHandler, openaiHandler, friendHandler, meetupHandler, interactionHandler, authHandler)

	// Start server
	log.Printf("Server starting on port %s", port)
	log.Printf("Health check: http://localhost:%s/api/v1/health", port)
	log.Printf("Server starting on port %s", port)
	log.Printf("Health check: http://localhost:%s/api/v1/health", port)
	log.Fatal(router.Run(":" + port))
}

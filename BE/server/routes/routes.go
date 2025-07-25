package routes

import (
	"net/http"
	"tukarkultur/api/chat_socket"
	"tukarkultur/api/handlers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	router *gin.Engine,
	userHandler *handlers.UserHandler,
	geminiHandler *handlers.GeminiHandler,
	openaiHandler *handlers.OpenAIHandler,
	friendHandler *handlers.FriendHandler,
	meetupHandler *handlers.MeetupHandler,
	interactionHandler *handlers.InteractionHandler,
	authHandler *handlers.AuthHandler, // Add auth handler
) {
	// Health check endpoint
	router.GET("/api/v1/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"message": "Server is running",
		})
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Auth routes (no authentication required)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/logout", authHandler.Logout)
		}

		// User routes
		users := v1.Group("/users")
		{
			users.POST("", userHandler.CreateUser)
			users.GET("", userHandler.GetAllUsers)
			users.GET("/:id", userHandler.GetUser)
			users.PUT("/:id", userHandler.UpdateUser)
			users.PUT("/location/:id", userHandler.UpdateLocation)
			users.DELETE("/:id", userHandler.DeleteUser)
			users.POST("/:id/profile-picture", userHandler.UploadProfilePicture)
		}

		// User routes
		chat := v1.Group("/chat")
		{
			chat.GET("", chat_socket.HandleConnection)
		}

		// Friend routes
		friends := v1.Group("/friends")
		{
			friends.GET("", friendHandler.GetAllFriends)
			friends.POST("", friendHandler.CreateFriend)
			friends.DELETE("", friendHandler.DeleteFriend)
		}

		// Friend request routes
		friendRequests := v1.Group("/friend-requests")
		{
			friendRequests.POST("", friendHandler.SendFriendRequest)
			friendRequests.PUT("/:id", friendHandler.RespondToFriendRequest)
			friendRequests.GET("/received", friendHandler.GetReceivedFriendRequests)
			friendRequests.GET("/sent", friendHandler.GetSentFriendRequests)
		}

		// Meetup routes
		meetups := v1.Group("/meetups")
		{
			meetups.POST("", meetupHandler.CreateMeetup)
			meetups.GET("", meetupHandler.GetAllMeetups)
			meetups.GET("/:id", meetupHandler.GetMeetup)
			meetups.GET("/user/:id", meetupHandler.GetMeetupsByUserID)
			meetups.PUT("/:id", meetupHandler.UpdateMeetup)
			meetups.PUT("/:id/confirm", meetupHandler.ConfirmMeetup)
			meetups.PUT("/:id/complete", meetupHandler.CompleteMeetup)
			meetups.DELETE("/:id", meetupHandler.DeleteMeetup)
		}

		interactions := v1.Group("/interactions")
		{
			interactions.POST("", interactionHandler.CreateInteraction)
			interactions.GET("", interactionHandler.GetAllInteractions)
			interactions.GET("/:id", interactionHandler.GetInteraction)
			interactions.GET("/meetup/:id", interactionHandler.GetInteractionsByMeetupID)
			interactions.GET("/user/:id", interactionHandler.GetInteractionsByUserID)
			interactions.GET("/reviews/:id", interactionHandler.GetReviewsForUser)
			interactions.GET("/stats/:id", interactionHandler.GetUserRatingStats)
			interactions.PUT("/:id", interactionHandler.UpdateInteractionWithPhoto)
			interactions.DELETE("/:id", interactionHandler.DeleteInteraction)
		}

		// Gemini AI routes
		gemini := v1.Group("/gemini")
		{
			gemini.POST("/generate", geminiHandler.GenerateText)
			gemini.POST("/chat", geminiHandler.GenerateChat)
			gemini.GET("/models", geminiHandler.GetModels)
			gemini.GET("/health", geminiHandler.HealthCheck)
		}

		// OpenAI routes
		openai := v1.Group("/openai")
		{
			openai.POST("/generate", openaiHandler.GenerateText)
			openai.POST("/chat", openaiHandler.GenerateChat)
			openai.GET("/models", openaiHandler.GetModels)
			openai.GET("/health", openaiHandler.HealthCheck)
		}
	}
}

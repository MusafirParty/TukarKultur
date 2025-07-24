package routes

import (
	"tukarkultur/api/handlers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine, userHandler *handlers.UserHandler, geminiHandler *handlers.GeminiHandler, openaiHandler *handlers.OpenAIHandler) {
	// API versioning
	api := router.Group("/api/v1")
	{
		// User routes
		users := api.Group("/users")
		{
			users.POST("", userHandler.CreateUser)       // POST /api/v1/users
			users.GET("/:id", userHandler.GetUser)       // GET /api/v1/users/:id
			users.GET("", userHandler.GetAllUsers)       // GET /api/v1/users
			users.PUT("/:id", userHandler.UpdateUser)    // PUT /api/v1/users/:id
			users.DELETE("/:id", userHandler.DeleteUser) // DELETE /api/v1/users/:id
		}

		// Gemini AI routes
		gemini := api.Group("/gemini")
		{
			gemini.POST("/generate", geminiHandler.GenerateText)   // POST /api/v1/gemini/generate
			gemini.POST("/chat", geminiHandler.GenerateChat)       // POST /api/v1/gemini/chat
			gemini.GET("/models", geminiHandler.GetModels)         // GET /api/v1/gemini/models
			gemini.GET("/health", geminiHandler.HealthCheck)       // GET /api/v1/gemini/health
		}

		// OpenAI AI routes
		openai := api.Group("/openai")
		{
			openai.POST("/generate", openaiHandler.GenerateText)   // POST /api/v1/openai/generate
			openai.POST("/chat", openaiHandler.GenerateChat)       // POST /api/v1/openai/chat
			openai.GET("/models", openaiHandler.GetModels)         // GET /api/v1/openai/models
			openai.GET("/health", openaiHandler.HealthCheck)       // GET /api/v1/openai/health
		}

		// Health check
		api.GET("/health", func(c *gin.Context) {
			c.JSON(200, gin.H{"status": "ok", "service": "GarudaTK API"})
		})
	}
}

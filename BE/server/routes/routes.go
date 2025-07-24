package routes

import (
	"net/http"
	"tukarkultur/api/handlers"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine, userHandler *handlers.UserHandler, friendHandler *handlers.FriendHandler) {
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
		// User routes
		users := v1.Group("/users")
		{
			users.POST("", userHandler.CreateUser)
			users.GET("", userHandler.GetAllUsers)
			users.GET("/:id", userHandler.GetUser)
			users.PUT("/:id", userHandler.UpdateUser)
			users.DELETE("/:id", userHandler.DeleteUser)
		}

		// Friend routes
		friends := v1.Group("/friends")
		{
			friends.POST("", friendHandler.CreateFriend)
			friends.GET("", friendHandler.GetAllFriends)
			friends.GET("/user/:id", friendHandler.GetFriendsByUserID)
			friends.DELETE("", friendHandler.DeleteFriend)
		}
	}
}

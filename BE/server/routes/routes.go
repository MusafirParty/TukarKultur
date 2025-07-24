package routes

import (
    "github.com/gin-gonic/gin"
    "your-project/handlers"
)

func SetupRoutes(router *gin.Engine, userHandler *handlers.UserHandler) {
    // API versioning
    api := router.Group("/api/v1")
    {
        // User routes
        users := api.Group("/users")
        {
            users.POST("", userHandler.CreateUser)           // POST /api/v1/users
            users.GET("/:id", userHandler.GetUser)           // GET /api/v1/users/:id
            users.GET("", userHandler.GetAllUsers)           // GET /api/v1/users
            users.PUT("/:id", userHandler.UpdateUser)        // PUT /api/v1/users/:id
            users.DELETE("/:id", userHandler.DeleteUser)     // DELETE /api/v1/users/:id
        }

        // Health check
        api.GET("/health", func(c *gin.Context) {
            c.JSON(200, gin.H{"status": "ok", "service": "GarudaTK API"})
        })
    }
}
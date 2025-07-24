package routes

import (
	"tukarkultur/api/handlers"

	"github.com/gin-gonic/gin"
)

func RegisterUserRoutes(router *gin.Engine) {
	websocketRoutes := router.Group("/ws")
	{
		websocketRoutes.GET("/", handlers.ConnectWebsocket)
	}
}

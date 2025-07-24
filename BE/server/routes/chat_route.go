package routes

import (
	"tukarkultur/api/controllers"

	"github.com/gin-gonic/gin"
)

func RegisterUserRoutes(router *gin.Engine) {
	websocketRoutes := router.Group("/ws")
	{
		websocketRoutes.GET("/", controllers.ConnectWebsocket)
	}
}

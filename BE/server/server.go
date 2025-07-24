package main

import (
	"tukarkultur/api/models"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
	clients = make(map[*websocket.Conn]bool)
	broadcast = make(chan models.Message)
)

func main() {
	router := gin.Default()
	router.
}

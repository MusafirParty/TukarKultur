package handlers

import (
	"fmt"

	"github.com/gin-gonic/gin"
)

func ConnectWebsocket(c *gin.Context) {
	conn, err := utils.upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		fmt.Println("Upgrade: ", err)
	}
	defer conn.Close()

	upgrader.clients[conn] = true

	for {
		var msg Message
		err := conn.ReadJSON(&msg)
		if err != nil {
			fmt.Println("Message: ", err)
			delete(upgrader.clients)
		}
	}
}

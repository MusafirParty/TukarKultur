package chat_socket

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Client struct {
	name string
	conn *websocket.Conn
}

func NewClient(name string, conn *websocket.Conn) *Client {
	return &Client{name, conn}
}

var clients = make(map[*Client]bool)
var broadcast = make(chan Message)

type Message struct {
	Sender    string `json:"sender"`
	Receiver  string `json:"receiver"`
	Text      string `json:"text"`
	Image_url string `json:"image_url"`
}

func HandleConnection(c *gin.Context) {
	client_id := c.Query("id")
	if client_id == "" {
		log.Println("Invalid: No Client ID")
		return
	}
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Upgrader Error: ", err)
		return
	}
	defer conn.Close()

	client := NewClient(client_id, conn)
	clients[client] = true

	for {
		var msg Message
		err := client.conn.ReadJSON(&msg)
		if err != nil {
			log.Println("Read JSON: ", err)
			delete(clients, client)
			return
		}

		broadcast <- msg
	}
}

func handleMessages() {
	for {
		msg := <-broadcast

		for client := range clients {
			if client.name == msg.Receiver {
				err := client.conn.WriteJSON(msg)
				if err != nil {
					fmt.Println(err)
					client.conn.Close()
					delete(clients, client)
				}
				break
			}
		}
	}
}

func Run() {
	go handleMessages()
}

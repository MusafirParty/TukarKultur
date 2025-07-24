package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sort"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

type Room struct {
	Clients map[*websocket.Conn]string
	Lock    sync.Mutex
}

func (r *Room) broadcast(msg Message) {
	r.Lock.Lock()
	defer r.Lock.Unlock()

	for conn := range r.Clients {
		if err := conn.WriteJSON(msg); err != nil {
			log.Println("Error sending message:", err)
			conn.Close()
			delete(r.Clients, conn)
		}
	}
}

type Message struct {
	Sender    string `json:"from"`
	Image_url string `json:"image_url"`
	Text      string `json:"text"`
}

var (
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}
	rooms = make(map[string]*Room)
	rLock sync.Mutex
)

func makeRoomKey(user1, user2 string) string {
	users := []string{user1, user2}
	sort.Strings(users)
	return fmt.Sprintf("%s_%s", users[0], users[1])
}

func CreateRoom(c *gin.Context) {
	from := c.Query("From")
	to := c.Query("To")

	if from == "" || to == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "From and To query parameters are required"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Upgrade Error:", err)
		return
	}
	defer conn.Close()

	roomKey := makeRoomKey(from, to)
	rLock.Lock()
	room, exists := rooms[roomKey]
	if !exists {
		room = &Room{Clients: make(map[*websocket.Conn]string)}
		rooms[roomKey] = room
		log.Printf("Created new room: %s", roomKey)
	}
	rLock.Unlock()

	room.Lock.Lock()
	room.Clients[conn] = from
	room.Lock.Unlock()

	// Listen for messages
	for {
		_, msgBytes, err := conn.ReadMessage()
		if err != nil {
			log.Printf("Connection closed for %s: %v", from, err)
			break
		}

		var msg Message
		if err := json.Unmarshal(msgBytes, &msg); err != nil {
			log.Println("Invalid message format:", err)
			continue
		}
		msg.Sender = from

		room.broadcast(msg)
	}

	// Cleanup when user disconnects
	room.Lock.Lock()
	delete(room.Clients, conn)
	room.Lock.Unlock()
}

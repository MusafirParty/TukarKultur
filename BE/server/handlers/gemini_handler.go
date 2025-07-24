package handlers

import (
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/services"

	"github.com/gin-gonic/gin"
)

type GeminiHandler struct {
	geminiService *services.GeminiService
}

func NewGeminiHandler(geminiService *services.GeminiService) *GeminiHandler {
	return &GeminiHandler{
		geminiService: geminiService,
	}
}

// GenerateText handles text generation requests
// POST /api/v1/ai/generate
func (h *GeminiHandler) GenerateText(c *gin.Context) {
	var req models.GeminiRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"details": err.Error(),
		})
		return
	}

	// Validate required fields
	if req.Prompt == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Prompt is required",
		})
		return
	}

	// Call Gemini service
	response, err := h.geminiService.GenerateText(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to generate text",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    response,
	})
}

// GenerateChat handles chat conversation requests
// POST /api/v1/ai/chat
func (h *GeminiHandler) GenerateChat(c *gin.Context) {
	var req models.ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"details": err.Error(),
		})
		return
	}

	// Validate required fields
	if len(req.Messages) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "At least one message is required",
		})
		return
	}

	// Validate messages format
	for i, msg := range req.Messages {
		if msg.Role == "" || msg.Content == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Each message must have both 'role' and 'content' fields",
				"index": i,
			})
			return
		}
		if msg.Role != "user" && msg.Role != "model" {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Message role must be either 'user' or 'model'",
				"index": i,
			})
			return
		}
	}

	// Call Gemini service
	response, err := h.geminiService.GenerateChat(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to generate chat response",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    response,
	})
}

// GetModels returns available AI models
// GET /api/v1/ai/models
func (h *GeminiHandler) GetModels(c *gin.Context) {
	models := []map[string]string{
		{
			"id":          "gemini-1.5-flash-latest",
			"name":        "Gemini 1.5 Flash",
			"description": "Fast and efficient text generation model",
			"type":        "text-generation",
		},
		{
			"id":          "gemini-1.5-pro-latest",
			"name":        "Gemini 1.5 Pro",
			"description": "Advanced text generation with enhanced reasoning",
			"type":        "text-generation",
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    gin.H{"models": models},
	})
}

// HealthCheck for AI service
// GET /api/v1/ai/health
func (h *GeminiHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"service": "Gemini AI Agent",
		"version": "1.0.0",
	})
}

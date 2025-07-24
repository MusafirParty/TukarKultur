package handlers

import (
	"net/http"
	"tukarkultur/api/models"
	"tukarkultur/api/services"

	"github.com/gin-gonic/gin"
)

type OpenAIHandler struct {
	openaiService *services.OpenAIService
}

func NewOpenAIHandler(openaiService *services.OpenAIService) *OpenAIHandler {
	return &OpenAIHandler{
		openaiService: openaiService,
	}
}

// GenerateText handles text generation requests
// POST /api/v1/openai/generate
func (h *OpenAIHandler) GenerateText(c *gin.Context) {
	var req models.OpenAIRequest
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

	// Call OpenAI service
	response, err := h.openaiService.GenerateText(&req)
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
// POST /api/v1/openai/chat
func (h *OpenAIHandler) GenerateChat(c *gin.Context) {
	var req models.OpenAIChatRequest
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
		if msg.Role != "user" && msg.Role != "assistant" && msg.Role != "system" {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Message role must be 'user', 'assistant', or 'system'",
				"index": i,
			})
			return
		}
	}

	// Call OpenAI service
	response, err := h.openaiService.GenerateChat(&req)
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

// GetModels returns available OpenAI models
// GET /api/v1/openai/models
func (h *OpenAIHandler) GetModels(c *gin.Context) {
	models := []map[string]interface{}{
		{
			"id":          "gpt-4",
			"name":        "GPT-4",
			"description": "Most advanced GPT model with superior reasoning",
			"type":        "chat",
			"max_tokens":  8192,
			"pricing":     "high",
		},
		{
			"id":          "gpt-4-turbo",
			"name":        "GPT-4 Turbo",
			"description": "Faster GPT-4 with optimized performance",
			"type":        "chat",
			"max_tokens":  4096,
			"pricing":     "medium",
		},
		{
			"id":          "gpt-3.5-turbo",
			"name":        "GPT-3.5 Turbo",
			"description": "Fast and efficient chat model",
			"type":        "chat",
			"max_tokens":  4096,
			"pricing":     "low",
		},
		{
			"id":          "gpt-3.5-turbo-instruct",
			"name":        "GPT-3.5 Turbo Instruct",
			"description": "Instruction-following completion model",
			"type":        "completion",
			"max_tokens":  4096,
			"pricing":     "low",
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    gin.H{"models": models},
	})
}

// HealthCheck for OpenAI service
// GET /api/v1/openai/health
func (h *OpenAIHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"service": "OpenAI AI Agent",
		"version": "1.0.0",
		"provider": "OpenAI",
	})
}

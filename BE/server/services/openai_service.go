package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
	"tukarkultur/api/models"

	"github.com/google/uuid"
)

type OpenAIService struct {
	client  *http.Client
	apiKey  string
	baseURL string
}

// NewOpenAIService creates a new OpenAI service instance
func NewOpenAIService() *OpenAIService {
	apiKey := os.Getenv("OPENAI_API_KEY")
	if apiKey == "" {
		apiKey = "your-openai-api-key" // Fallback for development
	}

	baseURL := os.Getenv("OPENAI_BASE_URL")
	if baseURL == "" {
		baseURL = "https://api.openai.com/v1"
	}

	return &OpenAIService{
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
		apiKey:  apiKey,
		baseURL: baseURL,
	}
}

// OpenAIAPIRequest represents the request structure for OpenAI Completions API
type OpenAIAPIRequest struct {
	Model       string  `json:"model"`
	Prompt      string  `json:"prompt"`
	MaxTokens   int     `json:"max_tokens,omitempty"`
	Temperature float64 `json:"temperature,omitempty"`
}

// OpenAIChatAPIRequest represents the request structure for OpenAI Chat API
type OpenAIChatAPIRequest struct {
	Model       string                    `json:"model"`
	Messages    []models.OpenAIChatMessage `json:"messages"`
	MaxTokens   int                       `json:"max_tokens,omitempty"`
	Temperature float64                   `json:"temperature,omitempty"`
}

// OpenAIAPIResponse represents the response structure from OpenAI API
type OpenAIAPIResponse struct {
	ID      string   `json:"id"`
	Object  string   `json:"object"`
	Created int64    `json:"created"`
	Model   string   `json:"model"`
	Choices []Choice `json:"choices"`
	Usage   APIUsage `json:"usage"`
}

// OpenAIChatAPIResponse represents the response structure from OpenAI Chat API
type OpenAIChatAPIResponse struct {
	ID      string      `json:"id"`
	Object  string      `json:"object"`
	Created int64       `json:"created"`
	Model   string      `json:"model"`
	Choices []ChatChoice `json:"choices"`
	Usage   APIUsage    `json:"usage"`
}

type Choice struct {
	Text         string `json:"text"`
	Index        int    `json:"index"`
	FinishReason string `json:"finish_reason"`
}

type ChatChoice struct {
	Message      models.OpenAIChatMessage `json:"message"`
	Index        int                      `json:"index"`
	FinishReason string                   `json:"finish_reason"`
}

type APIUsage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

// GenerateText generates text using OpenAI API
func (s *OpenAIService) GenerateText(request *models.OpenAIRequest) (*models.OpenAIResponse, error) {
	// Set default model if not provided
	model := request.Model
	if model == "" {
		model = "gpt-3.5-turbo-instruct"
	}

	// Set default max tokens if not provided
	maxTokens := request.MaxTokens
	if maxTokens == 0 {
		maxTokens = 150
	}

	// Set default temperature if not provided
	temperature := request.Temperature
	if temperature == 0 {
		temperature = 0.7
	}

	// Prepare the prompt with context if provided
	prompt := request.Prompt
	if request.Context != "" {
		prompt = fmt.Sprintf("Context: %s\n\nPrompt: %s", request.Context, request.Prompt)
	}

	// Prepare the request for OpenAI API
	openaiReq := OpenAIAPIRequest{
		Model:       model,
		Prompt:      prompt,
		MaxTokens:   maxTokens,
		Temperature: temperature,
	}

	// Convert to JSON
	jsonData, err := json.Marshal(openaiReq)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	url := fmt.Sprintf("%s/completions", s.baseURL)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", s.apiKey))

	// Make the request
	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check for HTTP errors
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API request failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Parse response
	var openaiResp OpenAIAPIResponse
	if err := json.Unmarshal(body, &openaiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	// Extract response text
	var responseText string
	if len(openaiResp.Choices) > 0 {
		responseText = openaiResp.Choices[0].Text
	}

	// Create response
	response := &models.OpenAIResponse{
		ID:       uuid.New().String(),
		Response: responseText,
		Prompt:   request.Prompt,
		Status:   "completed",
		Model:    openaiResp.Model,
		Usage: models.OpenAIUsage{
			PromptTokens:     openaiResp.Usage.PromptTokens,
			CompletionTokens: openaiResp.Usage.CompletionTokens,
			TotalTokens:      openaiResp.Usage.TotalTokens,
		},
	}

	return response, nil
}

// GenerateChat handles chat conversations with OpenAI
func (s *OpenAIService) GenerateChat(request *models.OpenAIChatRequest) (*models.OpenAIChatResponse, error) {
	// Set default model if not provided
	model := request.Model
	if model == "" {
		model = "gpt-3.5-turbo"
	}

	// Set default max tokens if not provided
	maxTokens := request.MaxTokens
	if maxTokens == 0 {
		maxTokens = 150
	}

	// Set default temperature if not provided
	temperature := request.Temperature
	if temperature == 0 {
		temperature = 0.7
	}

	// Add system context if provided
	messages := request.Messages
	if request.Context != "" {
		systemMessage := models.OpenAIChatMessage{
			Role:    "system",
			Content: request.Context,
		}
		messages = append([]models.OpenAIChatMessage{systemMessage}, messages...)
	}

	openaiReq := OpenAIChatAPIRequest{
		Model:       model,
		Messages:    messages,
		MaxTokens:   maxTokens,
		Temperature: temperature,
	}

	// Convert to JSON
	jsonData, err := json.Marshal(openaiReq)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	url := fmt.Sprintf("%s/chat/completions", s.baseURL)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", s.apiKey))

	// Make the request
	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check for HTTP errors
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API request failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Parse response
	var openaiResp OpenAIChatAPIResponse
	if err := json.Unmarshal(body, &openaiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	// Extract response text
	var responseText string
	if len(openaiResp.Choices) > 0 {
		responseText = openaiResp.Choices[0].Message.Content
	}

	// Add the AI response to messages
	allMessages := append(request.Messages, models.OpenAIChatMessage{
		Role:    "assistant",
		Content: responseText,
	})

	// Create response
	response := &models.OpenAIChatResponse{
		ID:       uuid.New().String(),
		Messages: allMessages,
		Response: responseText,
		Status:   "completed",
		Model:    openaiResp.Model,
		Usage: models.OpenAIUsage{
			PromptTokens:     openaiResp.Usage.PromptTokens,
			CompletionTokens: openaiResp.Usage.CompletionTokens,
			TotalTokens:      openaiResp.Usage.TotalTokens,
		},
	}

	return response, nil
}

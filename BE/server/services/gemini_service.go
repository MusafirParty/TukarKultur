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

type GeminiService struct {
	client *http.Client
	apiKey string
	baseURL string
}

// NewGeminiService creates a new Gemini service instance
func NewGeminiService() *GeminiService {
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		apiKey = "your-gemini-api-key" // Fallback for development
	}

	baseURL := os.Getenv("GEMINI_BASE_URL")
	if baseURL == "" {
		baseURL = "https://generativelanguage.googleapis.com/v1beta"
	}

	return &GeminiService{
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
		apiKey:  apiKey,
		baseURL: baseURL,
	}
}

// GeminiAPIRequest represents the request structure for Gemini API
type GeminiAPIRequest struct {
	Contents []Content `json:"contents"`
}

type Content struct {
	Parts []Part `json:"parts"`
}

type Part struct {
	Text string `json:"text"`
}

// GeminiAPIResponse represents the response structure from Gemini API
type GeminiAPIResponse struct {
	Candidates []Candidate `json:"candidates"`
	UsageMetadata UsageMetadata `json:"usageMetadata,omitempty"`
}

type Candidate struct {
	Content Content `json:"content"`
	FinishReason string `json:"finishReason,omitempty"`
	Index int `json:"index"`
}

type UsageMetadata struct {
	PromptTokenCount     int `json:"promptTokenCount"`
	CandidatesTokenCount int `json:"candidatesTokenCount"`
	TotalTokenCount      int `json:"totalTokenCount"`
}

// GenerateText generates text using Gemini API
func (s *GeminiService) GenerateText(request *models.GeminiRequest) (*models.GeminiResponse, error) {
	// Prepare the request for Gemini API
	geminiReq := GeminiAPIRequest{
		Contents: []Content{
			{
				Parts: []Part{
					{Text: request.Prompt},
				},
			},
		},
	}

	// Add context if provided
	if request.Context != "" {
		contextPart := Part{Text: fmt.Sprintf("Context: %s\n\nPrompt: %s", request.Context, request.Prompt)}
		geminiReq.Contents[0].Parts = []Part{contextPart}
	}

	// Convert to JSON
	jsonData, err := json.Marshal(geminiReq)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	url := fmt.Sprintf("%s/models/gemini-1.5-flash-latest:generateContent?key=%s", s.baseURL, s.apiKey)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

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
	var geminiResp GeminiAPIResponse
	if err := json.Unmarshal(body, &geminiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	// Extract response text
	var responseText string
	if len(geminiResp.Candidates) > 0 && len(geminiResp.Candidates[0].Content.Parts) > 0 {
		responseText = geminiResp.Candidates[0].Content.Parts[0].Text
	}

	// Create response
	response := &models.GeminiResponse{
		ID:       uuid.New().String(),
		Response: responseText,
		Prompt:   request.Prompt,
		Status:   "completed",
		Model:    "gemini-1.5-flash-latest",
		Usage: models.Usage{
			PromptTokens:     geminiResp.UsageMetadata.PromptTokenCount,
			CompletionTokens: geminiResp.UsageMetadata.CandidatesTokenCount,
			TotalTokens:      geminiResp.UsageMetadata.TotalTokenCount,
		},
	}

	return response, nil
}

// GenerateChat handles chat conversations with Gemini
func (s *GeminiService) GenerateChat(request *models.ChatRequest) (*models.ChatResponse, error) {
	// Convert chat messages to Gemini format
	var contents []Content
	
	for _, msg := range request.Messages {
		content := Content{
			Parts: []Part{
				{Text: msg.Content},
			},
		}
		contents = append(contents, content)
	}

	geminiReq := GeminiAPIRequest{
		Contents: contents,
	}

	// Convert to JSON
	jsonData, err := json.Marshal(geminiReq)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Create HTTP request
	url := fmt.Sprintf("%s/models/gemini-1.5-flash-latest:generateContent?key=%s", s.baseURL, s.apiKey)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

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
	var geminiResp GeminiAPIResponse
	if err := json.Unmarshal(body, &geminiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	// Extract response text
	var responseText string
	if len(geminiResp.Candidates) > 0 && len(geminiResp.Candidates[0].Content.Parts) > 0 {
		responseText = geminiResp.Candidates[0].Content.Parts[0].Text
	}

	// Add the AI response to messages
	allMessages := append(request.Messages, models.ChatMessage{
		Role:    "model",
		Content: responseText,
	})

	// Create response
	response := &models.ChatResponse{
		ID:       uuid.New().String(),
		Messages: allMessages,
		Response: responseText,
		Status:   "completed",
		Model:    "gemini-1.5-flash-latest",
		Usage: models.Usage{
			PromptTokens:     geminiResp.UsageMetadata.PromptTokenCount,
			CompletionTokens: geminiResp.UsageMetadata.CandidatesTokenCount,
			TotalTokens:      geminiResp.UsageMetadata.TotalTokenCount,
		},
	}

	return response, nil
}

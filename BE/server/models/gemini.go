package models

// GeminiRequest represents the request payload for the Gemini API
type GeminiRequest struct {
	Prompt   string            `json:"prompt" binding:"required"`
	Context  string            `json:"context,omitempty"`
	UserID   string            `json:"user_id,omitempty"`
	Metadata map[string]string `json:"metadata,omitempty"`
}

// GeminiResponse represents the response from the Gemini API
type GeminiResponse struct {
	ID       string `json:"id"`
	Response string `json:"response"`
	Prompt   string `json:"prompt"`
	Status   string `json:"status"`
	Model    string `json:"model"`
	Usage    Usage  `json:"usage,omitempty"`
}

// Usage represents token usage information
type Usage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

// GeminiErrorResponse represents error response from Gemini
type GeminiErrorResponse struct {
	Error   string `json:"error"`
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// ChatMessage represents a single message in a conversation
type ChatMessage struct {
	Role    string `json:"role"`    // "user" or "model"
	Content string `json:"content"`
}

// ChatRequest represents a chat conversation request
type ChatRequest struct {
	Messages []ChatMessage     `json:"messages" binding:"required"`
	UserID   string            `json:"user_id,omitempty"`
	Context  string            `json:"context,omitempty"`
	Metadata map[string]string `json:"metadata,omitempty"`
}

// ChatResponse represents a chat conversation response
type ChatResponse struct {
	ID       string      `json:"id"`
	Messages []ChatMessage `json:"messages"`
	Response string      `json:"response"`
	Status   string      `json:"status"`
	Model    string      `json:"model"`
	Usage    Usage       `json:"usage,omitempty"`
}

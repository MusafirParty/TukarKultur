package models

// OpenAIRequest represents the request payload for the OpenAI API
type OpenAIRequest struct {
	Prompt      string            `json:"prompt" binding:"required"`
	Model       string            `json:"model,omitempty"`
	MaxTokens   int               `json:"max_tokens,omitempty"`
	Temperature float64           `json:"temperature,omitempty"`
	Context     string            `json:"context,omitempty"`
	UserID      string            `json:"user_id,omitempty"`
	Metadata    map[string]string `json:"metadata,omitempty"`
}

// OpenAIResponse represents the response from the OpenAI API
type OpenAIResponse struct {
	ID       string    `json:"id"`
	Response string    `json:"response"`
	Prompt   string    `json:"prompt"`
	Status   string    `json:"status"`
	Model    string    `json:"model"`
	Usage    OpenAIUsage `json:"usage,omitempty"`
}

// OpenAIUsage represents token usage information for OpenAI
type OpenAIUsage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

// OpenAIErrorResponse represents error response from OpenAI
type OpenAIErrorResponse struct {
	Error   OpenAIError `json:"error"`
	Code    int         `json:"code,omitempty"`
	Message string      `json:"message,omitempty"`
}

type OpenAIError struct {
	Message string `json:"message"`
	Type    string `json:"type"`
	Code    string `json:"code,omitempty"`
}

// OpenAIChatMessage represents a single message in an OpenAI conversation
type OpenAIChatMessage struct {
	Role    string `json:"role"`    // "system", "user", or "assistant"
	Content string `json:"content"`
}

// OpenAIChatRequest represents a chat conversation request for OpenAI
type OpenAIChatRequest struct {
	Messages    []OpenAIChatMessage `json:"messages" binding:"required"`
	Model       string              `json:"model,omitempty"`
	MaxTokens   int                 `json:"max_tokens,omitempty"`
	Temperature float64             `json:"temperature,omitempty"`
	UserID      string              `json:"user_id,omitempty"`
	Context     string              `json:"context,omitempty"`
	Metadata    map[string]string   `json:"metadata,omitempty"`
}

// OpenAIChatResponse represents a chat conversation response from OpenAI
type OpenAIChatResponse struct {
	ID       string            `json:"id"`
	Messages []OpenAIChatMessage `json:"messages"`
	Response string            `json:"response"`
	Status   string            `json:"status"`
	Model    string            `json:"model"`
	Usage    OpenAIUsage       `json:"usage,omitempty"`
}

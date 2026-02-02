local M = {}

M.defaults = {
  debug = false,
  -- Service type: 'ollama' or 'openai'
  service = "ollama",
  
  -- Ollama specific configuration
  ollama = {
    url = "http://127.0.0.1:11434/api/generate",
    model = "llama3",
    stream = true,
  },
  
  -- OpenAI compatible configuration
  openai = {
    url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-3.5-turbo",
    api_key = os.getenv("OPENAI_API_KEY"),
    max_tokens = 1000,
  },
  
  -- Prompts for different actions
  prompts = {
    translate = "Translate the following text to Simplified Chinese. Only output the translation result without any explanation:\n\n",
    explain = "Explain the following code or text concisely:\n\n",
    refactor = "Refactor the following code to be more readable and efficient:\n\n",
  },
  
  -- UI Configuration
  ui = {
    width_ratio = 0.4,    -- Percentage of screen width
    height_ratio = 0.3,   -- Percentage of screen height
    border = "rounded",
    title = " PopAI ",
  }
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", M.defaults, options or {})
end

return M

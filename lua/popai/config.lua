local M = {}

M.defaults = {
  debug = false,
  -- Service type: 'ollama' or 'openai'
  service = "ollama",

  -- Global system prompt (optional)
  -- Applies to both Ollama and OpenAI
  system_prompt = "Act as a concise coding assistant. Provide direct answers without unnecessary conversational filler.",
  
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
    translate_ch = "Translate the following text to Simplified Chinese. Only output the translation result without any explanation:\n\n{input}",
    translate_en = "Translate the following text to English. Only output the translation result without any explanation:\n\n{input}",
    regex_explain = "Explain this regex concisely: {input} Format the output as follows:\nFunction: [Brief description]\nLogic: [Component breakdown]\nExample: [One matching string]\nUse Markdown. No conversational filler.",
    shell_explain = "Break down this shell command and explain what each flag/parameter does: {input}",
    cron_explain = "Translate this Cron expression into a human-readable sentence (e.g., 'Every 15 minutes, Monday through Friday'): {input}",
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

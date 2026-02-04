# 🍿 popai.nvim

A Neovim plugin that sends text under cursor or visual selection to Ollama or OpenAI-compatible services, displaying the response in a floating window.

## ✨ Features

- 🤖 Support for **Ollama** and **OpenAI-compatible** APIs
- ⚡ **Streaming** response with real-time display
- 📐 **Adaptive** floating window size
- 🔄 Works in **Normal mode** (word under cursor) and **Visual mode** (selected text)
- 📝 **Customizable prompts** for different actions (translate, explain, refactor, etc.)
- ⏳ Built-in **loading indicator**

## 🎬 Demo

![popai.nvim demo](assets/demo.gif)

The demo showcases:
- 🌐 **Translation** - Translate text between Chinese and English
- 📐 **Regex Explain** - Break down complex regex patterns into readable explanations
- ⏰ **Cron Explain** - Convert cron expressions to human-readable sentences
- 💻 **Shell Explain** - Analyze shell commands and their parameters
- 😀 **Emoji** - Convert text to emoji expressions

## 📋 Requirements

- Neovim >= 0.10.0 (uses `vim.system` for async HTTP)
- `curl` installed on your system
- Ollama running locally, or an OpenAI-compatible API endpoint

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Root-lee/popai.nvim",
  config = function()
    require("popai").setup({
      -- your configuration here
    })
  end,
  cmd = "Popai",
  keys = {
    { "<leader>t", ":Popai translate<CR>", mode = { "n", "v" }, desc = "Translate with PopAI" },
  },
}
```

## ⚙️ Configuration

### Default Configuration

```lua
require("popai").setup({
  -- Service type: "ollama" or "openai"
  service = "ollama",

  -- Global system prompt (optional)
  -- Applies to both Ollama and OpenAI
  system_prompt = "Act as a concise coding assistant. Provide direct answers without unnecessary conversational filler.",

  -- Ollama configuration
  ollama = {
    url = "http://127.0.0.1:11434/api/generate",
    model = "llama3",
  },

  -- OpenAI-compatible configuration
  openai = {
    url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-3.5-turbo",
    api_key = os.getenv("OPENAI_API_KEY"),
  },

  -- Prompts for different actions
  prompts = {
    translate_ch = "Translate the following text to Simplified Chinese. Only output the translation result without any explanation:\n\n{input}",
    translate_en = "Translate the following text to English. Only output the translation result without any explanation:\n\n{input}",
    regex_explain = "Explain this regex concisely: {input} Format the output as follows:\nFunction: [Brief description]\nLogic: [Component breakdown]\nExample: [One matching string]\nUse Markdown. No conversational filler.",
    shell_explain = "Break down this shell command and explain what each flag/parameter does: {input}",
    cron_explain = "Translate this Cron expression into a human-readable sentence (e.g., 'Every 15 minutes, Monday through Friday'): {input}",
  },

  -- UI configuration
  ui = {
    width_ratio = 0.4,   -- Window width as percentage of screen
    height_ratio = 0.3,  -- Max window height as percentage of screen
    border = "rounded",  -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    title = " PopAI ",   -- Window title
  },
})
```

### Example: Using Ollama with Qwen

```lua
require("popai").setup({
  service = "ollama",
  ollama = {
    model = "qwen3:4b",
  },
})
```

### Example: Using OpenAI

```lua
require("popai").setup({
  service = "openai",
  openai = {
    api_key = os.getenv("OPENAI_API_KEY"),
    model = "gpt-4",
  },
})
```

### Example: Using OpenAI-compatible API (e.g., DeepSeek, Groq)

```lua
require("popai").setup({
  service = "openai",
  openai = {
    url = "https://api.deepseek.com/v1/chat/completions",
    api_key = os.getenv("DEEPSEEK_API_KEY"),
    model = "deepseek-chat",
  },
})
```

### Adding Custom Prompts

```lua
require("popai").setup({
  prompts = {
    translate_jp = "Translate the following text to Japanese. Only output the translation result without any explanation:\n\n{input}",
    emoji = "Express the following text using ONLY emojis. Do not use any words or letters:\n\n{input}",
    sql = "Format this SQL query and explain what it does concisely:\n\n{input}",
  },
})
```

You can also use the `{input}` placeholder to insert the selected text at a specific position in the prompt. If `{input}` is not present, the text will be appended to the end of the prompt.

```lua
require("popai").setup({
  prompts = {
    -- Text will be inserted at {input}
    custom_task = "Task: Process the following content: {input}\n\nRequirements: ...",
  },
})
```

## 🚀 Usage

### Commands

| Command | Description |
|---------|-------------|
| `:Popai translate_ch` | Translate to Chinese |
| `:Popai translate_en` | Translate to English |
| `:Popai regex_explain` | Explain regex |
| `:Popai shell_explain` | Explain shell command |
| `:Popai cron_explain` | Explain cron expression |
| `:Popai <custom>` | Run any custom prompt you defined |

### Workflow

1. **Normal mode**: Place cursor on a word, then run `:Popai translate_ch`
2. **Visual mode**: Select text, then run `:'<,'>Popai translate_ch`
3. **Close window**: Press `q` or `<Esc>` in the floating window

### Recommended Keymaps

```lua
-- In your lazy.nvim plugin spec
keys = {
  { "<leader>pc", ":Popai translate_ch<CR>", mode = { "n", "v" }, desc = "Translate to Chinese" },
  { "<leader>pe", ":Popai translate_en<CR>", mode = { "n", "v" }, desc = "Translate to English" },
  { "<leader>pr", ":Popai regex_explain<CR>", mode = { "n", "v" }, desc = "Regex Explain" },
  { "<leader>ps", ":Popai shell_explain<CR>", mode = { "n", "v" }, desc = "Shell Explain" },
  { "<leader>pt", ":Popai cron_explain<CR>", mode = { "n", "v" }, desc = "Cron Explain" },
}

-- Or manually in your config
vim.keymap.set({ "n", "v" }, "<leader>pc", ":Popai translate_ch<CR>", { desc = "Translate to Chinese" })
vim.keymap.set({ "n", "v" }, "<leader>pe", ":Popai translate_en<CR>", { desc = "Translate to English" })
vim.keymap.set({ "n", "v" }, "<leader>pr", ":Popai regex_explain<CR>", { desc = "Regex Explain" })
vim.keymap.set({ "n", "v" }, "<leader>ps", ":Popai shell_explain<CR>", { desc = "Shell Explain" })
vim.keymap.set({ "n", "v" }, "<leader>pt", ":Popai cron_explain<CR>", { desc = "Cron Explain" })
```

## 📄 License

MIT

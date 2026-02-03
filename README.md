# popai.nvim

A Neovim plugin that sends text under cursor or visual selection to Ollama or OpenAI-compatible services, displaying the response in a floating window.

## Features

- Support for **Ollama** and **OpenAI-compatible** APIs
- **Streaming** response with real-time display
- **Adaptive** floating window size
- Works in **Normal mode** (word under cursor) and **Visual mode** (selected text)
- **Customizable prompts** for different actions (translate, explain, refactor, etc.)
- Built-in **loading indicator**

## Requirements

- Neovim >= 0.10.0 (uses `vim.system` for async HTTP)
- `curl` installed on your system
- Ollama running locally, or an OpenAI-compatible API endpoint

## Installation

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

## Configuration

### Default Configuration

```lua
require("popai").setup({
  -- Service type: "ollama" or "openai"
  service = "ollama",

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
    translate = "Translate the following text to Simplified Chinese. Only output the translation result without any explanation:\n\n",
    explain = "Explain the following code or text concisely:\n\n",
    refactor = "Refactor the following code to be more readable and efficient:\n\n",
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
    translate = "Translate to Chinese:\n\n",
    translate_en = "Translate to English:\n\n",
    summarize = "Summarize the following text in 2-3 sentences:\n\n",
    fix_grammar = "Fix the grammar and spelling errors in the following text:\n\n",
    explain_code = "Explain what this code does step by step:\n\n",
  },
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:Popai` | Run default action (translate) on word under cursor or selection |
| `:Popai translate` | Translate text |
| `:Popai explain` | Explain text/code |
| `:Popai refactor` | Refactor code |
| `:Popai <custom>` | Run any custom prompt you defined |

### Workflow

1. **Normal mode**: Place cursor on a word, then run `:Popai translate`
2. **Visual mode**: Select text, then run `:'<,'>Popai translate`
3. **Close window**: Press `q` or `<Esc>` in the floating window

### Recommended Keymaps

```lua
-- In your lazy.nvim plugin spec
keys = {
  { "<leader>tt", ":Popai translate<CR>", mode = { "n", "v" }, desc = "Translate" },
  { "<leader>te", ":Popai explain<CR>", mode = { "n", "v" }, desc = "Explain" },
  { "<leader>tr", ":Popai refactor<CR>", mode = { "n", "v" }, desc = "Refactor" },
}

-- Or manually in your config
vim.keymap.set({ "n", "v" }, "<leader>tt", ":Popai translate<CR>", { desc = "Translate" })
vim.keymap.set({ "n", "v" }, "<leader>te", ":Popai explain<CR>", { desc = "Explain" })
vim.keymap.set({ "n", "v" }, "<leader>tr", ":Popai refactor<CR>", { desc = "Refactor" })
```

## License

MIT

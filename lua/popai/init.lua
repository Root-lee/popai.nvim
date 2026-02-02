local M = {}
local config = require("popai.config")
local ui = require("popai.ui")
local api = require("popai.api")

-- Helper to get visual selection
local function get_visual_selection()
  -- This approach assumes the marks are set. 
  -- When using a keybinding like 'vmap', we might need to feed keys to exit visual mode first
  -- or use region API. For simplicity with commands, we use the marks.
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  
  if csrow == 0 or cerow == 0 then return "" end

  local lines = vim.api.nvim_buf_get_lines(0, csrow - 1, cerow, false)
  if #lines == 0 then return "" end

  -- Adjust last line (check strictly if cecol is larger than line length, 
  -- but usually vim handles it. Note vim columns are 1-based in getpos)
  if #lines > 1 then
      lines[#lines] = string.sub(lines[#lines], 1, cecol)
      lines[1] = string.sub(lines[1], cscol)
  else
      lines[1] = string.sub(lines[1], cscol, cecol)
  end
  
  return table.concat(lines, "\n")
end

function M.setup(opts)
  config.setup(opts)
end

function M.popai(action_name, is_visual)
  local text = ""

  if is_visual then
    text = get_visual_selection()
  else
    text = vim.fn.expand("<cword>") 
  end

  if text == "" then
    vim.notify("PopAI: No text selected or found under cursor", vim.log.levels.WARN)
    return
  end

  -- Default to 'translate' if no action provided
  action_name = action_name or "translate"
  local template = config.options.prompts[action_name]
  
  if not template then
    -- Fallback: treat action_name as a custom prompt or search in prompts
    template = config.options.prompts["translate"] -- Safe fallback
    vim.notify("PopAI: Unknown action '" .. action_name .. "', using translate.", vim.log.levels.INFO)
  end

  local full_prompt = template .. text

  -- Open UI
  ui.create_window()
  ui.show_loading()
  
  -- Call API
  api.request(full_prompt)
end

return M

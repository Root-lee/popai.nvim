if vim.g.loaded_popai then
  return
end
vim.g.loaded_popai = 1

local popai = require("popai")

vim.api.nvim_create_user_command("Popai", function(opts)
  local action = opts.args
  local is_visual = opts.range == 2
  popai.popai(action, is_visual)
end, {
  nargs = 1,
  range = true,
  complete = function(ArgLead, CmdLine, CursorPos)
    local config = require("popai.config")
    local keys = vim.tbl_keys(config.options.prompts or config.defaults.prompts)
    return vim.tbl_filter(function(item)
      return vim.startswith(item, ArgLead)
    end, keys)
  end,
})

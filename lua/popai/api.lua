local M = {}
local config = require("popai.config")
local ui = require("popai.ui")

-- Helper to parse JSON safely
local function parse_json(str)
	local ok, result = pcall(vim.json.decode, str)
	if ok then
		return result
	end
	return nil
end

function M.request(prompt)
	local opts = config.options
	local service = opts.service

	local cmd = { "curl", "-s", "-N", "-X", "POST" }
	local body = {}
	local url = ""
	local headers = { "-H", "Content-Type: application/json" }

	if service == "ollama" then
		url = opts.ollama.url
		body = {
			model = opts.ollama.model,
			prompt = prompt,
			stream = true,
		}

		if opts.system_prompt then
			body.system = opts.system_prompt
		end
	elseif service == "openai" then
		url = opts.openai.url
		local messages = {}
		if opts.system_prompt then
			table.insert(messages, { role = "system", content = opts.system_prompt })
		end
		table.insert(messages, { role = "user", content = prompt })

		body = {
			model = opts.openai.model,
			messages = messages,
			stream = true,
		}
		if opts.openai.api_key then
			table.insert(headers, "-H")
			table.insert(headers, "Authorization: Bearer " .. opts.openai.api_key)
		end
	else
		vim.notify("PopAI: Unsupported service: " .. service, vim.log.levels.ERROR)
		return
	end

	table.insert(cmd, url)
	for _, h in ipairs(headers) do
		table.insert(cmd, h)
	end
	table.insert(cmd, "-d")
	table.insert(cmd, vim.json.encode(body))

	-- Buffer for accumulating partial chunks
	local buffer = ""
	local first_token = true
	local in_thinking_block = false

	-- Use vim.system for async execution (Nvim 0.10+)
	vim.system(cmd, {
		stdout = function(err, data)
			if err then
				return
			end
			if not data then
				return
			end

			-- Schedule UI update on main loop
			vim.schedule(function()
				local chunk = buffer .. data
				local lines = vim.split(chunk, "\n")

				-- The last element is either empty (if data ended with \n) or incomplete
				buffer = table.remove(lines)

				for _, line in ipairs(lines) do
					local content = ""

					if line ~= "" then
						if service == "ollama" then
							local json = parse_json(line)
							if json and json.response then
								content = json.response
							end
						elseif service == "openai" then
							local raw = line:gsub("^data: ", "")
							if raw ~= "[DONE]" then
								local json = parse_json(raw)
								if json and json.choices and json.choices[1].delta.content then
									content = json.choices[1].delta.content
								end
							end
						end

						if content ~= "" then
							-- Handle thinking block logic
							if content:find("<thinking>") then
								ui.set_thinking()
								in_thinking_block = true
								-- Only clear if it's the very first token, otherwise we might clear previous content
								if first_token then
									ui.clear()
									first_token = false
								end
								-- Don't print the tag itself or content inside yet
								-- But if there is content before the tag, we should handle that (simplified here)
								content = content:gsub("<thinking>.*", "")
							end

							if in_thinking_block then
								if content:find("</thinking>") then
									ui.set_generating()
									in_thinking_block = false
									content = content:gsub(".*</thinking>", "")
								else
									content = "" -- Suppress content inside thinking block
								end
							end

							if content ~= "" then
								-- Ensure spinner is stopped if we start outputting content
								-- Check against thinking block state is already done above
								if not in_thinking_block then
									ui.set_generating()
								end

								if first_token then
									ui.clear()
									first_token = false
								end
								ui.write(content)
							end
						end
					end
				end
			end)
		end,
		stderr = function(err, data)
			-- Optional: handle stderr logging
		end,
	}, function(obj)
		if obj.code ~= 0 then
			vim.schedule(function()
				vim.notify("PopAI Request Failed. Exit code: " .. obj.code, vim.log.levels.ERROR)
			end)
		end
	end)
end

return M

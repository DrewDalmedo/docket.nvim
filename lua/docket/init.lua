local M = {}
local uv = vim.loop

-- compute the path to the global docket
local function get_global_path()
	local data_dir = vim.fn.stdpath("data")
	return table.concat(
		{ data_dir, "dockets", "global.md" },
		uv.os_uname().version:find("Windows") and "\\" or "/"
	)
end

local function ensure_global_dir()
	local global_path = get_global_path()
	local parent_dir = vim.fn.fnamemodify(global_path, ":h")

	-- sanity check: if parent directory doesn't exist, create it
	if vim.fn.isdirectory(parent_dir) == 0 then
		vim.fn.mkdir(parent_dir, "p", "0700")
	end
end

function M.configure_buffer(bufnr)
	-- default docket filetype to markdown
	-- TODO: make configurable
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

	-- hide buffer when closed; don't drop it from memory
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

	-- no swapfile
	vim.api.nvim_buf_set_option(bufnr, "swapfile", false)

	-- don't list in :ls
	vim.api.nvim_buf_set_option(bufnr, "buflisted", false)

	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
end

function M.open_global_floating()
	ensure_global_dir()
	local path = get_global_path()

	local bufnr = vim.fn.bufadd(path)
	vim.fn.bufload(bufnr)
	M.configure_buffer(bufnr)

	-- compute a reasonable size / position for the floating window:
	local total_cols = vim.o.columns
	local total_lines = vim.o.lines
	local width = math.floor(total_cols * 0.8)
	local height = math.floor(total_lines * 0.8)
	local row = math.floor((total_lines - height) / 2 - 1)
	local col = math.floor((total_cols - width) / 2)

	-- open a floating window for the buffer
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		--style = "minimal",
		border = "solid",
	}
	local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)

	-- set the background of the floating window to something readable
	vim.api.nvim_win_set_option(
		win_id,
		"winhighlight",
		"Normal:Normal,FloatBorder:FloatBorder"
	)

	-- make sure edits are written out on BufLeave or VimLeavePre
	vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
		buffer = bufnr,
		callback = function()
			if vim.api.nvim_buf_get_option(bufnr, "modified") then
				vim.cmd("silent write")
			end
		end,
	})

	-- map esc to close the floating window:
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<Esc>",
		string.format("<cmd>silent! bwipeout %d<CR>", bufnr),
		{ noremap = true, silent = true }
	)
end

function M.open_global()
	ensure_global_dir()
	local path = get_global_path()

	-- if buffer is loaded, just switch to it
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(bufnr) == path then
			vim.api.nvim_set_current_buf(bufnr)
			return
		end
	end

	-- if buffer isn't loaded, create or edit the file
	vim.cmd("edit " .. vim.fn.fnameescape(path))
	local bufnr = vim.api.nvim_get_current_buf()
	M.configure_buffer(bufnr)

	vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
		buffer = bufnr,
		callback = function()
			if vim.api.nvim_buf_get_option(bufnr, "modified") then
				vim.cmd("silent write")
			end
		end,
	})
end

return M

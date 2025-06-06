local ok, docket = pcall(require, "docket")

if not ok then
	vim.notify(
		"docket.nvim: could not load module \"docket\"",
		vim.log.levels.ERROR
	)
	return
end

vim.api.nvim_create_user_command("DocketGlobal", function()
	docket.open_global()
end, { desc = "Open (or switch to) your global docket" })

vim.api.nvim_create_user_command("DocketGlobalFloating", function()
	docket.open_global_floating()
end, { desc = "Open global docket in a floating window" })

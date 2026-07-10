-- Keymaps are automatically loaded on the VeryLazy event.
-- LazyVim defaults still apply; these restore the old Kickstart muscle memory.
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<C-q>", "<cmd>qa!<CR>", { desc = "Quit all" })

map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>wh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close window" })

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Telescope muscle memory backed by Snacks.
map("n", "<leader><leader>", function()
  Snacks.picker.files()
end, { desc = "Find files" })

map("n", "<leader>,", function()
  Snacks.picker.grep({ icons = { ui = { live = "" } } })
end, { desc = "Grep" })

map("n", "<leader>.", function()
  Snacks.picker.recent()
end, { desc = "Recent files" })

map("n", "<leader>/", function()
  Snacks.picker.lines()
end, { desc = "Buffer lines" })

map("n", "<leader>sn", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find config files" })

map("n", "<leader>ss", function()
  Snacks.picker.lsp_symbols()
end, { desc = "LSP symbols" })

map("n", "<leader>sW", function()
  Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })

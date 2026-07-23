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

-- vim-herdr-navigation (vendored from paulbkim-dev/vim-herdr-navigation
-- editor/nvim.lua, tmux fallback dropped): <C-h/j/k/l> moves between splits,
-- and at a split edge crosses into the neighbouring herdr pane.
local function herdr_nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then
      herdr = "herdr"
    end
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
  end
end

for key, nav in pairs({
  ["<C-h>"] = { "h", "left" },
  ["<C-j>"] = { "j", "down" },
  ["<C-k>"] = { "k", "up" },
  ["<C-l>"] = { "l", "right" },
}) do
  map("n", key, function()
    herdr_nav(nav[1], nav[2])
  end, { desc = "Navigate " .. nav[2] .. " (vim/herdr)" })
end

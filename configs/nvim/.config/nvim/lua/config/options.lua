-- Personal defaults carried over from the old Kickstart config.

vim.g.have_nerd_font = true

-- Disable optional remote providers this config does not use.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.winborder = "bold"

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    focusable = true,
  },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = { prefix = "●" },
  virtual_lines = false,
  jump = {
    on_jump = function(diagnostic, bufnr)
      if diagnostic then
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
      end
    end,
  },
})

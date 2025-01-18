-- lua/plugins/codesnap.lua

-- lua/plugins/codesnap.lua
-- lua/plugins/codesnap.lua

return {
  {
    "mistricky/codesnap.nvim",
    build = "make",
    config = function()
      require("codesnap").setup({
        -- Default configuration
        watermark = "", -- Watermark text to display at the bottom
        preview_title = "", -- Title of the preview window
        editor_font_family = "monospace", -- Font family for the code
        watermark_font_family = "monospace", -- Font family for the watermark
        -- Optional: You can customize the theme
        -- theme = {
        --   background = "#1f2335", -- Background color
        --   text = "#c0caf5", -- Text color
        --   selection = "#364268", -- Selection color
        -- }
      })

      -- Set up key mappings (optional)
      vim.keymap.set("v", "<leader>Cs", ":<C-u>CodeSnapSave<CR>", { silent = true })
      vim.keymap.set("v", "<leader>Cc", ":<C-u>CodeSnap<CR>", { silent = true })
    end,
  },
}
-- return {
--   "mistricky/codesnap.nvim",
--   build = "make build_generator",
--   keys = {
--     { "<leader>Cc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
--     { "<leader>Cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
--   },
--   opts = {
--     save_path = "~/Pictures",
--     has_breadcrumbs = true,
--     bg_theme = "bamboo",
--   },
--   theme = {
--     -- Main colors
--     background = "#282828", -- Gruvbox dark background
--     text = "#ebdbb2", -- Gruvbox foreground
--     selection = "#504945", -- Gruvbox bg2
--
--     -- Syntax highlighting colors
--     keyword = "#fb4934", -- Gruvbox red
--     string = "#b8bb26", -- Gruvbox green
--     comment = "#928374", -- Gruvbox gray
--     function_word = "#fabd2f", -- Gruvbox yellow
--     number = "#d3869b", -- Gruvbox purple
--     operator = "#fe8019", -- Gruvbox orange
--     variable = "#83a598", -- Gruvbox blue
--
--     -- UI elements
--     line_number = "#7c6f64", -- Gruvbox fg4
--     watermark = "#928374", -- Gruvbox gray
--   },
-- }
-- return {
--   {
--     "mistricky/codesnap.nvim",
--     build = "make build_generator",
--     keys = {
--       { "<leader>Cc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
--       { "<leader>Cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
--     },
--     opts = {
--       save_path = "~/Pictures",
--       has_breadcrumbs = true,
--       bg_theme = "gruvbox", -- Using gruvbox theme as requested earlier
--
--       -- Gruvbox color customization
--       theme = {
--         -- Main colors
--         background = "#282828", -- Gruvbox dark background
--         text = "#ebdbb2", -- Gruvbox foreground
--         selection = "#504945", -- Gruvbox bg2
--
--         -- Syntax highlighting colors
--         keyword = "#fb4934", -- Gruvbox red
--         string = "#b8bb26", -- Gruvbox green
--         comment = "#928374", -- Gruvbox gray
--         function_word = "#fabd2f", -- Gruvbox yellow
--         number = "#d3869b", -- Gruvbox purple
--         operator = "#fe8019", -- Gruvbox orange
--         variable = "#83a598", -- Gruvbox blue
--
--         -- UI elements
--         line_number = "#7c6f64", -- Gruvbox fg4
--         watermark = "#928374", -- Gruvbox gray
--       },
--     },
--   },
-- }

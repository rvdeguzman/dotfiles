return {
  {
    "mistricky/codesnap.nvim",
    build = "make",
    config = function()
      require("codesnap").setup({
        mac_window_bar = false,
        breadcrumbs_separator = "/",
        has_breadcrumbs = true,
        has_line_number = true,
        show_workspace = true,
        bg_x_padding = 144,
        bg_y_padding = 108,
        watermark = "", -- Watermark text to display at the bottom
        preview_title = "", -- Title of the preview window
        editor_font_family = "JetBrains Nerd Font Mono", -- Font family for the code
        watermark_font_family = "monospace", -- Font family for the watermark
        bg_color = "#282828",
      })

      -- Set up key mappings (optional)
      vim.keymap.set("v", "<leader>Cs", ":<C-u>CodeSnapSave<CR>", { silent = true })
      vim.keymap.set("v", "<leader>Cc", ":<C-u>CodeSnap<CR>", { silent = true })
    end,
  },
}

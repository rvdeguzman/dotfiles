return {
  -- Other plugins
  {
    "rcarriga/nvim-notify",
    enabled = false,
    config = function()
      require("notify").setup({
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = false,
        max_width = 50,
        max_height = 10,
        background_colour = "Normal",
      })
      vim.notify = require("notify")
    end,
  },
  -- More plugins
}

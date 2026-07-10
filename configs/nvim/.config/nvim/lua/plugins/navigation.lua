return {
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move focus to the left window" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Move focus to the lower window" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Move focus to the upper window" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Move focus to the right window" },
    },
  },
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
      },
      prompt = {
        enabled = false,
      },
    },
    keys = {
      {
        "f",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash",
      },
      {
        "F",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash Treesitter",
      },
      {
        "r",
        function()
          require("flash").remote()
        end,
        mode = "o",
        desc = "Remote Flash",
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local keys = {
        {
          "<leader>ha",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon add file",
        },
        {
          "<leader>ho",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon quick menu",
        },
      }

      for i = 1, 9 do
        keys[#keys + 1] = {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to file " .. i,
        }
      end

      return keys
    end,
    opts = {
      menu = {
        width = function()
          return vim.api.nvim_win_get_width(0) - 4
        end,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    config = function(_, opts)
      if type(opts.menu.width) == "function" then
        opts.menu.width = opts.menu.width()
      end
      require("harpoon"):setup(opts)
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font } },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      local oil_util = require("oil.util")
      if not oil_util.rv_is_oil_bufnr_guarded then
        local is_oil_bufnr = oil_util.is_oil_bufnr
        oil_util.is_oil_bufnr = function(bufnr)
          if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end

          return is_oil_bufnr(bufnr)
        end
        oil_util.rv_is_oil_bufnr_guarded = true
      end

      local group = vim.api.nvim_create_augroup("RvOilAutoPreview", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "OilEnter",
        desc = "Open Oil preview by default",
        callback = function(event)
          local bufnr = event.data and event.data.buf or event.buf
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end

            local win = vim.fn.bufwinid(bufnr)
            if win == -1 or vim.wo[win].previewwindow or vim.w[win].oil_preview or vim.w[win].oil_auto_previewed then
              return
            end

            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(win)
            vim.w[win].oil_auto_previewed = true
            require("oil").open_preview()

            if vim.api.nvim_win_is_valid(current_win) then
              vim.api.nvim_set_current_win(current_win)
            end
          end)
        end,
      })
    end,
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      delete_to_trash = false,
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,
      preview_win = {
        preview_method = "load",
      },
      lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = false,
      },
      constrain_cursor = "editable",
      watch_for_changes = false,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = false,
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = false,
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        gs = { "actions.change_sort", mode = "n" },
        go = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      use_default_keymaps = true,
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name)
          return name:match("^%.") ~= nil
        end,
        is_always_hidden = function()
          return false
        end,
        natural_order = "fast",
        case_insensitive = false,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },
      git = {
        add = function()
          return false
        end,
        mv = function()
          return false
        end,
        rm = function()
          return false
        end,
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.delay = 0
      opts.icons = opts.icons or {}
      opts.icons.mappings = vim.g.have_nerd_font
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "<leader>g", group = "[G]it" },
        { "<leader>h", group = "[H]arpoon" },
        { "<leader>o", group = "[O]pen" },
        { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>w", group = "[W]indows" },
        { "gr", group = "LSP Actions", mode = { "n" } },
      })
    end,
  },
}

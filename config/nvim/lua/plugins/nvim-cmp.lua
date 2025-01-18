return {
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    lazy = false,
    dependencies = {
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-vsnip",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "buffer" },
        { name = "path" },
      }))

      opts.snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      }

      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn["vsnip#available"](1) == 1 then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "")
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      return opts
    end,
  },
  {
    "hrsh7th/vim-vsnip",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-vsnip",
    },
  },
  {
    "Nash0x7E2/awesome-flutter-snippets",
    dependencies = {
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-vsnip",
    },
    ft = { "dart" },
  },
}

-- Format on save and linters
return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- list of formatters & linters for mason to install
    require('mason-null-ls').setup {
      ensure_installed = {
        'checkmake',
        'prettier', -- ts/js formatter
        'stylua', -- lua formatter
        'eslint_d', -- ts/js linter
        'shfmt',
        'ruff',
        'gofmt',
      },
      -- auto-install configured formatters & linters (with null-ls)
      automatic_installation = true,
    }

    -- Utility to find prettier up the directory tree
    local Path = require 'plenary.path'

    local function find_upward(filename, startpath)
      local current = Path:new(startpath or vim.fn.expand '%:p'):parent()
      while current do
        local candidate = current:joinpath(filename)
        if candidate:exists() then
          return candidate:absolute()
        end
        local parent = current:parent()
        if parent:absolute() == current:absolute() then
          break
        end
        current = current:parent()
      end
      return nil
    end

    local function find_prettier()
      return find_upward 'node_modules/.bin/prettier'
    end

    local sources = {
      diagnostics.checkmake,
      formatting.prettier.with {
        filetypes = {
          'html',
          'json',
          'yaml',
          'markdown',
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'vue',
          'css',
        },
        command = find_prettier(),
        condition = function()
          return find_prettier() ~= nil
        end,
      },

      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },
      formatting.terraform_fmt,
      formatting.gofmt,
      require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
      require 'none-ls.formatting.ruff_format',
      require 'none-ls.diagnostics.eslint_d',
      require 'none-ls.code_actions.eslint_d',
      require 'none-ls.formatting.eslint_d',
    }

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    null_ls.setup {
      -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
      sources = sources,
      -- you can reuse a shared lspconfig on_attach callback here
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format {
                async = false,
                bufnr = bufnr,
                filter = function(c)
                  return c.name == 'null-ls'
                end,
              }
            end,
          })
        end
        if client.name == 'eslint_d' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { bufnr = bufnr }
            end,
          })
        end
      end,
    }
  end,
}

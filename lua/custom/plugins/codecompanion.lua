return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      chat = {
        adapter = 'gemini',
      },
      inline = {
        adapter = 'gemini',
      },
      cmd = {
        adapter = 'gemini',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<leader>A', '<cmd>CodeCompanionActions<cr>', { desc = 'Code Companion Actions', noremap = true, silent = true } },
    { '<leader>a', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'Code Companion Actions', noremap = true, silent = true } },
    { 'ga', '<cmd>CodeCompanionChat Add<cr>', mode = { 'v' }, { desc = 'Code Companion Chat Add', noremap = true, silent = true } },
  },
}

return {
  'GustavEikaas/easy-dotnet.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'mfussenegger/nvim-dap',
  },
  ft = { 'cs', 'razor', 'cshtml', 'fsharp', 'vb', 'xaml', 'sln' },
  cmd = 'Dotnet',
  -- On NixOS `dotnet` is a wrapper script, so the apphost shims for global
  -- tools (dotnet-easydotnet, roslyn-language-server) cannot locate the
  -- runtime and abort with "You must install .NET to run this application".
  -- Derive DOTNET_ROOT from the resolved `dotnet` binary so the tools inherit
  -- it. Resolved per-launch rather than hardcoded: the nix store path changes
  -- on every dotnet upgrade.
  init = function()
    if vim.env.DOTNET_ROOT then
      return
    end
    local exe = vim.fn.exepath('dotnet')
    if exe == '' then
      return
    end
    local root = vim.fs.dirname(vim.uv.fs_realpath(exe) or exe)
    if vim.uv.fs_stat(root .. '/shared') then
      vim.env.DOTNET_ROOT = root
    end
  end,
  keys = {
    { '<leader>nr', '<cmd>Dotnet run<cr>', desc = '.NET: [R]un' },
    { '<leader>nR', '<cmd>Dotnet run profile<cr>', desc = '.NET: [R]un with profile' },
    { '<leader>nw', '<cmd>Dotnet watch<cr>', desc = '.NET: [W]atch' },
    { '<leader>nd', '<cmd>Dotnet debug<cr>', desc = '.NET: [D]ebug' },
    { '<leader>nb', '<cmd>Dotnet build<cr>', desc = '.NET: [B]uild' },
    { '<leader>nB', '<cmd>Dotnet build quickfix<cr>', desc = '.NET: [B]uild to quickfix' },
    { '<leader>nt', '<cmd>Dotnet testrunner<cr>', desc = '.NET: [T]est runner' },
    { '<leader>nT', '<cmd>Dotnet test<cr>', desc = '.NET: [T]est all' },
    { '<leader>na', '<cmd>Dotnet add package<cr>', desc = '.NET: [A]dd package' },
    { '<leader>nx', '<cmd>Dotnet remove package<cr>', desc = '.NET: Remove package' },
    { '<leader>ns', '<cmd>Dotnet secrets<cr>', desc = '.NET: User [S]ecrets' },
    { '<leader>no', '<cmd>Dotnet outdated<cr>', desc = '.NET: [O]utdated packages' },
  },
  config = function()
    require('easy-dotnet').setup({
      picker = 'telescope',

      lsp = {
        enabled = true,
        preload_roslyn = true,
        roslynator_enabled = true,
        easy_dotnet_analyzer_enabled = true,
        razor = { enabled = true },
        restart_roslyn_on_branch_change = true,
      },

      debugger = {
        engine = 'netcoredbg',
        console = 'integratedTerminal',
        auto_register_dap = true,
      },

      test_runner = {
        auto_start_testrunner = false,
        viewmode = 'float',
      },

      managed_terminal = {
        auto_hide = true,
        auto_hide_delay = 1000,
      },

      diagnostics = {
        default_severity = 'error',
        setqflist = false,
      },
    })
  end,
}

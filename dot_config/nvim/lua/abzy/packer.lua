vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {'nvim-lua/plenary.nvim'}
  use {'nvim-telescope/telescope.nvim', tag = '0.1.8'}
end)

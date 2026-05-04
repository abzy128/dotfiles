return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"hyprlang",
			}

			require("nvim-treesitter").setup {
				install_dir = vim.fn.stdpath("data") .. "/site",
			}

			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(parsers)
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = parsers,
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	}
}

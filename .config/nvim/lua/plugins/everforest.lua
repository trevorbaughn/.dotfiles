return{
	{
      	'neanias/everforest-nvim',
      	lazy = false,
      	priority = 1001,
      	config = function()
        	-- Optionally configure and load the colorscheme
        	-- directly inside the plugin declaration.
        	-- vim.g.everforest_enable_italic = true
		require("everforest").setup({
			transparent_background_level = 2,
		})
        	-- vim.cmd.colorscheme('everforest')
      	end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
		colorscheme = "everforest",
		},
	},
}

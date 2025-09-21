return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "master",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {"lua", "c", "cpp", "go", "javascript", "typescript"},
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}

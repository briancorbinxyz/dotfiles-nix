return {
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    keys = {
      { "<C-p>", "<cmd>Files<cr>", desc = "Find Files" },
      { "<leader>ff", "<cmd>Files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>GFiles<cr>", desc = "Git Files" },
      { "<leader>fb", "<cmd>Buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>History<cr>", desc = "History" },
      { "<leader>fr", "<cmd>Rg<cr>", desc = "Ripgrep" },
      { "<leader>fl", "<cmd>Lines<cr>", desc = "Lines" },
      { "<leader>fc", "<cmd>Commits<cr>", desc = "Commits" },
    },
    cmd = { "Files", "GFiles", "Buffers", "Rg", "Lines", "History", "Commits", "Commands" },
  },
}

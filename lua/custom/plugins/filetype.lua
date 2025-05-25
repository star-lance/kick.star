-- Custom filetype detection for TypeScript React files
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
  },
  pattern = {
    [".*%.tsx"] = "typescriptreact",
  },
})

return {}

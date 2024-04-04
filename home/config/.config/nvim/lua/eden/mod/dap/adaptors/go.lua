local dap = require("dap")
local dutils = require("dap.utils")
local util = require("eden.mod.dap.util")

dap.adapters.go = {
  type = "executable",
  command = "node",
  args = { vim.fn.stdpath("data") .. "/mason/bin/go-debug-adapter" },
}

dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    showLog = false,
    program = "${file}",
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed
  },
}
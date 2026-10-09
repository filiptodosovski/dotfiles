-- Run by bootstrap/update, or with -u NONE for the read-only doctor.
local function run()
  local root = assert(vim.env.DOTFILES_DIR, "DOTFILES_DIR is missing")
  local languages = dofile(root .. "/nvim/lua/fit0/languages.lua")
  local data = vim.fn.stdpath("data")
  local checking = vim.env.DOTFILES_CHECK == "1"

  for _, plugin in ipairs({ "mason.nvim", "mason-lspconfig.nvim" }) do
    local path = data .. "/lazy/" .. plugin
    assert(vim.uv.fs_stat(path), "Missing plugin: " .. plugin .. "; run bootstrap.sh")
    vim.opt.runtimepath:append(path)
  end

  if checking then
    require("mason").setup({
      PATH = "skip",
      log_level = vim.log.levels.OFF,
      registry_cache = { refresh = false },
    })
  end
  local registry = require("mason-registry")
  if not checking then
    -- MasonUpdate blocks in headless mode; verify registry refresh succeeded too.
    local async = require("mason-core.async")
    async.run_blocking(function()
      assert(async.wait(registry.update), "Could not update the Mason registry")
    end)
  end
  local mapping = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  local packages = vim.tbl_map(function(server)
    return assert(mapping[server], "No Mason package found for " .. server)
  end, languages.mason)

  if not checking then
    vim.cmd.MasonInstall({ args = vim.list_extend({ "--quiet" }, packages) })
    local ts = require("nvim-treesitter")
    ts.install(languages.parsers):wait(300000)
    ts.update(languages.parsers):wait(300000)
  end

  for _, package in ipairs(packages) do
    assert(registry.get_package(package):is_installed(), "Missing server: " .. package)
    local receipt = data .. "/mason/packages/" .. package .. "/mason-receipt.json"
    assert(vim.uv.fs_stat(receipt), "Missing server receipt: " .. package)
    local installed = vim.json.decode(table.concat(vim.fn.readfile(receipt), "\n"))
    for executable in pairs(installed.links and installed.links.bin or {}) do
      assert(
        vim.fn.executable(data .. "/mason/bin/" .. executable) == 1,
        "Missing server executable: " .. executable
      )
    end
    print("server OK          " .. package)
  end
  for _, parser in ipairs(languages.parsers) do
    local path = data .. "/site/parser/" .. parser .. ".so"
    assert(vim.uv.fs_stat(path), "Missing parser: " .. parser)
    print("parser OK          " .. parser)
  end
end

local ok, err = pcall(run)
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd("cquit 1")
end

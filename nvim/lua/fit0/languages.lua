-- Shared by LSP setup and bootstrap. Ruff/ty/StyLua are Homebrew CLI tools.
return {
  servers = { "vtsls", "eslint", "gopls", "lua_ls", "ruff", "ty", "html", "tailwindcss" },
  mason = { "vtsls", "eslint", "gopls", "lua_ls", "html", "tailwindcss" },
  parsers = {
    "typescript",
    "tsx",
    "javascript",
    "go",
    "lua",
    "python",
    "html",
    "css",
    "json",
    -- Markdown and vimdoc also support editor documentation and injected LSP docs.
    "markdown",
    "markdown_inline",
    "vimdoc",
  },
}

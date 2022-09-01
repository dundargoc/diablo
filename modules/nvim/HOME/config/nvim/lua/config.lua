------------
-- global --
------------

local keyopts = { noremap=true, silent=true }

------------------------
-- base functionality --
------------------------

-- autosplit.nvim
-- https://github.com/ii14/autosplit.nvim
vim.cmd [[
    set splitright

    let g:autosplit_loaded = 1
    au WinNew * lua require('autosplit')()
]]

-- spaceless.nvim
-- https://github.com/lewis6991/spaceless.nvim
require('spaceless').setup()

-- stabilize.nvim
-- https://github.com/luukvbaal/stabilize.nvim
require('stabilize').setup()

-----------------------------
-- themes and highlighting --
-----------------------------

-- nightfox.nvim
-- https://github.com/EdenEast/nightfox.nvim
vim.cmd("colorscheme nightfox")

-- lualine.nvim
-- https://github.com/nvim-lualine/lualine.nvin
require('lualine').setup({
    sections = {
        lualine_b = {
            'branch', 'diff',
            {
                'diagnostics',
                symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            }
        },
        lualine_x = { },
        lualine_y = { 'filetype' },
        lualine_z = { 'location' }
    }
})

-- nvim-colorizer
-- https://github.com/norcalli/nvim-colorizer.lua
require('colorizer').setup()

-- todo-comments.nvim
-- https://github.com/folke/todo-comments.nvim
require('todo-comments').setup()

----------------
-- navigation --
----------------

-- trouble.nvim
-- https://github.com/folke/trouble.nvim
local trouble = require('trouble');

trouble.setup {
    auto_open = false,
    auto_close = true,

    -- remove icons
    icons = false,
    fold_open = "v",
    fold_closed = ">",
    indent_lines = false,
    signs = {
        error = "E",
        warning = "W",
        hint = "H",
        information = "I"
    },
    use_diagnostic_signs = false
}

vim.cmd [[
    nnoremap <leader>x <cmd>TroubleToggle<cr>
    nnoremap <leader>d <cmd>TroubleToggle workspace_diagnostics<cr>
    nnoremap <leader>q <cmd>TroubleToggle quickfix<cr>
    nnoremap <leader>l <cmd>TroubleToggle loclist<cr>
    nnoremap gr        <cmd>TroubleToggle lsp_references<cr>
]]

local troubleopts = { skip_group=true, jump=true }
vim.keymap.set('n', '[q', function() trouble.next(troubleopts) end, keyopts)
vim.keymap.set('n', ']q', function() trouble.previous(troubleopts) end, keyopts)

-- telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim.git
local telescope = require('telescope');

telescope.setup({
    defaults = {
        mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
        }
    }
})

vim.cmd [[
    nnoremap / <cmd>Telescope current_buffer_fuzzy_find<cr>
    nnoremap <C-`> <cmd>Telescope buffers<cr>
    nnoremap <leader>f <cmd>Telescope find_files find_command=fd<cr>
    nnoremap <leader>/ <cmd>Telescope live_grep<cr>
]]

----------------
-- treesitter --
----------------

-- nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter.install').update({
    with_sync = true
})

require('nvim-treesitter.configs').setup({
    auto_install = true,

    highlight = {
        enable = true
    },

    indent = {
        enable = true
    },

    rainbow = {
        enable = true,
        extended_mode = true
    }
})

vim.cmd [[
    set nofoldenable
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
]]

---------
-- lsp --
---------

-- nvim-lspconfig
-- https://github.com/neovim/nvim-lspconfig.git,master
local lspfmt = vim.api.nvim_create_augroup('LspFormatting', {})

local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>c', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gq', vim.lsp.buf.formatting, bufopts)

    -- format on save
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#sync-formatting
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = lspfmt, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = lspfmt,
            buffer = bufnr,
            callback = function()
                -- 0.8: vim.lsp.buf.format({ bufnr = bufnr })
                vim.lsp.buf.formatting_sync()
            end,
        })
    end
end

vim.cmd [[
    " https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#highlight-line-number-instead-of-having-icons-in-sign-column
    sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticVirtualTextError
    sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticVirtualTextWarn
    sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineVirtualTextInfo
    sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticVirtualTextHint
]]

-- vim-illuminate
-- https://github.com/RRethy/vim-illuminate
require('illuminate').configure()

-- lsp_lines
-- https://git.sr.ht/~whynothugo/lsp_lines.nvim
require('lsp_lines').setup()

-- lsp_signature
-- https://github.com/ray-x/lsp_signature.nvim
require('lsp_signature').setup()

vim.diagnostic.config({
    virtual_text = false,
})

-- null-ls.nvim
-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require('null-ls')

local code_actions = null_ls.builtins.code_actions
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting

null_ls.setup({
    sources = {
        -- generic
        code_actions.gitsigns,

        -- js/ts et al, css et al, html, json, yaml, md, etc
        formatting.prettier,

        -- c, c++, c#, java, etc
        formatting.uncrustify,

        -- fish
        diagnostics.fish,
        formatting.fish_indent,

        -- html, xml
        formatting.tidy,

        -- xml
        formatting.xmllint,

        -- lua
        diagnostics.luacheck,

        -- sh
        code_actions.shellcheck,
        formatting.shfmt,

        -- yaml
        diagnostics.yamllint.with({
            extra_args = { "-d", "{ extends: default, rules: { braces: { max-spaces-inside: 999 }, document-start: { present: false }, line-length: { max: 120 } } }" },
        }),
    },

    on_attach = on_attach,
    diagnostics_format = "[#{m} (#{s})", -- msg (src)
    log_level = "trace"
})

-- rust-tools.nvim
-- https://github.com/simrat39/rust-tools.nvim
local rust_tools = require("rust-tools")

rust_tools.setup({
    server = {
        on_attach = on_attach
    }
})

--------------------------------------
-- other languages-specific support --
--------------------------------------

-- crates.nvim
-- https://github.com/Saecki/crates.nvim
require('crates').setup({
    text = {
        loading = "  Loading...",
        version = "  %s",
        prerelease = "  %s",
        yanked = "  %s yanked",
        nomatch = "  Not found",
        upgrade = "  %s",
        error = "  Error fetching crate",
    },
    popup = {
        text = {
            title = "# %s",
            pill_left = "",
            pill_right = "",
            created_label = "created        ",
            updated_label = "updated        ",
            downloads_label = "downloads      ",
            homepage_label = "homepage       ",
            repository_label = "repository     ",
            documentation_label = "documentation  ",
            crates_io_label = "crates.io      ",
            categories_label = "categories     ",
            keywords_label = "keywords       ",
            version = "%s",
            prerelease = "%s pre-release",
            yanked = "%s yanked",
            enabled = "* s",
            transitive = "~ s",
            normal_dependencies_title = "  Dependencies",
            build_dependencies_title = "  Build dependencies",
            dev_dependencies_title = "  Dev dependencies",
            optional = "? %s",
            loading = " ...",
        },
    },
    src = {
        text = {
            prerelease = " pre-release ",
            yanked = " yanked ",
        },
    },
    null_ls = {
        enabled = true,
        name = "crates",
    },
})

----------------------------------
-- external tooling integration --
----------------------------------

-- vim-oscyank
-- https://github.com/ojroques/vim-oscyank
vim.cmd [[
    let g:oscyank_term = 'default'

    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif
let g:clipboard = {
        \   'name': 'osc52',
        \   'copy': {
        \     '+': {lines, regtype -> OSCYankString(join(lines, "\n"))},
        \     '*': {lines, regtype -> OSCYankString(join(lines, "\n"))},
        \   },
        \   'paste': {
        \     '+': {-> [split(getreg(''), '\n'), getregtype('')]},
        \     '*': {-> [split(getreg(''), '\n'), getregtype('')]},
        \   },
        \ }
]]

-- vim-tmux-navigation
-- https://github.com/christoomey/vim-tmux-navigator
vim.cmd [[
    let g:tmux_navigator_preserve_zoom = 1
    nnoremap <silent> <C-Space> :TmuxNavigatePrevious<cr>
]]

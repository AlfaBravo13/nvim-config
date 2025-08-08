--[[
    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ setting options ]]
-- see `:help vim.o`
--  for more options, you can see `:help option-list`

-- make line numbers default
vim.o.number = true
-- you can also add relative line numbers, to help with jumping.
--  experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- don't show the mode, since it's already in the status line
vim.o.showmode = false

-- sync clipboard between os and neovim.
--  schedule the setting after `uienter` because it can increase startup-time.
--  remove this option if you want your os clipboard to remain independent.
--  see `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- enable break indent
vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

-- case-insensitive searching unless \c or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- decrease update time
vim.o.updatetime = 250

-- decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- sets how neovim will display certain whitespace characters in the editor.
--  see `:help 'list'`
--  and `:help 'listchars'`
--
--  notice listchars is set using `vim.opt` instead of `vim.o`.
--  it is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   see `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- show which line your cursor is on
vim.o.cursorline = true

-- minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- see `:help 'confirm'`
vim.o.confirm = true

-- [[ basic keymaps ]]
--  see `:help vim.keymap.set()`

-- clear highlights on search when pressing <esc> in normal mode
--  see `:help hlsearch`
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')

-- diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'open diagnostic [q]uickfix list' })

-- [[ basic autocommands ]]
--  see `:help lua-guide-autocommands`

-- highlight when yanking (copying) text
--  try it with `yap` in normal mode
--  see `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('textyankpost', {
  desc = 'highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ install `lazy.nvim` plugin manager ]]
--    see `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ configure and install plugins ]]
--
--  to check the current status of your plugins, run
--    :lazy
--
--  you can press `?` in this menu for help. use `:q` to close the window
--
--  to update plugins you can run
--    :lazy update
--
-- note: here is where you install your plugins.
require('lazy').setup({
  -- note: plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'nmac427/guess-indent.nvim', -- detect tabstop and shiftwidth automatically

  -- note: plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- alternatively, use `config = function() ... end` for full control over the configuration.
  -- if you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- see `:help gitsigns` to understand what the configuration keys do
  { -- adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- note: plugins can also be configured to run lua code when they are loaded.
  --
  -- this is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- for example, in the following configuration, we use:
  --  event = 'vimenter'
  --
  -- which loads which-key before all the ui elements are loaded. events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(module).setup(opts)`.

  { -- useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'vimenter', -- sets the loading event to 'vimenter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a nerd font
        mappings = vim.g.have_nerd_font,
        -- if you are using a nerd font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined nerd font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          up = '<up> ',
          down = '<down> ',
          left = '<left> ',
          right = '<right> ',
          c = '<c-…> ',
          m = '<m-…> ',
          d = '<d-…> ',
          s = '<s-…> ',
          cr = '<cr> ',
          esc = '<esc> ',
          scrollwheeldown = '<scrollwheeldown> ',
          scrollwheelup = '<scrollwheelup> ',
          nl = '<nl> ',
          bs = '<bs> ',
          space = '<space> ',
          tab = '<tab> ',
          f1 = '<f1>',
          f2 = '<f2>',
          f3 = '<f3>',
          f4 = '<f4>',
          f5 = '<f5>',
          f6 = '<f6>',
          f7 = '<f7>',
          f8 = '<f8>',
          f9 = '<f9>',
          f10 = '<f10>',
          f11 = '<f11>',
          f12 = '<f12>',
        },
      },

      -- document existing key chains
      spec = {
        { '<leader>s', group = '[s]earch' },
        { '<leader>t', group = '[t]oggle' },
        { '<leader>h', group = 'git [h]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- note: plugins can specify dependencies.
  --
  -- the dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- use the `dependencies` key to specify the dependencies of a particular plugin

  { -- fuzzy finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'vimenter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- if encountering errors, see telescope-fzf-native readme for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- this is only run then, not every time neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- useful for getting pretty icons, but requires a nerd font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! it's more than just a "file finder", it can search
      -- many different aspects of neovim, your workspace, lsp, and more!
      --
      -- the easiest way to use telescope, is to start by doing something like:
      --  :telescope help_tags
      --
      -- after running this command, a window will open up and you're able to
      -- type in the prompt window. you'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- two important keymaps to use while in telescope are:
      --  - insert mode: <c-/>
      --  - normal mode: ?
      --
      -- this opens a window that shows you all of the keymaps for the current
      -- telescope picker. this is really useful to discover what telescope can
      -- do as well as how to actually do it!

      -- [[ configure telescope ]]
      -- see `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- you can put your default mappings / updates / etc. in here
        --  all the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- enable telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- see `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[s]earch [s]elect telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[s]earch current [w]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [d]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[s]earch recent files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] find existing buffers' })

      -- slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- you can pass additional configuration to telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] fuzzily search in current buffer' })

      -- it's also possible to pass additional configuration options.
      --  see `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'live grep in open files',
        }
      end, { desc = '[s]earch [/] in open files' })

      -- shortcut for searching your neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[s]earch [n]eovim files' })
    end,
  },

  -- lsp plugins
  {
    -- `lazydev` configures lua lsp for your neovim config, runtime and plugins
    -- used for completion, annotations and signatures of neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- main lsp configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- automatically install lsps and related tools to stdpath for neovim
      -- mason must be loaded before its dependents so we need to set it up here.
      -- note: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'whoissethdaniel/mason-tool-installer.nvim',

      -- useful status updates for lsp.
      { 'j-hui/fidget.nvim', opts = {} },

      -- allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- brief aside: **what is lsp?**
      --
      -- lsp is an initialism you've probably heard, but might not understand what it is.
      --
      -- lsp stands for language server protocol. it's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- in general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). these language servers
      -- (sometimes called lsp servers, but that's kind of like atm machine) are standalone
      -- processes that communicate with some "client" - in this case, neovim!
      --
      -- lsp provides neovim with features like:
      --  - go to definition
      --  - find references
      --  - autocompletion
      --  - symbol search
      --  - and more!
      --
      -- thus, language servers are external tools that must be installed separately from
      -- neovim. this is where `mason` and related plugins come into play.
      --
      -- if you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  this function gets run when an lsp attaches to a particular buffer.
      --    that is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('lspattach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- note: remember that lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- in this case, we create a function that lets us more easily define mappings specific
          -- for lsp related items. it sets the mode, buffer and description for us each time.
          local map = function(key, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, key, func, { buffer = event.buf, desc = 'lsp: ' .. desc })
          end

          -- rename the variable under your cursor.
          --  most language servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[r]e[n]ame')

          -- execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your lsp for this to activate.
          map('gra', vim.lsp.buf.code_action, '[g]oto code [a]ction', { 'n', 'x' })

          -- find references for the word under your cursor.
          map('grr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')

          -- jump to the implementation of the word under your cursor.
          --  useful when your language has ways of declaring types without an actual implementation.
          map('gri', require('telescope.builtin').lsp_implementations, '[g]oto [i]mplementation')

          -- jump to the definition of the word under your cursor.
          --  this is where a variable was first declared, or where a function is defined, etc.
          --  to jump back, press <c-t>.
          map('grd', require('telescope.builtin').lsp_definitions, '[g]oto [d]efinition')

          -- warn: this is not goto definition, this is goto declaration.
          --  for example, in c this would take you to the header.
          map('grd', vim.lsp.buf.declaration, '[g]oto [d]eclaration')

          -- fuzzy find all the symbols in your current document.
          --  symbols are things like variables, functions, types, etc.
          map('go', require('telescope.builtin').lsp_document_symbols, 'open document symbols')

          -- fuzzy find all the symbols in your current workspace.
          --  similar to document symbols, except searches over your entire project.
          map('gw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'open workspace symbols')

          -- jump to the type of the word under your cursor.
          --  useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', require('telescope.builtin').lsp_type_definitions, '[g]oto [t]ype definition')

          -- this function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.client
          ---@param method vim.lsp.protocol.method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- the following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    see `:help cursorhold` for information about when this is executed
          --
          -- when you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.methods.textdocument_documenthighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'cursorhold', 'cursorholdi' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'cursormoved', 'cursormovedi' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('lspdetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- the following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- this may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.methods.textdocument_inlayhint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[t]oggle inlay [h]ints')
          end
        end,
      })

      -- diagnostic config
      -- see :help vim.diagnostic.opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.error },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.error] = '󰅚 ',
            [vim.diagnostic.severity.warn] = '󰀪 ',
            [vim.diagnostic.severity.info] = '󰋽 ',
            [vim.diagnostic.severity.hint] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.error] = diagnostic.message,
              [vim.diagnostic.severity.warn] = diagnostic.message,
              [vim.diagnostic.severity.info] = diagnostic.message,
              [vim.diagnostic.severity.hint] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- lsp servers and clients are able to communicate to each other what features they support.
      --  by default, neovim doesn't support everything that is in the lsp specification.
      --  when you add blink.cmp, luasnip, etc. neovim now has *more* capabilities.
      --  so, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- enable the following language servers
      --  feel free to add/remove any lsps that you want here. they will automatically be installed.
      --
      --  add any additional override configuration in the following tables. available keys are:
      --  - cmd (table): override the default command used to start the server
      --  - filetypes (table): override the default list of associated filetypes for the server
      --  - capabilities (table): override fields in capabilities. can be used to disable certain lsp features.
      --  - settings (table): override the default settings passed when initializing the server.
      --        for example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- see `:help lspconfig-all` for a list of all the pre-configured lsps
        --
        ts_ls = {},
        dockerls = {},

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            lua = {
              completion = {
                callsnippet = 'replace',
              },
              -- you can toggle below to ignore lua_ls's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- ensure the servers and tools above are installed
      --
      -- to check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :mason
      --
      -- you can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- you can add other tools here that you want mason to install
      -- for you, so that they are available from within neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- used to format lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- this handles overriding only values explicitly passed
            -- by the server configuration above. useful when disabling
            -- certain features of an lsp (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- autoformat
    'stevearc/conform.nvim',
    event = { 'bufwritepre' },
    cmd = { 'conforminfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[f]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. you can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- you can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- autocompletion
    'saghen/blink.cmp',
    event = 'vimenter',
    version = '1.*',
    dependencies = {
      -- snippet engine
      {
        'l3mon4d3/luasnip',
        version = '2.*',
        build = (function()
          -- build step is needed for regex support in snippets.
          -- this step is not supported in many windows environments.
          -- remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    see the readme about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    this will auto-import if your lsp supports it.
        --    this will expand snippets if the lsp sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- for an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- no, but seriously. please read `:help ins-completion`, it is really good!
        --
        -- all presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: select next/previous item
        -- <c-e>: hide menu
        -- <c-k>: toggle signature help
        --
        -- see :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',

        -- for more advanced luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/l3mon4d3/luasnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'nerd font mono' or 'normal' for 'nerd font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- by default, you may press `<c-space>` to show the documentation.
        -- optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- by default, we use the lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- see :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  { -- you can easily change to a different colorscheme.
    -- change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- if you want to see what colorschemes are already installed, you can use `:telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- disable italics in comments
        },
      }

      -- load the colorscheme here.
      -- like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'vimenter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- better around/inside textobjects
      --
      -- examples:
      --  - va)  - [v]isually select [a]round [)]paren
      --  - yinq - [y]ank [i]nside [n]ext [q]uote
      --  - ci'  - [c]hange [i]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [s]urround [a]dd [i]nner [w]ord [)]paren
      -- - sd'   - [s]urround [d]elete [']quotes
      -- - sr)'  - [s]urround [r]eplace [)] [']
      require('mini.surround').setup()

      -- simple and easy statusline.
      --  you could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a nerd font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- you can configure sections in the statusline by overriding their
      -- default behavior. for example, here we set the section for
      -- cursor location to line:column
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':tsupdate',
    main = 'nvim-treesitter.configs', -- sets main module to use for opts
    -- [[ configure treesitter ]] see `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- some languages depend on vim's regex highlighting system (such as ruby) for indent rules.
        --  if you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- there are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. you should go explore a few and see what interests you:
    --
    --    - incremental selection: included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  --  here are some example plugins that i've included in the kickstart repository.
  --  uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- note: the import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    this is the easiest way to modularize your config.
  --
  --  uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- for additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- or use telescope!
  -- in normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- if you are using a nerd font: set icons to an empty table which will use the
    -- default lazy.nvim defined nerd font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- the line beneath this is called `modeline`. see `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

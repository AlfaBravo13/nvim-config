-- OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.scrolloff = 10
vim.o.confirm = true

-- KEYMAPS
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "open diagnostic [q]uickfix list" })

-- AUTOCOMMANDS
vim.api.nvim_create_autocmd("textyankpost", {
	desc = "highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- LAZY SETUP
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		"nmac427/guess-indent.nvim",
		{
			"lewis6991/gitsigns.nvim",
			enabled = false,
			opts = {
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
			},
		},
		{
			"folke/which-key.nvim",
			event = "vimenter",
			opts = {
				delay = 0,
				icons = {
					mappings = vim.g.have_nerd_font,
					keys = vim.g.have_nerd_font and {} or {
						up = "<up> ",
						down = "<down> ",
						left = "<left> ",
						right = "<right> ",
						c = "<c-…> ",
						m = "<m-…> ",
						d = "<d-…> ",
						s = "<s-…> ",
						cr = "<cr> ",
						esc = "<esc> ",
						scrollwheeldown = "<scrollwheeldown> ",
						scrollwheelup = "<scrollwheelup> ",
						nl = "<nl> ",
						bs = "<bs> ",
						space = "<space> ",
						tab = "<tab> ",
						f1 = "<f1>",
						f2 = "<f2>",
						f3 = "<f3>",
						f4 = "<f4>",
						f5 = "<f5>",
						f6 = "<f6>",
						f7 = "<f7>",
						f8 = "<f8>",
						f9 = "<f9>",
						f10 = "<f10>",
						f11 = "<f11>",
						f12 = "<f12>",
					},
				},

				spec = {
					{ "<leader>s", group = "[s]earch" },
					{ "<leader>t", group = "[t]oggle" },
					{ "<leader>h", group = "git [h]unk", mode = { "n", "v" } },
				},
			},
		},
		{
			"nvim-telescope/telescope.nvim",
			event = "vimenter",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
					cond = function()
						return vim.fn.executable("make") == 1
					end,
				},
				{ "nvim-telescope/telescope-ui-select.nvim" },
				{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
			},
			config = function()
				require("telescope").setup({
					extensions = {
						["ui-select"] = {
							require("telescope.themes").get_dropdown(),
						},
					},
				})
				pcall(require("telescope").load_extension, "fzf")
				pcall(require("telescope").load_extension, "ui-select")
				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
				vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[s]earch [k]eymaps" })
				vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
				vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[s]earch [s]elect telescope" })
				vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[s]earch current [w]ord" })
				vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[s]earch by [g]rep" })
				vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[s]earch [d]iagnostics" })
				vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[s]earch [r]esume" })
				vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[s]earch recent files ("." for repeat)' })
				vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] find existing buffers" })

				vim.keymap.set("n", "<leader>/", function()
					builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end, { desc = "[/] fuzzily search in current buffer" })

				vim.keymap.set("n", "<leader>s/", function()
					builtin.live_grep({
						grep_open_files = true,
						prompt_title = "live grep in open files",
					})
				end, { desc = "[s]earch [/] in open files" })

				vim.keymap.set("n", "<leader>sn", function()
					builtin.find_files({ cwd = vim.fn.stdpath("config") })
				end, { desc = "[s]earch [n]eovim files" })
			end,
		},
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{ "mason-org/mason.nvim", opts = {} },
				"mason-org/mason-lspconfig.nvim",
				"whoissethdaniel/mason-tool-installer.nvim",
				{ "j-hui/fidget.nvim", opts = {} },
				"saghen/blink.cmp",
			},
			config = function()
				vim.api.nvim_create_autocmd("lspattach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
					callback = function(event)
						local map = function(key, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, key, func, { buffer = event.buf, desc = "lsp: " .. desc })
						end
						map("grn", vim.lsp.buf.rename, "[r]e[n]ame")
						map("gra", vim.lsp.buf.code_action, "[g]oto code [a]ction", { "n", "x" })
						map("grr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")
						map("gri", require("telescope.builtin").lsp_implementations, "[g]oto [i]mplementation")
						map("grd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")
						map("grd", vim.lsp.buf.declaration, "[g]oto [d]eclaration")
						map("go", require("telescope.builtin").lsp_document_symbols, "open document symbols")
						map("gw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "open workspace symbols")
						map("grt", require("telescope.builtin").lsp_type_definitions, "[g]oto [t]ype definition")
						---@param client vim.lsp.client
						---@param method vim.lsp.protocol.method
						---@param bufnr? integer
						---@return boolean
						local function client_supports_method(client, method, bufnr)
							if vim.fn.has("nvim-0.11") == 1 then
								return client:supports_method(method, bufnr)
							else
								return client.supports_method(method, { bufnr = bufnr })
							end
						end

						local client = vim.lsp.get_client_by_id(event.data.client_id)
						if
							client
							and client_supports_method(
								client,
								vim.lsp.protocol.methods.textdocument_documenthighlight,
								event.buf
							)
						then
							local highlight_augroup =
								vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
							vim.api.nvim_create_autocmd({ "cursorhold", "cursorholdi" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.document_highlight,
							})

							vim.api.nvim_create_autocmd({ "cursormoved", "cursormovedi" }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.clear_references,
							})

							vim.api.nvim_create_autocmd("lspdetach", {
								group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
								callback = function(event2)
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds({
										group = "kickstart-lsp-highlight",
										buffer = event2.buf,
									})
								end,
							})
						end

						if
							client
							and client_supports_method(
								client,
								vim.lsp.protocol.methods.textdocument_inlayhint,
								event.buf
							)
						then
							map("<leader>th", function()
								vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
							end, "[t]oggle inlay [h]ints")
						end
					end,
				})

				vim.diagnostic.config({
					severity_sort = true,
					float = { border = "rounded", source = "if_many" },
					underline = { severity = vim.diagnostic.severity.error },
					signs = vim.g.have_nerd_font and {
						text = {
							[vim.diagnostic.severity.error] = "󰅚 ",
							[vim.diagnostic.severity.warn] = "󰀪 ",
							[vim.diagnostic.severity.info] = "󰋽 ",
							[vim.diagnostic.severity.hint] = "󰌶 ",
						},
					} or {},
					virtual_text = {
						source = "if_many",
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
				})

				local capabilities = require("blink.cmp").get_lsp_capabilities()

				local servers = {
					ts_ls = {},
					lua_ls = {
						settings = {
							lua = {
								completion = {
									callsnippet = "replace",
								},
							},
						},
					},
				}
				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					"stylua",
				})
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

				require("mason-lspconfig").setup({
					ensure_installed = {},
					automatic_installation = false,
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							server.capabilities =
								vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
							require("lspconfig")[server_name].setup(server)
						end,
					},
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			event = { "Bufwritepre" },
			cmd = { "Conforminfo" },
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end,
					mode = "",
					desc = "[f]ormat buffer",
				},
			},
			opts = {
				notify_on_error = false,
				format_on_save = function(bufnr)
					local disable_filetypes = { c = true, cpp = true }
					if disable_filetypes[vim.bo[bufnr].filetype] then
						return nil
					else
						return {
							timeout_ms = 500,
							lsp_format = "fallback",
						}
					end
				end,
				formatters_by_ft = {
					lua = { "stylua" },
				},
			},
		},
		{
			"saghen/blink.cmp",
			event = "vimenter",
			version = "1.*",
			dependencies = {
				{
					"l3mon4d3/luasnip",
					version = "2.*",
					build = (function()
						if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
							return
						end
						return "make install_jsregexp"
					end)(),
					dependencies = {},
					opts = {},
				},
				"folke/lazydev.nvim",
			},
			--- @module 'blink.cmp'
			--- @type blink.cmp.config
			opts = {
				keymap = {
					preset = "default",
				},
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = {
					documentation = { auto_show = false, auto_show_delay_ms = 500 },
				},
				sources = {
					default = { "lsp", "path", "snippets", "lazydev" },
					providers = {
						lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
					},
				},
				snippets = { preset = "luasnip" },
				fuzzy = { implementation = "lua" },
				signature = { enabled = true },
			},
		},
		{
			"folke/tokyonight.nvim",
			priority = 1000,
			config = function()
				---@diagnostic disable-next-line: missing-fields
				require("tokyonight").setup({
					styles = {
						comments = { italic = false }, -- disable italics in comments
					},
				})
				vim.cmd.colorscheme("tokyonight-night")
			end,
		},
		{
			"folke/todo-comments.nvim",
			event = "vimenter",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = { signs = false },
		},
		{
			"echasnovski/mini.nvim",
			config = function()
				require("mini.ai").setup({ n_lines = 500 })
				require("mini.surround").setup()
				local statusline = require("mini.statusline")
				statusline.setup({ use_icons = vim.g.have_nerd_font })
				---@diagnostic disable-next-line: duplicate-set-field
				statusline.section_location = function()
					return "%2l:%-2v"
				end
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":tsupdate",
			main = "nvim-treesitter.configs",
			opts = {
				ensure_installed = {
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
				},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },
			},
		},
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- the line beneath this is called `modeline`. see `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

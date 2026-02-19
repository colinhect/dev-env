--: Options
vim.g.mapleader = ' '
vim.g.editorconfig = false
vim.o.backup = false
vim.o.expandtab = true
vim.o.incsearch = true
vim.o.number = true
vim.o.scrolloff = 8
vim.o.shiftwidth = 4
vim.o.showmode = false
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.updatetime = 50
vim.o.wrap = false
vim.o.hlsearch = true
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.autoread = true
vim.opt.shortmess:append("I") -- Don't show start-up message
--:

--: Basic keymaps
vim.keymap.set('v', '>', '>gv', { noremap = true })
vim.keymap.set('v', '<', '<gv', { noremap = true })

vim.keymap.set('n', 'gt', ':bn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'gT', ':bp<CR>', { noremap = true, silent = true })

vim.keymap.set('n', 'qn', ':cnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'qp', ':cprev<CR>', { noremap = true, silent = true })

vim.keymap.set('', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('', '<C-l>', '<C-w>l', { noremap = true })

vim.keymap.set('v', '<C-c>', '"+y')
vim.api.nvim_set_keymap("n", "<C-c>", [[:lua vim.fn.setreg('+', vim.fn.getline('.'))<CR>]],
	{ noremap = true, silent = true })
--:

--: nord
vim.pack.add({
	{ src = "https://github.com/shaunsingh/nord.nvim" },
})
-- sed -i 's/2E3440/07080A/g'  ~/.local/share/nvim/site/pack/core/opt/nord.nvim/lua/nord/named_colors.lua

vim.cmd([[ colorscheme nord ]])
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
--:

--: whichkey
vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim" },
})

local whichkey = require("which-key")
whichkey.add(
    {
        { "<leader>a", group = "AI" },
        { "<leader>f", group = "Files" },
        { "<leader>s", group = "Search" },
        { "<leader>l", group = "LSP" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" },
        { "<leader>u", group = "UI" },
        { "<leader>d", group = "Debugger" },
        { "<leader>x", group = "Execute Code" },
    }, { mode = "n" })
--:

--: treesitter
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version="main" },
})

require 'nvim-treesitter'.install { 'python', 'bash', 'rust', 'html', 'xml', 'json', 'yaml', 'javascript', 'c', 'cpp', 'markdown', 'markdown_inline', 'lua', 'diff', 'html', 'latex', 'yaml',  }
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'markdown_inline', 'copilot-chat', 'python', 'cpp', 'c', 'lua', 'diff', 'rust', 'bash' },
  callback = function() vim.treesitter.start() end,
})

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context.git" },
})
local tsc = require("treesitter-context")
tsc.setup{
  enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  separator = '─',

}
function toggle_treesitter_context()
    tsc.toggle()
end
vim.keymap.set({'n', 'i'}, "<leader>ut", toggle_treesitter_context, { desc = "Toggle Treesitter Context" })
--:

--: nvim-tree
vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { desc = "File Tree" })
require("nvim-tree").setup({
	view = {
		adaptive_size = true,
	},
	update_focused_file = {
		enable = true,
	},
	sync_root_with_cwd = true,
	respect_buf_cwd = true,
})
--:

--: blink.cmp
vim.pack.add({
	{ src = "https://github.com/Saghen/blink.cmp", version = "v1.9.1" },
})
require("blink.cmp").setup({
	keymap = { preset = 'default' },
	appearance = {
		nerd_font_variant = 'mono'
	},
	completion = { documentation = { auto_show = true } },
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
	fuzzy = { implementation = "prefer_rust" }
})
--:

--: telescope
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
})

local telescope_builtin = require('telescope.builtin')

require('telescope').setup({
	pickers = {
		buffers = {
			initial_mode = "normal",
		},
		bookmarks = {
			initial_mode = "normal",
		},
	},
})

vim.keymap.set('n', '<leader>b', telescope_builtin.buffers, { desc = 'Open Buffers' })

vim.keymap.set('n', '<leader><space>', telescope_builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fr', telescope_builtin.oldfiles, { desc = 'Find Recent Files' })

vim.keymap.set('n', '<leader>/', telescope_builtin.live_grep, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>sf', telescope_builtin.live_grep, { desc = 'Search Files' })
--vim.keymap.set('n', '<leader>sb', ":vimgrep /<string>/ % | copen", { desc = 'Search Current Buffer' })
vim.keymap.set('n', '<leader>sq', telescope_builtin.quickfix, { desc = 'Search Quickfix' })
vim.keymap.set('n', '<leader>sk', telescope_builtin.keymaps, { desc = 'Search Keymaps' })
vim.keymap.set('n', '<leader>sh', telescope_builtin.help_tags, { desc = 'Search Help' })
vim.keymap.set('n', '<leader>sw', telescope_builtin.grep_string, { desc = 'Search Current Word In Files' })
vim.keymap.set('n', '<leader>sR', telescope_builtin.resume, { desc = 'Resume Previous Search' })
vim.keymap.set('n', '<leader>ss', telescope_builtin.lsp_dynamic_workspace_symbols, { desc = 'Search Workspace Symbols' })
vim.keymap.set('n', '<leader>sd', telescope_builtin.lsp_document_symbols, { desc = 'Search Document Symbols' })

vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go To Definition (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Show Symbol Info (LSP)", noremap = true, silent = true })

vim.keymap.set("n", "<leader>ld", function() vim.lsp.buf.definition() end, { desc = "Go To Definition (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>lt", function() vim.lsp.buf.type_definition() end, { desc = "Go To Type Definition (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>li", function() vim.lsp.buf.implementation() end, { desc = "Go To Implementation (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.references() end, { desc = "Find References (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ln", function() vim.lsp.buf.rename() end, { desc = "Find References (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ls", function() vim.lsp.buf.hover() end, { desc = "Show Symbol Info (LSP)", noremap = true, silent = true })
vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format() end, { desc = "Format (LSP)", noremap = true, silent = true })

vim.keymap.set("n", "<leader>ch", ":LspClangdSwitchSourceHeader<CR>", { desc = "Switch To Header/Source File", noremap = true, silent = true })
--:

--: nvim-lspconfig
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig.git" },
})
vim.lsp.config.clangd = {
  cmd = {
    'clangd',
    --'--clang-tidy',
    '--header-insertion=never',
    '--background-index',
  },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
}
vim.lsp.enable({"clangd", "pyright"})
--:

--: tiny-inline-diagnostic
vim.pack.add({
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
})
local diag = require("tiny-inline-diagnostic")
diag.setup()
--:

--: outline
vim.pack.add({
	{ src = "https://github.com/hedyhli/outline.nvim" },
})
local outline = require("outline")
outline.setup({})
vim.keymap.set("n", "<leader>lo", "<cmd>Outline<CR>", { desc = "Symbol Outline" })
--:

--: nvim-dap
vim.pack.add({
    { src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
})
local dap = require("dap")
dap.defaults.fallback.auto_continue_if_many_stopped = false
dap.defaults.fallback.exception_breakpoints = {}

dap.adapters.gdb = {
    id = 'gdb',
    type = 'executable',
    command = 'gdb',
    args = { '--quiet', '--interpreter=dap' },
}

dap.configurations.cpp = {
    {
        name = 'Run executable (GDB)',
        type = 'gdb',
        request = 'launch',
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
            local path = vim.fn.input({
                prompt = 'Path to executable: ',
                default = vim.fn.getcwd() .. '/',
                completion = 'file',
            })

            return (path and path ~= '') and path or dap.ABORT
        end,
    },
    {
        name = 'Run executable with arguments (GDB)',
        type = 'gdb',
        request = 'launch',
        -- This requires special handling of 'run_last', see
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        program = function()
            local path = vim.fn.input({
                prompt = 'Path to executable: ',
                default = vim.fn.getcwd() .. '/',
                completion = 'file',
            })

            return (path and path ~= '') and path or dap.ABORT
        end,
        args = function()
            local args_str = vim.fn.input({
                prompt = 'Arguments: ',
            })
            return vim.split(args_str, ' +')
        end,
    },
    {
        name = 'Attach to process (GDB)',
        type = 'gdb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
    },
}

vim.keymap.set('n', '<F12>', function() require('dap').continue() end, { desc = "Continue or Start Debugging" })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = "Step Over" })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = "Step Into" })
vim.keymap.set('n', '<F23>', function() require('dap').step_out() end, { desc = "Step Out" })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set('n', '<leader>dt', function() require('dap').disconnect() end, { desc = "Terminate Debug Session" })
vim.keymap.set('n', '<leader>dk', function() require('dap').up() end, { desc = "Move Up Callstack" })
vim.keymap.set('n', '<leader>dj', function() require('dap').down() end, { desc = "Move Down Callstack" })

--vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end, { desc = "Debugger REPL" })
--vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
--vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
--vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end, { desc = "Debugger Run Last" })
--vim.keymap.set({'n', 'v'}, '<Leader>dh', function() require('dap.ui.widgets').hover() end, { desc = "Debugger Widgets Hover" })
--vim.keymap.set({'n', 'v'}, '<Leader>dp', function() require('dap.ui.widgets').preview() end, { desc = "Debugger Widgets Preview" })
--vim.keymap.set('n', '<Leader>df', function() local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.frames) end, { desc = "Debugger Widgets Frames" })
--vim.keymap.set('n', '<Leader>ds', function() local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.scopes) end, { desc = "Debugger Widgets Scopes" })
--
require("dapui").setup()
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = "Toggle Debugger UI" })

--:

--: CopilotChat
vim.pack.add({
    { src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim" },
})
vim.keymap.set('n', '<leader>aa', function() require("CopilotChat").open() end, { desc = 'Copilot Chat' })
vim.keymap.set('v', '<leader>aa', function() require("CopilotChat").open() end, { desc = "Copilot Chat (With Selection)" })
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'copilot-*',
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.conceallevel = 0
  end,
})
--:

vim.keymap.set('n', '<leader>ar', ":vsplit|term artifice --full<CR>", { desc = 'Artifice' })

--: diffview
vim.pack.add({
	{ src = "https://github.com/sindrets/diffview.nvim" },
})
--:

--: loghighlight
vim.pack.add({
	{ src = "https://github.com/fei6409/log-highlight.nvim" },
})
require('log-highlight').setup {
	extension = 'log',
	filename = {
		'messages',
	},
	pattern = {
		'/var/log/.*',
		'messages%..*',
	}
}
--:

--: lazygit
vim.pack.add({
	{ src = "https://github.com/kdheepak/lazygit.nvim" },
})
vim.keymap.set('n', '<leader>gg', ":LazyGit<CR>", { desc = 'LazyGit' })
vim.keymap.set('n', '<leader>gf', ":LazyGitFilterCurrentFile<CR>", { desc = 'LazyGit Current File' })
vim.keymap.set('n', '<leader>gl', ":LazyGitLog<CR>", { desc = 'LazyGit Log' })
vim.keymap.set('n', '<leader>gb', ":Git blame<CR>", { desc = 'Git Blame Current File' })
vim.keymap.set('n', '<leader>gd', ":Gdiffsplit<CR>", { desc = 'Git Diff Current File' })
--:

--: lualine
vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
})
require('lualine').setup { extensions = { "quickfix", "fugitive", "nvim-tree", "nvim-dap-ui" } }
--:

--: vim-fugitive (git)
vim.pack.add({
	{ src = "https://github.com/tpope/vim-fugitive" },
})
--:

--: spectre (search and replace)
vim.pack.add({
	{ src = "https://github.com/nvim-pack/nvim-spectre" },
})
vim.keymap.set('n', '<leader>sr', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})
--:

--: render-markdown
vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})
--:

local function find_code_section(bufnr, cursor_row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local start, finish, lang
  for i = cursor_row, 1, -1 do
    local s = lines[i]
    local m = s:match("^```(%w+)")
    if m then
      start = i
      lang = m
      break
    end
  end
  if not start then
    return
  end
  for i = cursor_row + 1, #lines do
    if lines[i]:match("^```") then
      finish = i
      break
    end
  end
  if not finish then
    return
  end
  return lang, start, finish
end

local function execute_code_section(interactive, shell)
  local bufnr = vim.api.nvim_get_current_buf()
  local mode = vim.fn.mode()
  local code, lang

  if mode == "v" or mode == "V" or mode == "\22" then -- visual, linewise visual, blockwise visual
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    code = vim.fn.getline(start_line, end_line)
    lang, _, _ = find_code_section(bufnr, start_line)
    vim.notify(table.concat(code, " + "))
  else
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1
    lang, start, finish = find_code_section(bufnr, row)
    if not lang then
      vim.notify("No code section found", vim.log.levels.ERROR)
      return
    end
    code = vim.api.nvim_buf_get_lines(bufnr, start, finish - 1, false)
  end

  if shell then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
        local chan_id = vim.b[bufnr].terminal_job_id
        if chan_id then
          for _, line in ipairs(code) do
            vim.fn.chansend(chan_id, line .. "\n")
          end
          break
        end
      end
    end
  else
    local cmd
    if lang == "sh" or lang == "bash" or lang == "shell" then
      cmd = "sh"
    elseif lang == "py" or lang == "python" or lang == "python3" then
      cmd = "python3"
    elseif lang == "lua" then
      local code_str = table.concat(code, "\n")
      local f, err = loadstring(code_str)
      if not f then
        vim.notify("Lua error: " .. err, vim.log.levels.ERROR)
        return
      end
      local ok, result = pcall(f)
      if not ok then
        vim.notify("Lua error: " .. result, vim.log.levels.ERROR)
      end
      return
    elseif lang == "vim" then
      for _, line in ipairs(code) do
        vim.cmd(line)
      end
      return
    else
      vim.notify("Unsupported code type: " .. lang, vim.log.levels.ERROR)
      return
    end
    local tmpfile = vim.fn.tempname() .. "." .. lang
    vim.fn.writefile(code, tmpfile)
    if interactive then
      vim.cmd("split | terminal " .. cmd .. " " .. tmpfile)
    else
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.7),
        height = math.floor(vim.o.lines * 0.6),
        row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.7)) / 2),
        style = "minimal",
        border = "rounded",
      })
      vim.fn.termopen(cmd .. " " .. tmpfile, {
        on_exit = function()
          vim.api.nvim_win_close(win, true)
          vim.api.nvim_buf_delete(buf, { force = true })
        end,
      })
      vim.cmd("startinsert")
    end
  end
end

vim.keymap.set({ "n", "v" }, "<leader>xc", function()
  execute_code_section(false)
end, { desc = "Execute code in current section (transient)" })

vim.keymap.set({ "n", "v" }, "<leader>xC", function()
  execute_code_section(true)
end, { desc = "Execute code in current section (persistent)" })

vim.keymap.set({ "n", "v" }, "<leader>xs", function()
  execute_code_section(false, true)
end, { desc = "Execute code in current section in terminal" })

function CopyBufferPathsAsCopilotPrompt()
  local lines = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.fn.filereadable(name) == 1 then
        local relpath = vim.fn.fnamemodify(name, ":.")
        table.insert(lines, "#file:./" .. relpath)
      end
    end
  end
  local result = table.concat(lines, "\n")
  vim.fn.setreg("+", result)
  vim.notify("Copied " .. #lines .. " buffer path(s) to clipboard", vim.log.levels.INFO)
  return result
end

vim.keymap.set("n", "<leader>cb", CopyBufferPathsAsCopilotPrompt, { desc = "Copy buffer paths as Copilot prompt" })

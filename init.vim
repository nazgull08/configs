" Менеджер плагинов
call plug#begin('~/.config/nvim/plugged')

" Темы
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
Plug 'tanvirtin/monokai.nvim'


" Rust support
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'        " Autодополнение
Plug 'hrsh7th/cmp-nvim-lsp'    " Источник LSP для автодополнения
Plug 'simrat39/rust-tools.nvim' " Инструменты для Rust
Plug 'nvim-lua/plenary.nvim'   " Вспомогательные библиотеки

" Навигация и автодополнение
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'         " Snippets


Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'kyazdani42/nvim-tree.lua'
Plug 'lewis6991/gitsigns.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'nvim-tree/nvim-tree.lua'

" Улучшенная подсветка
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

" Включаем тему spaceduck 
syntax enable
" colorscheme monokai
colorscheme spaceduck 

" Общие настройки
set number              " Нумерация строк
set tabstop=2 shiftwidth=2 expandtab
set wrap                " Автоматический перенос строк
set signcolumn=yes      " Колонка для диагностики
set clipboard=unnamedplus  " Копирование в системный буфер обмена

" Поддержка LSP и Rust с инлайн подсказками типов
lua << EOF
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local opts = { noremap=true, silent=true }

      -- Навигация
      buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      vim.api.nvim_set_keymap('n', 'gD', '<Cmd>tab split | lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'gt', ':tabnext<CR>', { noremap = true, silent = true })  -- Следующий таб
      vim.api.nvim_set_keymap('n', 'gT', ':tabprevious<CR>', { noremap = true, silent = true })  -- Предыдущий таб

      -- Включение инлайн подсказок типов
      rt.inlay_hints.enable()
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",  -- Включаем проверку с помощью Clippy
        },
      },
    },
  },
})

-- Настройка автодополнения
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),  -- режим вставки и выборки фрагментов
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Подтверждение выбора
    ['<C-Space>'] = cmp.mapping.complete(),  -- Вызов автодополнения вручную
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }
})
EOF

" Настройки Treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  },
  ensure_installed = { "rust" }
}
EOF


lua << EOF
-- Настройка nvim-tree
require("nvim-tree").setup({
  renderer = {
    icons = {
      glyphs = {
        folder = {
          arrow_closed = ">",   -- закрытая папка
          arrow_open = "v",     -- открытая папка
          default = "+",        -- папка
          open = "-",           -- открытая папка
        },
      },
    },
  },
})

-- Маппинг для открытия/закрытия дерева на <F6>
vim.api.nvim_set_keymap('n', '<F6>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
EOF


lua << EOF
local telescope = require('telescope')

telescope.setup{
  defaults = {
    mappings = {
      i = {
        ["<C-n>"] = "move_selection_next",
        ["<C-p>"] = "move_selection_previous",
        ["<C-c>"] = "close",
      },
    },
    file_ignore_patterns = {"node_modules"},  -- Пример игнорирования директорий
    sorting_strategy = "ascending",
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- Включение нечёткого поиска
      override_generic_sorter = true,  -- Использование FZF для общего поиска
      override_file_sorter = true,     -- Использование FZF для поиска файлов
      case_mode = "smart_case",        -- "smart_case" для умного поиска
    }
  }
}

-- Подключаем расширение fzf
require('telescope').load_extension('fzf')

-- Клавиши для быстрого поиска
vim.api.nvim_set_keymap('n', '<C-F>', "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-G>', "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-H>', "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-T>', "<cmd>Telescope diagnostics<cr>", { noremap = true, silent = true })

EOF



lua << EOF
require('gitsigns').setup{
  signs = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Маппинг для навигации по изменениям
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Маппинг для действий с Git hunks
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
  end
}

-- Добавление подсветки для Git
vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'DiffAdd' })
vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'DiffChange' })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'DiffDelete' })
EOF



lua << EOF
require('lualine').setup{
  options = { theme = 'dracula' },
  sections = {
    lualine_c = {'filename', 'lsp_progress'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}
EOF



nnoremap <C-Left>  <C-w>h   " Влево
nnoremap <C-Down>  <C-w>j   " Вниз
nnoremap <C-Up>    <C-w>k   " Вверх
nnoremap <C-Right> <C-w>l   " Вправо



" Перемещение к следующей диагностике (ошибке или предупреждению)
nnoremap <silent> ]d <cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>
nnoremap <silent> [d <cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>

" Перемещение по всем диагностическим сообщениям
nnoremap <silent> ]w <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> [w <cmd>lua vim.diagnostic.goto_prev()<CR>

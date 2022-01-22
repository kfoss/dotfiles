
""" LAST_UPDATED_AT '2021-03-15'
"""BEGIN_ADD_VIMRC

" Enable vundle
filetype off
set rtp+=~/.vim/bundle/vundle.vim/
call vundle#rc()

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ";"
let g:mapleader = ";"
nmap <leader>w :w<CR>
nmap <leader>q :wq<CR>

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" YouCompleteMe
Plugin 'Valloric/YouCompleteMe'

" NERDTree
Plugin 'scrooloose/nerdtree'

" Enable vim focus events.
Plugin 'tmux-plugins/vim-tmux-focus-events'

" Enable Fugitive.
Plugin 'tpope/vim-fugitive'
" Conflict Resolution
nnoremap gdl :diffget 2<CR>
nnoremap gdr :diffget 3<CR>

" Enable Splice.
Plugin 'sjl/splice.vim'

" Enable fzf.
Plugin 'junegunn/fzf.vim'
set rtp+=~/.fzf
nmap <Leader>b :Buffers<CR>
nmap <Leader>f :Files<CR>
nmap <Leader>t :Tags<CR>
nmap <Leader>l :Lines<CR>

" Typescript formatter.
Plugin 'leafgarland/typescript-vim'

" Enable ag.
Plugin 'mileszs/ack.vim'
let g:ackprg = 'ag --nogroup --nocolor --column'

" Enable GitGutter.
Plugin 'airblade/vim-gitgutter'
let g:gitgutter_sign_removed = '-'
hi GitGutterAdd ctermfg=154 gui=bold
hi GitGutterChange ctermfg=14 gui=bold
hi GitGutterDelete ctermfg=162 gui=bold
hi GitGutterChangeDelete ctermfg=13 gui=bold

" Add Commentary.
Plugin 'tpope/vim-commentary'
autocmd FileType cpp setlocal commentstring=//\ %s

" Add Endwise.
Plugin 'tpope/vim-endwise'

" Add Lightline.
Plugin 'itchyny/lightline.vim'
set laststatus=2
set showtabline=0
set noshowmode
set cmdheight=1
let g:lightline = {
\ 'active': {
\   'left': [['mode', 'paste'], ['shortabsolutepath', 'modified']],
\   'right': [['lineinfo'], ['percent'], ['readonly', 'linter_warnings', 'linter_errors', 'linter_ok']]
\ },
\ 'component_expand': {
\   'linter_warnings': 'LightlineLinterWarnings',
\   'linter_errors': 'LightlineLinterErrors',
\   'linter_ok': 'LightlineLinterOK'
\ },
\ 'component_type': {
\   'readonly': 'error',
\   'linter_warnings': 'warning',
\   'linter_errors': 'error'
\ },
\ 'component': {
\   'lineinfo': '%3l: %-2v',
\ },
\ 'colorscheme': 'seoul256',
\ }
"\   'shortabsolutepath': '%{CondensedAbsolutePath()}',

let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.normal.left = [ ['#000000', '#000000', 15, 14 ], [ '#000000', '#000000', 10, 'NONE' ] ]
let s:palette.normal.right = [ ['#000000', '#000000', 'NONE', 13, 'bold' ], [ '#000000', '#000000', 13, 'NONE' ] ]
let s:palette.inactive.middle = s:palette.normal.middle
let s:palette.tabline.middle = s:palette.normal.middle
let s:palette.visual.middle = [ [ '#000000', '#000000', 13, 13, 'bold' ] ]
let s:palette.insert.middle = [ [ '#000000', '#000000', 11, 11, 'bold' ] ]

function! LightlineLinterWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '' : printf('%d ▲', all_non_errors)
endfunction

function! LightlineLinterErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '' : printf('%d ✗', all_errors)
endfunction

function! LightlineLinterOK() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:counts.total == 0 ? '✓' : ''
endfunction

autocmd User ALELint call s:MaybeUpdateLightline()
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()

" Update and show lightline but only if it's visible (e.g., not in Goyo)
function! s:MaybeUpdateLightline()
  if exists('#lightline')
    call lightline#update()
  end
endfunction

" vim-tmux-navigator
Plugin 'christoomey/vim-tmux-navigator'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Format the status line
set statusline=\ \ %F%m%r%h\ %w\ %{HasPaste()}%=Col\ %c,\ Line\ %l/%L\ (%P)

" Configure settings
:set pastetoggle=<F10>
:set number
:set tabstop=2 shiftwidth=2 expandtab
:set autoindent
:set timeoutlen=1000 ttimeoutlen=10

" Set custom colors
" C++ syntax highlighting
hi Delimiter ctermfg=5 ctermbg=NONE gui=NONE cterm=NONE term=NONE
hi cppPointer term=underline ctermfg=4 gui=bold
" Youcompleteme menu
hi Pmenu ctermfg=15 ctermbg=6 guifg=#000000 guibg=#00ffff
hi PmenuSel ctermfg=16 ctermbg=15 guifg=#ffffff guibg=#000080 gui=bold
" Vim line numbers
hi LineNr ctermfg=242

" Use code formatters with Ctrl+K and when saving files
:function FormatFile()
:  let l:lines="all"
:  if (&ft == 'python')
:    :echo "Formatting Python..."
:    :FormatCode
:  else
:    :echo "Formatting C++..."
:    py3f /usr/lib/clang-format/clang-format.py
:  endif
:endfunction
noremap <C-P> :call FormatFile()<CR>
inoremap <C-P> <C-O> :call FormatFile()<CR>
autocmd BufWritePre *.cc,*.cpp,*.h,*.py :call FormatFile()

" Enable NERDTree
map <C-n> :NERDTreeToggle<CR>

" Auto strip whitespace when saving files
autocmd BufWritePre * %s/\s\+$//e

" Switch CWD to the directory of the open buffer
map <leader>cd. :cd %:p:h<cr>:pwd<cr>

" Set paste and nopaste
map <leader>sp :set paste<CR>
map <leader>snp :set nopaste<CR>

" Set number and nonumber
map <leader>sn :set number<CR>
map <leader>snn :set nonumber<CR>

" Disable scratch preview window.
set completeopt-=preview

" Use system clipboard
set clipboard=unnamedplus

" Update files as they are written.
" set autoread
" Trigger 'autoread' when files changed on disk.
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" Notification after file change.
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" Select entire function.
:function SelectFunction()
:  execute "normal! ^{jv/{\<CR>%\<CR>"
:endfunction
map vif :call SelectFunction()<cr>

" Bring comment below up to current line.
:function MoveBelowCommentUp()
:  execute "normal! A \<DEL>\<ESC>dwxx"
:endfunction
nnoremap cu :call MoveBelowCommentUp()<cr>
nnoremap <leader>c :call MoveBelowCommentUp()<cr>

"Bring below line up and aligned with the current line.
:function MoveBelowLineUp()
:  execute "normal! A \<DEL>\<ESC> dw"
:endfunction
nnoremap du :call MoveBelowLineUp()<cr>

" Alias buffer close.
:command BCLOSE Bclose

"""END_ADD_VIMRC

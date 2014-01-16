" Vim Run Command File
"
" File: ~/.vimrc
" Author: Yecheng Fu <cofyc.jackson@gmail.com>

set nocompatible
set backspace=indent,eol,start

" File Format
set fileformats=unix,dos,mac " file formats to try when opening file

" File Encoding
set encoding=utf-8  " internal encoding
set fileencodings=utf-8,gb18030 " file encodings to try when opening file

" History Line
set history=1000

" Filetype
filetype on
filetype plugin on
filetype indent on

" Set mapleader
let mapleader = ","

" Fast Reloading RC File
map <leader>s :source ~/.vimrc<CR>

" Fast Editing RC File
map <leader>e :sp ~/.vimrc<CR>

" Syntax Highlight
syntax on

" Color
colorscheme zellner

set autoread
set so=7
set wildmenu
set ruler
set cmdheight=1
set nu
set lz
set hid
set incsearch
set magic
set noerrorbells
set novisualbell
set showmatch
set mat=2
set hlsearch
set laststatus=2
set statusline=%F%m%r%h%w%y[%{&fileencoding}][%{&ff}]\ \ Line:\ %l/%L\ \ Col:\ %c\ \ Cwd:\ %{getcwd()}
set nobackup
set nowb
set noswapfile
set nofen
set fdl=0

" Tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab

" Indent
set autoindent
set smartindent
set cindent
set cino=:0

" Abbreviations
iab xdate <C-R>=strftime("Date: %a %b %d %H:%M:%S %Y %z")<CR>
iab xdate1 <C-R>=strftime("%d %b %Y")<CR>
iab xauthor Author: Yecheng Fu <cofyc.jackson@gmail.com>
iab xcpyr Copyright (C) Yecheng Fu <cofyc.jackson at gmail dot com>
iab xnick Cofyc
iab xname Yecheng
iab xfname Yecheng Fu
iab xmail cofyc.jackson@gmail.com

" Tab Page Shortcuts
map <F2>    :tabprevious<CR>
map <F3>    :tabnext<CR>
map <F4>    :tabnew .<CR>
map <F5>    :tabclose<CR>

" Ctags
map <F6> :TlistToggle<CR>
map <F7> :TlistUpdate<CR>

" Exchange Words Separated By '[, ]'
map <leader>x :s/\v([^, (){}\[\]]*)([, ]\s*)([^, (){}\[\]]*)/\3\2\1/<CR> :nohlsearch<CR>

" Remove Trailing Spaces
function! RemoveTrailingSpaces()
    silent! %s/\v\s+$//
    ''
    echo "Trailing spaces removed."
endfunction
map <leader>r :call RemoveTrailingSpaces()<CR>

" Insert Line Number
map <leader>l :g/^/ s//\=line('.').' '/<CR>

" Title Case
" change capital letters to uppercase
map <leader>u :s/\<\(\w\)\(\w*\)\>/\u\1\2/g<CR> :nohlsearch<CR>
" strict version (addtion to previous, change letters follows capital to lowercase)
map <leader>U :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR> :nohlsearch<CR>

" Cmd: XmlFmt
command! XmlFmt set ft=xml | execute "%!xmllint --format -"

" Cmd: HtmlFmt
command! HtmlFmt set ft=html | execute "%!tidy -q -i -asxhtml 2>/dev/null"

" Windows
set wmh=0

" Plugins
runtime! ftplugin/man.vim

" Plugins: Taglist
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Exit_OnlyWindow = 1

" Plugins: gitcommit
autocmd FileType gitcommit DiffGitCached | wincmd r | wincmd =
au BufRead,BufNewFile *.vcl :set ft=vcl

" Macros
" @link http://vim.wikia.com/wiki/Macros
:nnoremap <Space> @q

" Improved hex editing: http://vim.wikia.com/wiki/Improved_Hex_editing
nnoremap <C-H> :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

command -bar Hexmode call ToggleHex()
function! ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1

    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin
        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        let &ft="xxd"
        " set status
        let b:editHex=1
        " switch to hex editor
        %!xxd
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
          setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction

" autocmds to automatically enter hex mode and handle file writes properly
if has("autocmd")
  " vim -b : edit binary using xxd-format!
  augroup Binary
    au!

    " set binary option for all binary files before reading them
    au BufReadPre *.bin,*.hex setlocal binary

    " if on a fresh read the buffer variable is already set, it's wrong
    au BufReadPost *
          \ if exists('b:editHex') && b:editHex |
          \   let b:editHex = 0 |
          \ endif

    " convert to hex on startup for binary files automatically
    au BufReadPost *
          \ if &binary | :silent Hexmode | endif

    " When the text is freed, the next time the buffer is made active it will
    " re-read the text and thus not match the correct mode, we will need to
    " convert it again if the buffer is again loaded.
    au BufUnload *
          \ if getbufvar(expand("<afile>"), 'editHex') == 1 |
          \   call setbufvar(expand("<afile>"), 'editHex', 0) |
          \ endif

    " before writing a file when editing in hex mode, convert back to non-hex
    au BufWritePre *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd -r" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif

    " after writing a binary file, if we're in hex mode, restore hex mode
    au BufWritePost *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd" |
          \  exe "set nomod" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif
  augroup END
endif

" http://vim.wikia.com/wiki/Opening_multiple_files_from_a_single_command-line
function! Sp(dir, ...)
    let split = 'sp'
    if a:dir == '1'
        let split = 'vsp'
    endif
    if(a:0 == 0)
        execute split
    else
        let i = a:0
        while(i > 0)
            execute 'let files = glob (a:' . i . ')'
            for f in split (files, "\n")
                execute split . ' ' . f
            endfor
            let i = i - 1
        endwhile
        windo if expand('%') == '' | q | endif
endif
endfunction
com! -nargs=* -complete=file Sp call Sp(0, <f-args>)
com! -nargs=* -complete=file Vsp call Sp(1, <f-args>)

" http://stackoverflow.com/questions/290465/vim-how-to-paste-over-without-overwriting-register
" I haven't found how to hide this function (yet)
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction

function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction

" NB: this supports "rp that replaces the selection by the contents of @r
vnoremap <silent> <expr> p <sid>Repl()

"
au BufRead,BufNewFile *.pl :set tw=79
au BufRead,BufNewFile *.c :set tw=79
au BufRead,BufNewFile *.erl :set tw=79

" Redefine iskeyword, (Perl6 use dash)
au BufRead,BufNewFile *.pl :set iskeyword=@,48-57,_,192-255,#,-

" TagBar
nnoremap <silent> <F9> :TagbarToggle<CR>
let g:tagbar_left = 1
let g:tagbar_sort = 0

" Pathogen, install plugins/scripts in private directories.
call pathogen#infect()

" No end of line on last line
"au BufWritePre * :set binary | set noeol
"au BufWritePost * :set nobinary | set eol

" Create parent directories on save.
" http://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" indent guides
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=7

" go
au BufRead,BufNewFile *.go set noexpandtab
au FileType go au BufWritePre <buffer> Fmt
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }

" align
" align on first separator only
map <leader>tf= :Align! lp1P1: =<CR>
map <leader>tf=> :Align! lp1P1: =><CR>
map <leader>tf: :Align! lp1P1: :<CR>

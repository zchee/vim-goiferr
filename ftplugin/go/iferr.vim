" goiferr.vim: Vim command to automatically inserts idiomatic
" error handling to given Go source code.
"
" This filetype plugin add a new commands for go buffers:
"
"   :GoIfferr
"
"       automatically inserts idiomatic error handling
"       to given Go source code.
"
" Options:
"
"   g:goiferr_command [default="goiferr"]
"
"       Flag naming the goiferr executable to use.
"
if exists("b:did_ftplugin_go_iferr")
    finish
endif

if !exists("g:go_iferr_command")
    let g:go_iferr_command = "goiferr"
endif

function! s:GoIferr()
    let view = winsaveview()
    silent execute "%!" . g:go_iferr_command . " -w " . expand("%:p") . "> /dev/null"
    silent e! %
endfunction

command! -buffer GoIferr call s:GoIferr()

let b:did_ftplugin_go_iferr = 1

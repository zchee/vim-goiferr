" goiferr.vim: Vim command to automatically inserts idiomatic
" error handling to given Go source code.
"
" This filetype plugin add a new commands for go buffers:
"
"   :GoIferr
"
"       Automatically inserts idiomatic error handling
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

" Check goiferr binary
function! s:check_bin(binpath)
  let binpath = substitute(a:binpath, '^\s*\(.\{-}\)\s*$', '\1', '')

  if !executable(binpath)
    echo "vim-goiferr: could not find" . binpath
    return
  endif

  return a:binpath
endfunction

" Check vimproc use vim-go environment
function! s:has_vimproc()
  if !exists('g:go#use_vimproc')
    if go#util#IsWin()
        try
            call vimproc#version()
            let exists_vimproc = 1
        catch
            let exists_vimproc = 0
        endtry
    else
        let exists_vimproc = 0
    endif

    let g:go#use_vimproc = exists_vimproc
  endif

  return g:go#use_vimproc
endfunction

" vim syscall
function! s:vim_system(str, ...)
  if s:has_vimproc()
    let s:vim_system = 'vimproc#system2'
  else
    let s:vim_system = 'system'
  endif

  return call(s:vim_system, [a:str] + a:000)
endfunction

" Main function
function! s:GoIferr()
  " Check exists goiferr binary
  call s:check_bin(g:go_iferr_command)

  " Save cursor position and other...
  let l:curw = winsaveview()

  " Write current unsaved buffer to a temp file(filename is '_' + current file name)
  " goiferr must exists in file is the $GOPATH
  let l:tmpname = expand('%:p:h') . "_" . expand('%:t')
  call writefile(getline(1, '$'), l:tmpname)

  " Execute goiferr use vimproc or vim system
  call s:vim_system(g:go_iferr_command . " -w " . l:tmpname)

  " Get current fileformat
  let old_fileformat = &fileformat

  " Replace the current buffer to tempfile
  call rename(l:tmpname, expand('%'))
  silent edit!

  " Restore the fileformat
  let &fileformat = old_fileformat

  " Delete temp file
  call delete(l:tmpname)

  " Restore cursor position and other...
  call winrestview(l:curw)
endfunction

command! -buffer GoIferr call s:GoIferr()

let b:did_ftplugin_go_iferr = 1

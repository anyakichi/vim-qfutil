" Quickfix utility
" Maintainer: INAJIMA Daisuke <inajima@sopht.jp>
" Version: 0.2
" License: MIT License

if exists("g:loaded_qfutil")
    finish
endif
let g:loaded_qfutil = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:qfutil_default_grep_file')
    let g:qfutil_default_grep_file = '**'
endif

command! -nargs=* QFCscope :call qfutil#tcscope(<f-args>)
command! -nargs=* QFMake :call qfutil#tmake(<f-args>)
command! -nargs=* -complete=file QFGrep :call qfutil#tgrep(<f-args>)

let &cpo = s:cpo_save

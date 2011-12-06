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

command! -nargs=* QFMake :call qfutil#tmake(<q-args>)
command! -nargs=* -complete=file QFGrep :call qfutil#tgrep(<q-args>)

let &cpo = s:cpo_save

" Quickfix utility
" Maintainer: INAJIMA Daisuke <inajima@sopht.jp>
" License: MIT License

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:qfutil_mode')
    let g:qfutil_mode = 'l'
endif

function! qfutil#mode()
    return g:qfutil_mode
endfunction

function! qfutil#_mode()
    return g:qfutil_mode == 'c' ? '' : g:qfutil_mode
endfunction

function! qfutil#quickfix()
    let g:qfutil_mode = 'c'
    echo 'quickfix'
endfunction

function! qfutil#loclist()
    let g:qfutil_mode = 'l'
    echo 'location list'
endfunction

function! qfutil#toggle()
    if g:qfutil_mode ==# 'l'
	call qfutil#quickfix()
    else
	call qfutil#loclist()
    endif
endfunction

function! s:execute(...)
    let cmd = join(a:000, ' ')
    try
	execute cmd
    catch
	echohl ErrorMsg
	echo substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl None
    endtry
endfunction

function! s:execute_with_arg(cmd, arg)
    let cmd = qfutil#mode() . a:cmd
    if a:arg == ''
	call s:execute(cmd)
    else
	call s:execute(cmd, a:arg)
    endif
endfunction

function! s:execute_with_nr(cmd, nr)
    let cmd = qfutil#mode() . a:cmd
    if a:nr == 0
	call s:execute(cmd)
    else
	call s:execute(cmd, a:nr)
    endif
endfunction

function! s:execute_with_count(cmd, count)
    let cmd = qfutil#mode() . a:cmd
    if a:count == 0
	call s:execute(cmd)
    else
	call s:execute(a:count . cmd)
    endif
endfunction

function! qfutil#qq(nr)
    call s:execute_with_nr(qfutil#mode(), a:nr)
endfunction

function! qfutil#next(count)
    call s:execute_with_count('next', a:count)
endfunction

function! qfutil#previous(count)
    call s:execute_with_count('previous', a:count)
endfunction

function! qfutil#nfile(count)
    call s:execute_with_count('nfile', a:count)
endfunction

function! qfutil#pfile(count)
    call s:execute_with_count('pfile', a:count)
endfunction

function! qfutil#first(nr)
    call s:execute_with_nr('first', a:nr)
endfunction

function! qfutil#last(nr)
    call s:execute_with_nr('last', a:nr)
endfunction

function! qfutil#file(...)
    call s:execute_with_arg('file', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#getfile(...)
    call s:execute_with_arg('getfile', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#addfile(...)
    call s:execute_with_arg('addfile', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#buffer(...)
    call s:execute_with_arg('buffer', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#getbuffer(...)
    call s:execute_with_arg('getbuffer', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#addbuffer(...)
    call s:execute_with_arg('addbuffer', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#list(...)
    call s:execute_with_arg('list', '')
endfunction

function! qfutil#open(...)
    call s:execute_with_arg('open', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#close()
    call s:execute_with_arg('close', '')
endfunction

function! qfutil#window(...)
    call s:execute_with_arg('window', a:0 > 0 ? a:1 : '')
endfunction

function! qfutil#older(count)
    call s:execute_with_nr('older', a:count)
endfunction

function! qfutil#newer(count)
    call s:execute_with_nr('newer', a:count)
endfunction

function! qfutil#make(...)
    let cmd = qfutil#_mode() . 'make'
    if a:0 == 0
	return ":\<C-u>" . cmd . "\<CR>"
    else
	return ":\<C-u>" . cmd . ' ' . join(a:000, ' ')
    endif
endfunction

function! qfutil#grep(...)
    let cmd = qfutil#_mode() . 'grep'
    if a:0 == 0
	return ":\<C-u>" . cmd . "\<CR>"
    else
	return ":\<C-u>" . cmd . ' ' . join(a:000, ' ')
    endif
endfunction

function! qfutil#toggle_window()
    for bufnr in range(1, winnr('$'))
	if getwinvar(bufnr, '&buftype') ==# 'quickfix'
	    call s:execute_with_arg('close', '')
	    return
	endif
    endfor
    call s:execute_with_arg('window', '')
endfunction

function! qfutil#ltag()
    let word = expand('<cword>')
    if word == ''
	echohl ErrorMsg
	echo 'E349: No identifier under cursor'
	echohl None
	return
    endif
    call s:execute('ltag', word)
    lwindow
endfunction

function! s:tquickfix(cmd, args)
    let cmd = qfutil#_mode() . a:cmd
    let tabnr = tabpagenr()

    tab split

    execute cmd join(a:args, ' ')

    for bufnr in range(1, winnr('$'))
	if getwinvar(bufnr, '&buftype') ==# 'quickfix'
	    return
	endif
    endfor

    tabclose
    execute 'tabnext' tabnr
endfunction

function! qfutil#tmake(...)
    call s:tquickfix('make', a:000)
endfunction

function! qfutil#tgrep(...)
    let args = copy(a:000)
    let dir_count = 0

    if a:0 < 1
	call add(args, expand('<cword>'))
    endif

    if a:0 < 2
	call add(args, expand(g:qfutil_default_grep_file))
    endif

    for i in range(1, len(args) - 1)
	if isdirectory(args[i])
	    let dir_count += 1
	    if &grepprg ==# 'internal'
		let args[i] .= '/**'
	    endif
	endif
    endfor

    if dir_count > 0 && &grepprg !=# 'internal'
	call insert(args, '-r', 1)
    endif

    call s:tquickfix('grep', args)
endfunction

let &cpo = s:save_cpo

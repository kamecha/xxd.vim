
function! xxd#command#call(bang, rargs) abort
	if a:bang ==# '!'
		return xxd#command#call('', '_raw ' . a:rargs)
	endif
	" ↓ここでargsからschemeを取得している
	let scheme = matchstr(a:rargs, '^\w\+')
	return call(
				\ printf('xxd#command#%s#call', scheme),
				\ call(printf('xxd#command#%s#args', scheme), [a:rargs]),
				\)
endfunction

function! xxd#command#complete(arglead, cmdline, cursorpos) abort
	" Xxd!の場合は_rawを補完する
	if a:cmdline =~# '^.\{-}Xxd!'
		return xxd#command#complete(
					\ a:arglead,
					\ substitute(a:cmdline, '^\(.\{-}\)Xxd!', '\1Xxd _raw', ''),
					\ a:cursorpos,
					\)
	endif
	let cmdline = matchstr(a:cmdline, '^.\{-}Xxd\s\+\zs.*')
	let scheme = matchstr(cmdline, '^\w\+')
	return call(
				\ printf('xxd#command#%s#complete', scheme),
				\ [a:arglead, cmdline, a:cursorpos],
				\)
endfunction

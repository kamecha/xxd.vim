
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
	let schemes = glob(expand('<sfile>:p:h') . '/autoload/xxd/command/*.vim', 0, 1)
				\->map({_, v -> matchstr(fnamemodify(v, ':t'), '^\w\+')})
	" schemeが正しい場合
	if schemes->index(scheme) != -1
		return call(
					\ printf('xxd#command#%s#complete', scheme),
					\ [a:arglead, cmdline, a:cursorpos],
					\)
	endif
	return schemes
				\->filter({_, v -> v !~# '^_.*'})
				\->filter({_, v -> v =~# a:arglead})
endfunction


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

function xxd#command#complete(arglead, cmdline, cursorpos) abort
endfunction

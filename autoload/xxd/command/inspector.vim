
function! xxd#command#inspector#call(args) abort
	call xxd#feature#inspector#enable()
	call xxd#feature#inspector#open()
endfunction

" 開く時のオプションとか指定したいかも
function! xxd#command#inspector#complete(arglead, cmdline, cursorpos) abort
endfunction

function! xxd#command#inspector#args(args) abort
	return [ a:args ]
endfunction


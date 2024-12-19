
function! xxd#command#jump#call(args, expr) abort
	let address = eval(a:expr)
	let pos = xxd#core#view#byte#address2pos(win_getid(), address)
	call xxd#core#view#byte#cursor(pos)
endfunction

" {expr}の形式だから補完は今の所無し
" だた:echo の時と同じように関数の補完はしたいかも
function! xxd#command#jump#complete(arglead, cmdline, cursorpos) abort
endfunction

function! xxd#command#jump#args(args) abort
	return [ a:args, a:args->substitute('^jump', '', '') ]
endfunction


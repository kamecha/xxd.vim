" byte_pos is a list of [line, col]
" 0-based

" args: [{lnum}, {col}] ←byte用
" カレントバッファ専用
" argsに対応した箇所へカーソルを移動する
function! xxd#core#view#byte#cursor(args) abort
	" 00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0000  jump.vim........
	let line = getline(a:args[0] + 1)
	let address = line->matchstr('^\d\+:')
	" colまでの空白の個数
	let byteline = line->matchstr('^\d\+:\zs.*')
	let bytespos = byteline->matchend('\(\s*[0-9a-f]\{2}\)\{' . string(a:args[1] + 1) . '}')
	let cursor = [a:args[0] + 1, address->len() + bytespos]
	call cursor(cursor)
endfunction

function! xxd#core#view#byte#getcurpos(winid) abort
	let curpos = getcurpos(a:winid)
	let lnum = curpos[1]
	let col = curpos[2]
	" 000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
	let line = winbufnr(a:winid)->getbufoneline(curpos[1])
	let byteline = line[0:col - 1]->matchstr('^\d\+:\zs.*')
	return [ lnum - 1, byteline->split('[0-9a-f]\{2}\zs')->len() - 1 ]
endfunction

" addressをposに変換する
function! xxd#core#view#byte#address2pos(winid, address) abort
	let pos = [ 0, 0 ]
	let i = 0
	for line in winbufnr(a:winid)->getbufline(1, '$')
		let adr = xxd#util#line2address(line)
		let blob = xxd#util#line2blob(line)
		if a:address >= adr && a:address < adr + blob->len()
			let pos = [ i, a:address - adr ]
			break
		endif
		let i += 1
	endfor
	return pos
endfunction

function! xxd#core#view#byte#pos2address(winid, pos) abort
	let line = winbufnr(a:winid)->getbufline(a:pos[0] + 1)
	let base_address = xxd#util#line2address(line)
	return base_address + a:pos[1]
endfunction


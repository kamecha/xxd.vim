" byte_pos is a list of [line, col]
" 0-based

" args: [{lnum}, {col}] ←byte用
" カレントバッファ専用
" argsに対応した箇所へカーソルを移動する
function! xxd#core#view#byte#cursor(args) abort
	" 00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0000  jump.vim........
	let line = getline(a:args[0] + 1)
	let address = line->matchstr('^[0-9a-fA-F]\+:')
	" colまでの空白の個数
	let byteline = line->matchstr('^[0-9a-fA-F]\+:\zs.*')
	let bytespos = byteline->matchend('\(\s*[0-9a-fA-F]\{2}\)\{' . string(a:args[1] + 1) . '}')
	let cursor = [a:args[0] + 1, address->len() + bytespos - 1]
	call cursor(cursor)
endfunction

" return: [lnum, col]
function! xxd#core#view#byte#getcurpos(winid) abort
	let curpos = getcurpos(a:winid)
	let lnum = curpos[1]
	let col = curpos[2]
	" 000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
	let line = winbufnr(a:winid)->getbufoneline(curpos[1])
	let byteline = line[0:col - 1]->matchstr('^[0-9a-fA-F]\+:\zs.*')
	return [ lnum - 1, byteline->split('[0-9a-fA-F]\{2}\zs')->len() - 1 ]
endfunction

" return: [lnum, col]
function! xxd#core#view#byte#getpos(expr) abort
	if a:expr == '.'
		return xxd#core#view#byte#getcurpos(win_getid())
	endif
	if a:expr == '$'
		let blobs = getline('$')->xxd#util#line2blob()
		return [ line('$') - 1, blobs->len() - 1 ]
	endif
endfunction

" カーソル位置のアドレスを取得する
function! xxd#core#view#byte#getaddress(winid) abort
	let curpos = xxd#core#view#byte#getcurpos(a:winid)
	let address = xxd#core#view#byte#pos2address(a:winid, curpos)
	return address
endfunction

" カーソル位置のバイトを取得する
function! xxd#core#view#byte#getbyte(winid) abort
	let curpos = xxd#core#view#byte#getcurpos(a:winid)
	let line = winbufnr(a:winid)->getbufoneline(curpos[0] + 1)
	let blobs = xxd#util#line2blob(line)
	return blobs[curpos[1]:curpos[1]]
endfunction

" 範囲内のバイトを取得する
" start: [lnum, col]
function! xxd#core#view#byte#getbytes(winid, start, end) abort
	let blobs = 0z
	" start行内
	let line = winbufnr(a:winid)->getbufoneline(a:start[0] + 1)
	if a:end[0] == a:start[0]
		return xxd#util#line2blob(line)[a:start[1]:a:end[1]]
	else
		let blobs += xxd#util#line2blob(line)[a:start[1]:]
	endif
	" 中間行
	for i in range(a:start[0] + 1, a:end[0] - 1)
		let line = winbufnr(a:winid)->getbufoneline(i + 1)
		let blobs += xxd#util#line2blob(line)
	endfor
	" end行内
	let line = winbufnr(a:winid)->getbufoneline(a:end[0] + 1)
	let blobs += xxd#util#line2blob(line)[0:a:end[1]]
	return blobs
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

" byte_posと実際のposの変換
function! xxd#core#view#byte#pos2rel(winid, pos) abort
	let line = winbufnr(a:winid)->getbufoneline(a:pos[0] + 1)
	let address = line->matchstr('^[0-9a-fA-F]\+:')
	" colまでの空白の個数
	let byteline = line->matchstr('^[0-9a-fA-F]\+:\zs.*')
	let bytespos = byteline->matchend('\(\s*[0-9a-fA-F]\{2}\)\{' . string(a:pos[1] + 1) . '}')
	let relpos = [a:pos[0] + 1, address->len() + bytespos - 1]
	return relpos
endfunction

" 1-indexの [lnum, col] をbyteの0-indexのposに変換する
" 00000000: 096c 6574 2072 656c 706f 7320 3d20 5b61  .let relpos = [a
"   ^ ここ[ 1, 3 ] -> [ 0, 0 ]
"           ^ ここ[ 1, 11 ] -> [ 0, 0 ]
"               ^ ここ[ 1, 15 ] -> [ 0, 2 ]
"                                                   ^ ここ[ 1, 17 ] -> [ 0, 3 ]
function xxd#core#view#byte#rel2pos(winid, rel) abort
	let pos = [ a:rel[0] - 1, 0 ]
	let line = winbufnr(a:winid)->getbufoneline(a:rel[0])
	let address = line->matchstr('^[0-9a-fA-F]\+:')
	let byteline = line
				\->matchstr('^[0-9a-fA-F]\+:\zs.*')
				\->matchstr('.*\ze\s\{2}.*$')
	let char = line->matchstr('\s\{2}\zs.*$')
	if a:rel[1] <= address->len()
		" アドレス部分
		let pos[1] = 0
	elseif a:rel[1] > line->len() - char->len()
		" 右側のデコードした文字列部分
		let pos[1] = byteline
					\->substitute('\s', '', 'g')
					\->len()
					\ / 2 - 1
	else
		let byteline = line[ address->len() : a:rel[1] - 1]
					\->substitute('\s', '', 'g')
		" [0-9a-fA-F]\{2}の個数
		if line[a:rel[1] - 1] == ' '
			" byteとの間の空白はその次のbyteのposを表す
			let pos[1] = byteline
						\->len()
						\ / 2
		else
			if byteline->len() % 2 == 0
				" byteの右端の場合
				let pos[1] = byteline->len() / 2 - 1
			else
				" byteの左端の場合
				let pos[1] = byteline->len() / 2
			endif
		endif
	endif
	return pos
endfunction

" posはbyte_pos [ lnum, col ]
" return: match_id
function xxd#core#view#byte#matchaddpos(group, pos) abort
	let list = [ win_getid()->xxd#core#view#byte#pos2rel(a:pos), 2 ]->flatten()
	return matchaddpos(a:group, [ list ])
endfunction

" posはbyte_pos [ lnum, col ]
" return: [ match_id ]
function xxd#core#view#byte#matchaddaddrlen(group, address, length) abort
	let match_id = []
	for l in range(a:length)
		let pos = xxd#core#view#byte#address2pos(win_getid(), a:address + l)
		let match_id += [ xxd#core#view#byte#matchaddpos(a:group, pos) ]
	endfor
	return match_id
endfunction


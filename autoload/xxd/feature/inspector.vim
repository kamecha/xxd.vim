" ↓みたいな変数を順次表示していきたいかも
" [ #{ name: 'hoge', converter: funcref }, ... ]
" funcref: (blob) => string

" inspector表示用バッファを作成
function xxd#feature#inspector#enable() abort
	let bufnr = bufadd('inspector')
	call setbufvar(bufnr, '&buftype', 'nofile')
	call setbufvar(bufnr, '&modifiable', 0)
endfunction

" inspector表示用バッファを削除
function xxd#feature#inspector#disable() abort
	let bufnr = bufnr('inspector')
	bdelete! bufnr
endfunction

" カーソル位置・選択範囲のblobを取得
function xxd#feature#inspector#getblob() abort
	let ret = 0z
	if mode() == 'n'
		let ret = xxd#core#view#byte#getbyte(win_getid())
	endif
	if mode() == 'v'
		let cursor_pos = xxd#core#view#byte#getpos('.')
		let op_pos = xxd#core#view#byte#getpos('v')
		let start = xxd#util#islesspos(cursor_pos, op_pos) ? cursor_pos : op_pos
		let end = xxd#util#islesspos(cursor_pos, op_pos) ? op_pos : cursor_pos
		let ret = xxd#core#view#byte#getbytes(win_getid(), start, end)
	endif
	if mode() == 'V'
		let cursor_pos = xxd#core#view#byte#getpos('.')
		let op_pos = xxd#core#view#byte#getpos('v')
		let start = xxd#util#islesspos(cursor_pos, op_pos) ? cursor_pos : op_pos
		let start = [ start[0], 0 ]
		let end = xxd#util#islesspos(cursor_pos, op_pos) ? op_pos : cursor_pos
		" TODO: ここの右端の取得方法良い感じにする
		let blobs = getline(end[0] + 1)->xxd#util#line2blob()
		let end = [ end[0], blobs->len() - 1 ]
		let ret = xxd#core#view#byte#getbytes(win_getid(), start, end)
	endif
	if mode() == "\<C-V>"
		let cursor_pos = xxd#core#view#byte#getpos('.')
		let op_pos = xxd#core#view#byte#getpos('v')
		let start = xxd#util#islesspos(cursor_pos, op_pos) ? cursor_pos : op_pos
		let end = xxd#util#islesspos(cursor_pos, op_pos) ? op_pos : cursor_pos
		for l in range(start[0], end[0])
			let ret += xxd#core#view#byte#getbytes(
						\win_getid(),
						\[ l, start[1] ],
						\[ l, end[1] ])
		endfor
	endif
	return ret
endfunction

" inspector表示用バッファを更新
function xxd#feature#inspector#draw(blob, inspectors) abort
	if !bufexists('inspector')
		return
	endif
	let bufnr = bufnr('inspector')
	call bufload(bufnr)
	call setbufvar(bufnr, '&modifiable', 1)
	silent call deletebufline(bufnr, 1, '$')
	for ins in a:inspectors
		let inslins = []
		call add(inslins, ins.name)
		call add(inslins, ins.converter(a:blob))
		call appendbufline(bufnr, '$', inslins)
	endfor
	call setbufvar(bufnr, '&modifiable', 0)
endfunction

" split表示だったりpopup表示だったりを担う
function xxd#feature#inspector#open() abort
	if !bufexists('inspector')
		return
	endif
	execute 'sbuffer ' . bufnr('inspector')
endfunction

function xxd#feature#inspector#close() abort
	if !bufexists('inspector')
		return
	endif
	let winid = bufwinnr(bufname('inspector'))
	execute winid . 'close'
endfunction

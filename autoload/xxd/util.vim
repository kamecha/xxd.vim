
" xxdの出力形式の文字列からバイナリデータを取得
" 後半のascii部分は無視
" TODO: ひとまずhex限定
" 0000a0: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
" return: 0z0010.0020.4F00.0000.0000.0000.0000.0000
" 000020: 0010
" return: 0z0010
function! xxd#util#line2blob(line) abort
	" 最初のアドレス部分を削除
	let bytes_str = a:line
				\->matchstr('^\([0-9a-fA-F]\+\):\s\zs.*$')
	" 右端のascii部分を削除
	" ascii部分は空白2つの後ろから始まる
	let bytes_str = bytes_str
				\->substitute('\s\{2}\zs.*$', '', '')
	let bytes_str = bytes_str
				\->trim()
				\->substitute('\s', '', 'g')
	let bytes = 0z
	execute 'let bytes += 0z' . bytes_str
	return bytes
endfunction

" xxdの出力形式の文字列からアドレスを取得
" 0000a0: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
" return: 0x0010
function xxd#util#line2address(line) abort
	" 最初のアドレス部分を取得
	let address_str = a:line
				\->matchstr('^\([0-9a-fA-F]\+\):\s.*$')
	let address = address_str->str2nr(16)
	return address
endfunction

" 0z00.01.02
" return: 0x000102 (big endian)
" return: 0x020100 (little endian)
function xxd#util#blob2hex(blob, endian) abort
	let hexstr = ''
	if a:endian == 'big'
		for b in a:blob
			let hexstr .= printf('%02X', b)
		endfor
	endif
	if a:endian == 'little'
		for b in reverse(a:blob)
			let hexstr .= printf('%02X', b)
		endfor
	endif
	return hexstr->str2nr(16)
endfunction

" "0z00.01.02"
" return: 0z00.01.02
" str2nr()みたいな挙動を目指す
function xxd#util#str2blob(str) abort
	let blob = 0z
	let blob_str = a:str
				\->substitute('^0z', '', '')
				\->substitute('\.', '', 'g')
				\->trim()
	for b in split(blob_str, '[0-9a-fA-F]\{2}\zs')
		if len(b) == 2
			execute 'let blob += 0z' . b
		endif
	endfor
	return blob
endfunction

" 0z00.01.02.03.00.01.02
" return: [ [ start, length ] ]
" startはアドレスに近い
function xxd#util#searchblob(blobs, blob) abort
	let ret = []
	if empty(a:blob)
		return ret
	endif
	for i in range(len(a:blobs) - len(a:blob) + 1)
		if a:blobs[i:i + len(a:blob) - 1] == a:blob
			call add(ret, [ i, len(a:blob) ])
		endif
	endfor
	return ret
endfunction

" lhs: [ start, length ], rhs: [ start, length ]
" return v:true if lhs < rhs
function xxd#util#islesspos(lhs, rhs) abort
	if a:lhs[0] < a:rhs[0]
		return v:true
	endif
	if a:lhs[0] == a:rhs[0] && a:lhs[1] < a:rhs[1]
		return v:true
	endif
	return v:false
endfunction

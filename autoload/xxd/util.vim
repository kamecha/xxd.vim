
" xxdの出力形式の文字列からバイナリデータを取得
" 後半のascii部分は無視
" TODO: ひとまずhex限定
" 000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
" return: 0z0010.0020.4F00.0000.0000.0000.0000.0000
" 000020: 0010
" return: 0z0010
function! xxd#util#line2blob(line) abort
	" 最初のアドレス部分を削除
	let bytes_str = a:line
				\->matchstr('^\(\d\+\):\s\zs.*$')
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
" 000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
" return: 0x0010
function xxd#util#line2address(line) abort
	" 最初のアドレス部分を取得
	let address_str = a:line
				\->matchstr('^\(\d\+\):\s.*$')
	let address = address_str->str2nr(16)
	return address
endfunction

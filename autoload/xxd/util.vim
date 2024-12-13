
" xxdの出力形式の文字列からバイナリデータを取得
" 後半のascii部分は無視
" TODO: ひとまずhex限定
" 000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...
" return: blob
function! xxd#util#line2blob(line) abort
	let bytes_str = matchstr(a:line, '^\(\d\+\):\s\zs.*')
				\->matchstr('.*\s\s\ze.*$')
				\->trim()
				\->substitute('\s', '', 'g')
	let bytes = 0z
	execute 'let bytes += 0z' . bytes_str
	return bytes
endfunction

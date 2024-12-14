
let s:suite = themis#suite('Test for write')
let s:assert = themis#helper('assert')

""" バッファからの保存がちゃんとファイルに保存されるか確認

function s:suite.xxd_write_through() abort
	let file_actual = 'actual.txt'
	let file_expected = 'expected.txt'
	" 0123456789ABCDEF
	let bytes  = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file_actual, 'bD')
	call writefile(bytes, file_expected, 'bD')
	" plugin経由での書き込み
	execute 'Xxd! ' . file_actual
	write
	call s:assert.equals(readfile(file_actual, 'b'), readfile(file_expected, 'b'))
endfunction

function s:suite.xxd_write_through_with_parameter() abort
	let file_actual = 'actual.txt'
	let file_expected = 'expected.txt'
	" 0123456789ABCDEF
	let bytes  = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file_actual, 'bD')
	call writefile(bytes, file_expected, 'bD')
	let options = '-g 1 -s 0x01 -len 3 '
	" plugin経由での書き込み
	execute 'Xxd! ' . options . file_actual
	write
	call s:assert.equals(readfile(file_actual, 'b'), readfile(file_expected, 'b'))
endfunction

" バッファを編集した後に保存する場合

function s:suite.xxd_write_replace() abort
	let file_actual = 'actual.txt'
	let file_expected = 'expected.txt'
	" 0123456789ABCDEF
	let bytes_actual    = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	" F123456789ABCDEF
	let bytes_expected  = 0z46.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes_actual, file_actual, 'bD')
	call writefile(bytes_expected, file_expected, 'bD')
	" plugin経由での書き込み
	execute 'Xxd! ' . file_actual
	s/30/46
	write
	call s:assert.equals(readfile(file_actual, 'b'), readfile(file_expected, 'b'))
endfunction


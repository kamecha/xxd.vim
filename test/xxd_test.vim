
let s:suite = themis#suite('Test for xxd')
let s:assert = themis#helper('assert')

""" xxd経由の出力がちゃんとバッファと同じか確認

" xxdでファイルのダンプをバッファに表示するテスト
function s:suite.xxd_dump_oneline() abort
	let file = 'test.txt'
	" writefileはListを投げると確定で改行を入れちゃうぽいからBlobで書き込む
	" 0123456789ABCDEF
	let bytes = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file, 'bD')
	" 生のxxdの出力
	let expected = systemlist('xxd ' . file)
	" コマンド経由でのxxdの出力
	execute 'Xxd! ' . file
	let actual = getline(1, '$')
	call s:assert.equals(actual, expected)
endfunction

" バイト列が複数行に渡る場合
function s:suite.xxd_dump_lines() abort
	let file = 'test.txt'
	" 0123456789ABCDEF
	let bytes  = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	let bytes += 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file, 'bD')
	" 生のxxdの出力
	let expected = systemlist('xxd ' . file)
	" コマンド経由でのxxdの出力
	execute 'Xxd! ' . file
	let actual = getline(1, '$')
	call s:assert.equals(actual, expected)
endfunction

" FIXME: themisの一連のテストの流れで一つのvimを使ってるらしく、↑で書き込んだバイナリが残ってて落ちる
" ↑描画範囲以外を削除する事で対処したけど、一つのvimを使ってるのは念頭にしとく
" xxdにオプションが渡された場合
function s:suite.xxd_dump_with_option() abort
	let file = 'test.txt'
	" 0123456789ABCDEF
	let bytes  = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file, 'bD')
	let expected = systemlist('xxd -g 1 ' . file)
	execute 'Xxd! -g 1 ' . file
	let actual = getline(1, '$')
	call s:assert.equals(actual, expected)
endfunction

" 部分的に読み込む
function s:suite.xxd_dump_with_partial() abort
	let file = 'test.txt'
	" 0123456789ABCDEF
	let bytes  = 0z30.31.32.33.34.35.36.37.38.39.41.42.43.44.45.46
	call writefile(bytes, file, 'bD')
	let options = '-g 1 -s 0x01 -len 3 '
	let expected = systemlist('xxd ' . options . file)
	execute 'Xxd! ' . options . file
	let actual = getline(1, '$')
	call s:assert.equals(actual, expected)
endfunction



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

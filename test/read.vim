
let s:suite = themis#suite('Test for read')
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


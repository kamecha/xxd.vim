
let s:suite = themis#suite('Test for jump')
let s:assert = themis#helper('assert')

" jumpした後のbyteposで比較する
function s:suite.xxd_jump_default() abort
	let dump = [
				\"00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0000  jump.vim........",
				\"00000010: 0a01 0203 0405 0607 0809 0a0b 0c0d 0e0f  ................",
				\]
	call setline(1, dump)
	" address: 0x12
	let expected = [ 1, 2 ]
	Xxd jump 0x12
	let actual = xxd#core#view#byte#getcurpos(win_getid())
	call s:assert.equals(actual, expected)
	" TODO: 書きこんだバッファの後処理しとく
endfunction

" jumpした後のbyteposで比較する
function s:suite.xxd_jump_g1() abort
	let dump = [
				\"00000000: 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f  ................",
				\"00000010: 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f  ................",
				\]
	call setline(1, dump)
	" address: 0x12
	let expected = [ 1, 2 ]
	Xxd jump 0x12
	let actual = xxd#core#view#byte#getcurpos(win_getid())
	call s:assert.equals(actual, expected)
	" TODO: 書きこんだバッファの後処理しとく
endfunction

function s:suite.xxd_jump_s5() abort
	let dump = [
				\"00000005: 0506 0708 090a 0b0c 0d0e 0f10 1112 1314  ................",
				\]
	call setline(1, dump)
	" address: 0x08
	let expected = [ 0, 3 ]
	Xxd jump 0x08
	let actual = xxd#core#view#byte#getcurpos(win_getid())
	call s:assert.equals(actual, expected)
endfunction



let s:suite = themis#suite('Test for search')
let s:assert = themis#helper('assert')

" カーソル位置・ハイライト位置をテスト

function s:suite.xxd_search() abort
	let dump = [
				\"00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0001  jump.vim........",
				\"00000010: 0a01 0203 0405 0607 0809 0a01 0c0d 0e0f  ................",
				\]
	call setline(1, dump)
	" search: 0z0a01
	let expected_pos = [ 1, 0 ]
	call feedkeys("0a01\<CR>")
	call xxd#feature#search#start('', 'forward')
	let actual_pos = xxd#core#view#byte#getpos('.')
	call s:assert.equals(actual_pos, expected_pos)
	" `n`で次のマッチ
	let expected_pos = [ 1, 10 ]
	call xxd#feature#search#start(
				\b:xxd_search_confirmed_str,
				\b:xxd_search_confirmed_direction
				\)
	let actual_pos = xxd#core#view#byte#getpos('.')
	call s:assert.equals(actual_pos, expected_pos)
	" `N`で前のマッチ
	let expected_pos = [ 1, 0 ]
	call xxd#feature#search#start(
				\b:xxd_search_confirmed_str,
				\b:xxd_search_confirmed_direction == 'forward' ? 'backward' : 'forward'
				\)
	let actual_pos = xxd#core#view#byte#getpos('.')
	call s:assert.equals(actual_pos, expected_pos)
	bdelete!
endfunction


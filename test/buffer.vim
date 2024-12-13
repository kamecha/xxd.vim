
let s:suite = themis#suite('Test for bufname')
let s:assert = themis#helper('assert')

" プラグイン用のbufnameの確認

function s:suite.xxd_bufname_file_only() abort
	let file = 'test.txt'
	let expected = 'xxd://' . file . ';'
	let actual = xxd#core#buffer#bufname(file, [])
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_bufname_file_with_key_value_option() abort
	let file = 'test.txt'
	let options = [{ 'g': 1 }]
	let expected = 'xxd://' . file . ';' . 'g=1'
	let actual = xxd#core#buffer#bufname(file, options)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_bufname_file_with_key_value_options() abort
	let file = 'test.txt'
	let options = [{ 'g': 1 }, { 's': 0x01 }, { 'len': 3 }]
	let expected = 'xxd://' . file . ';' . 'g=1&s=1&len=3'
	let actual = xxd#core#buffer#bufname(file, options)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_bufname_file_with_value_option() abort
	let file = 'test.txt'
	let options = ['a']
	let expected = 'xxd://' . file . ';' . 'a'
	let actual = xxd#core#buffer#bufname(file, options)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_bufname_file_with_value_options() abort
	let file = 'test.txt'
	let options = ['a', 'b']
	let expected = 'xxd://' . file . ';' . 'a&b'
	let actual = xxd#core#buffer#bufname(file, options)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_bufname_file_with_value_and_key_value_options() abort
	let file = 'test.txt'
	let options = ['a', 'b', { 'g': 1 }]
	let expected = 'xxd://' . file . ';' . 'a&b&g=1'
	let actual = xxd#core#buffer#bufname(file, options)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_parse() abort
	let expr = 'xxd://test.txt;a&b&g=1'
	let expected = #{ file: 'test.txt', options: ['a', 'b', { 'g': 1 }] }
	let actual = xxd#core#buffer#parse(expr)
	call s:assert.equals(actual, expected)
endfunction



let s:suite = themis#suite('Test for converter')
let s:assert = themis#helper('assert')

function s:suite.xxd_line2blob_default() abort
	let line = '000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...'
	let expected = 0z0010.0020.4F00.0000.0000.0000.0000.0000
	let actual = xxd#util#line2blob(line)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_line2blob_tiny_byte() abort
	let line = '000010: 0010                                     ...'
	let expected = 0z0010
	let actual = xxd#util#line2blob(line)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_line2blob_no_char() abort
	let line = '000010: 0010 0020 4F00'
	let expected = 0z0010.0020.4F00
	let actual = xxd#util#line2blob(line)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_line2address_default() abort
	let line = '000010: 0010 0020 4F00 0000 0000 0000 0000 0000  ...'
	let expected = 0x0010
	let actual = xxd#util#line2address(line)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_line2address_no_char() abort
	let line = '000010: 0010 0020 4F00'
	let expected = 0x0010
	let actual = xxd#util#line2address(line)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_blob2hex() abort
	let blob = 0z00.01.02
	let expected = 0x000102
	let actual = xxd#util#blob2hex(blob, 'big')
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_blob2hex_little() abort
	let blob = 0z00.01.02
	let expected = 0x020100
	let actual = xxd#util#blob2hex(blob, 'little')
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_str2blob() abort
	let blob_str = "0z00.0102.03.0102"
	let expected = 0z00.0102.03.0102
	let actual = xxd#util#str2blob(blob_str)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_str2blob_no_prefix() abort
	let blob_str = "00.0102.03.0102"
	let expected = 0z00.0102.03.0102
	let actual = xxd#util#str2blob(blob_str)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_str2blob_middle() abort
	let blob_str = "00.0102.0"
	let expected = 0z00.0102
	let actual = xxd#util#str2blob(blob_str)
	call s:assert.equals(actual, expected)
endfunction

function s:suite.xxd_searchblob() abort
	let blob = 0z00.0102.03.0102
	" 0z0102を検索
	let expected = [ [ 1, 2 ], [ 4, 2 ] ]
	let actual = xxd#util#searchblob(blob, 0z0102)
	call s:assert.equals(actual, expected)
endfunction


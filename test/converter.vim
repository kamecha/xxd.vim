
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


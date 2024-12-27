
let s:suite = themis#suite('Test for view')
let s:assert = themis#helper('assert')

function s:suite.xxd_view_getpos() abort
	let dump = [
				\"00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0000  jump.vim........",
				\"00000010: 0a01 0203 0405 0607                      ........",
				\]
	call setline(1, dump)
	" 末尾のbytepos
	let expected = [ 1, 7 ]
	let actual = xxd#core#view#byte#getpos('$')
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_view_getpos_hex_a() abort
	let dump = [
				\"00000000: 3842 5053 0001 0000 0000 0000 0003 0000  8BPS............",
				\"00000010: 0010 0000 0010 0008 0003 0000 0000 0000  ................",
				\"00000020: 0034 3842 494d 03ed 0000 0000 0010 0048  .48BIM.........H",
				\"00000030: 0000 0001 0000 0048 0000 0001 0000 3842  .......H......8B",
				\"00000040: 494d 03ee 0000 0000 0000 3842 494d 0415  IM........8BIM..",
				\"00000050: 0000 0000 0000 0000 028c 0000 026a 0002  .............j..",
				\"00000060: 0000 0000 0000 0000 0000 0010 0000 0010  ................",
				\"00000070: 0004 ffff 0000 0042 0000 0000 0042 0001  .......B.....B..",
				\"00000080: 0000 0042 0002 0000 0042 3842 494d 6e6f  ...B.....B8BIMno",
				\"00000090: 726d ff00 0000 0000 006c 0000 0000 0000  rm.......l......",
				\"000000a0: 0028 0000 ffff                           .(...",
				\]
	call setline(1, dump)
	" 末尾のbytepos
	let expected = [ 10, 5 ]
	let actual = xxd#core#view#byte#getpos('$')
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_view_getpos_lastone() abort
	let dump = [
				\"00000000: 6a75 6d70 2e76 696d 0a00 0000 0000 0000  jump.vim........",
				\"00000010: 0a                                       .",
				\]
	call setline(1, dump)
	" 末尾のbytepos
	let expected = [ 1, 0 ]
	let actual = xxd#core#view#byte#getpos('$')
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_view_getbytes() abort
	let dump = [
				\"00000000: 3842 5053 0001 0000 0000 0000 0003 0000  8BPS............",
				\"00000010: 0010 0000 0010 0008 0003 0000 0000 0000  ................",
				\"00000020: 0034 3842 494d 03ed 0000 0000 0010 0048  .48BIM.........H",
				\"00000030: 0000 0001 0000 0048 0000 0001 0000 3842  .......H......8B",
				\"00000040: 494d 03ee 0000 0000 0000 3842 494d 0415  IM........8BIM..",
				\"00000050: 0000 0000 0000 0000 028c 0000 026a 0002  .............j..",
				\"00000060: 0000 0000 0000 0000 0000 0010 0000 0010  ................",
				\"00000070: 0004 ffff 0000 0042 0000 0000 0042 0001  .......B.....B..",
				\"00000080: 0000 0042 0002 0000 0042 3842 494d 6e6f  ...B.....B8BIMno",
				\"00000090: 726d ff00 0000 0000 006c 0000 0000 0000  rm.......l......",
				\"000000a0: 0028 0000 ffff                           .(...",
				\]
	call setline(1, dump)
	" 0x082 - 0x0a5までのbyte
	let expected = 0z
				\0042.0002.0000.0042.3842.494d.6e6f.
				\726d.ff00.0000.0000.006c.0000.0000.0000.
				\0028.0000.ffff
	let actual = xxd#core#view#byte#getbytes(win_getid(), [ 8, 2 ], [ 10, 5 ])
	call s:assert.equals(actual, expected)
	bdelete!
endfunction


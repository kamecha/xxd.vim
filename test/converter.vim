
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
	let line = '0000a0: 0010 0020 4F00'
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
	let line = '0000a0: 0010 0020 4F00'
	let expected = 0x00a0
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

function s:suite.xxd_address2pos() abort
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
	" 0x0a1
	let expected = [ 10, 1 ]
	let actual = xxd#core#view#byte#address2pos(win_getid(), 0x0a1)
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_pos2address() abort
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
	let expected = 0x0a1
	let actual = xxd#core#view#byte#pos2address(win_getid(), [ 10, 1 ])
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_pos2rel() abort
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
	" address: 0x0a1
	" vim上のカーソルは1-index
	let expected = [ 11, len("000000a0: 002") ]
	let actual = xxd#core#view#byte#pos2rel(win_getid(), [ 10, 1 ])
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_rel2pos() abort
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
	let rel = [ 11, len("000000a0: 0028 0") ]
	" 000000a0: 0028 0000 ffff                           .(...",
	"                ^ここにカーソルがある場合
	let expected = [ 10, 2 ]
	let actual = xxd#core#view#byte#rel2pos(win_getid(), rel)
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_rel2pos_address() abort
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
	let rel = [ 11, len("000000a") ]
	" 000000a0: 0028 0000 ffff                           .(...",
	"       ^ここにカーソルがある場合
	let expected = [ 10, 0 ]
	let actual = xxd#core#view#byte#rel2pos(win_getid(), rel)
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_rel2pos_before() abort
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
	let rel = [ 11, len("000000a0: 0028 ") ]
	" 000000a0: 0028 0000 ffff                           .(...",
	"               ^ここにカーソルがある場合
	let expected = [ 10, 2 ]
	let actual = xxd#core#view#byte#rel2pos(win_getid(), rel)
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_rel2pos_after() abort
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
	let rel = [ 11, len("000000a0: 0028 00") ]
	" 000000a0: 0028 0000 ffff                           .(...",
	"                 ^ここにカーソルがある場合
	let expected = [ 10, 2 ]
	let actual = xxd#core#view#byte#rel2pos(win_getid(), rel)
	call s:assert.equals(actual, expected)
	bdelete!
endfunction

function s:suite.xxd_rel2pos_char() abort
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
	let rel = [ 11, len("000000a0: 0028 0000 ffff                           ") ]
	" 000000a0: 0028 0000 ffff                           .(...",
	"                                                   ^ここにカーソルがある場合
	let expected = [ 10, 5 ]
	let actual = xxd#core#view#byte#rel2pos(win_getid(), rel)
	call s:assert.equals(actual, expected)
	" TODO: assertでabortが発火すると↓の後処理が呼ばれない
	bdelete!
endfunction


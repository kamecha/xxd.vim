
function! xxd#core#get_byte(bufnr, byte_pos) abort
	let line = getbufline(a:bufnr, a:byte_pos[0] + 1)
	let bytes = line
				\->substitute('^\d\+:\s', '', '')
				\->substitute('.\{16}$', '', '')
				\->substitute('\s', '', 'g')
				\->trim()
	return bytes[2 * a:byte_pos[1] : 2 * a:byte_pos[1] + 1]
endfunction

function! xxd#core#get_bytes(bufnr, byte_pos, length) abort
	let bytes = []
	for i in range(a:length)
		let bytes = bytes->add(xxd#core#get_byte(a:bufnr, [
					\a:byte_pos[0] + (a:byte_pos[1] + i) / 16,
					\( a:byte_pos[1] + i ) % 16
					\]))
	endfor
	return bytes
endfunction

function! xxd#core#get_hex(bufnr, byte_pos, length, endian) abort
	let bytes = xxd#core#get_bytes(a:bufnr, a:byte_pos, a:length)
	if a:endian == 'big'
		return join(bytes, '')
	endif
	if a:endian == 'little'
		return join(reverse(bytes), '')
	endif
	return ''
endfunction

function! xxd#core#get_byte_pos(bytes) abort
	let max_byte_width = 16
	return [ a:bytes / max_byte_width, a:bytes % max_byte_width ]
endfunction

function! xxd#core#mark_byte_pos(pos_start, pos_end, hl_group) abort
	let hex_start_col = 10
	let ascii_start_col = 51
	let max_byte_width = 2 * 8
	if a:pos_start[0] == a:pos_end[0]
		call nvim_buf_set_extmark(0, b:mark_ns,
					\a:pos_start[0],
					\hex_start_col + 2 * a:pos_start[1] + a:pos_start[1] / 2,
					\#{
					\	end_col: hex_start_col + 2 * a:pos_end[1] + a:pos_end[1] / 2,
					\	hl_group: a:hl_group
					\})
		return
	endif
	call nvim_buf_set_extmark(0, b:mark_ns,
				\a:pos_start[0],
				\hex_start_col + 2 * a:pos_start[1] + a:pos_start[1] / 2,
				\#{
				\	end_col: hex_start_col + 2 * max_byte_width + max_byte_width / 2,
				\	hl_group: a:hl_group
				\})
	for row in range(a:pos_start[0] + 1, a:pos_end[0] - 1)
		call nvim_buf_set_extmark(0, b:mark_ns,
					\row,
					\hex_start_col,
					\#{
					\	end_col: hex_start_col + 2 * max_byte_width + max_byte_width / 2,
					\	hl_group: a:hl_group
					\})
	endfor
	call nvim_buf_set_extmark(0, b:mark_ns,
				\a:pos_end[0],
				\hex_start_col,
				\#{
				\	end_col: hex_start_col + 2 * a:pos_end[1] + a:pos_end[1] / 2,
				\	hl_group: a:hl_group
				\})
endfunction

function! xxd#core#mark_byte_length(byte, length, hl_group) abort
	let max_byte_width = 2 * 8
	" 0-index
	let byte_pos = xxd#core#get_byte_pos(a:byte)
	let last_byte_pos = xxd#core#get_byte_pos(a:byte + a:length)
	call xxd#core#mark_byte_pos(byte_pos, last_byte_pos, a:hl_group)
	return a:byte + a:length
endfunction

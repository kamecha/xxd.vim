let s:DEFAULT_PARAMS_ATTRIBUTES = {
			\ 'file': '',
			\ 'options': [],
			\}

" xxd://file;options
function! xxd#core#buffer#bufname(file, options) abort
	let bufname = 'xxd://' . a:file
	let bufname .= ';'
	" options
	if empty(a:options)
		return bufname
	endif
	if type(a:options[0]) ==# v:t_dict
		let bufname .= a:options[0]->keys()[0] . '=' . a:options[0]->values()[0]
	else
		let bufname .= a:options[0]
	endif
	for option in a:options[1:]
		if type(option) ==# v:t_dict
			let bufname .= '&' . option->keys()[0] . '=' . option->values()[0]
		else
			let bufname .= '&' . option
		endif
	endfor
	return bufname
endfunction

" xxd://file;a&b&g=1&e
" { 'file': 'file', 'options': [ 'a', 'b', { 'g': 1 }, 'e' ] }
function! xxd#core#buffer#parse(expr) abort
	let m = matchlist(a:expr, '\v^xxd://([^;]+);(.*)$')
	if empty(m)
		return {}
	endif
	let file = m[1]
	let options = []
	for option in split(m[2], '&')
		if option =~# '='
			let [key, value] = split(option, '=')
			let t = {}
			" valueが整数
			if key ==# 'c' || key ==# 'cols'
						\ || key ==# 'g' || key ==# 'groupsize'
						\ || key ==# 'l' || key ==# 'len'
				let t[key] = value->str2nr()
			" valueが16進数
			elseif key ==# 'o' || key ==# 's' || key ==# 'seek'
				let t[key] = value->str2nr(16)
			else
				let t[key] = value
			endif
			call add(options, t)
		else
			call add(options, option)
		endif
	endfor
	return { 'file': file, 'options': options }
endfunction



function! xxd#command#_raw#call(args, options, infile) abort
	call xxd#command#_raw#read(a:args, a:options, a:infile)
endfunction

function! xxd#command#_raw#complete(args) abort
	" 工事中
endfunction

" args:_raw [options] [infile]
" return:
" #[
"  'options': [],
"  'infile': 'hoge.txt',
" ]
function! xxd#command#_raw#args(args) abort
	let l:options = []
	let l:infile = ''
	const xxd_options = [
				\'a', 'autoskip',
				\'b', 'bits',
				\'C', 'capitalize',
				\#{c: 'cols'}, #{cols: 'cols'},
				\'E', 'EBCDIC',
				\'e',
				\#{g: 'bytes'}, #{groupsize: 'bytes'},
				\'h', 'help',
				\'i', 'include',
				\#{l: 'len'}, #{len: 'len'},
				\#{n: 'name'}, #{name: 'name'},
				\#{o: 'offset'},
				\'p', 'ps', 'postscript', 'plain',
				\'r', 'revert',
				\#{R: 'when'},
				\#{seek: 'offset'},
				\#{s: 'seek'},
				\'u',
				\'v', 'version',
				\]
	let args = a:args->trim("_raw", 1)->split('\s\+')
	while len(args)
		let arg = remove(args, 0)
		if arg =~# '^-'
			let option = arg->substitute('^-', '', '')
			" optionが引数を取る場合
			if xxd_options->copy()->filter({_, v -> type(v) ==# v:t_dict && v->has_key(option)})->len()
				let value = remove(args, 0)
				let t = {}
				let t[option] = value
				call add(l:options, t)
			else
				call add(l:options, [option])
			endif
		else
			let l:infile = arg
		endif
	endwhile
	return [a:args, l:options, l:infile]
endfunction

function! xxd#command#_raw#read(args, options, infile) abort
	let bufname = xxd#core#buffer#bufname(a:infile, a:options)
	let bufnr = bufnr(bufname, 1)
	call setbufvar(bufnr, "&filetype", "xxd")
	call setbufvar(bufnr, "&buftype", "acwrite")
	call bufload(bufnr)
	" 普通のファイルを開くかの如くバッファを開く前準備
	let old_undolevels = &undolevels
	call setbufvar(bufnr, "&undolevels", -1)
	let lines = systemlist("xxd " . a:args->trim("_raw", 1))
	call setbufline(bufnr, 1, lines)
	call deletebufline(bufnr, len(lines) + 1, '$')
	let &undolevels = old_undolevels
	unlet old_undolevels
	call setbufvar(bufnr, "&undolevels", 100)
	call setbufvar(bufnr, "&modified", 0)
	" ↓なんかbuffer始まりだと上手くいかないので、`execute`
	execute "buffer " . bufnr
	return bufnr
endfunction

" xxd前提にた書き込みは面倒そう
function! xxd#command#_raw#write(bufnr) abort
	"書き込み時(writefile)はBlobじゃないとおせっかいされる
	"もしくは'b'フラグを付ける
	let file = bufname(a:bufnr)->xxd#core#buffer#parse()->get('file')
	let options = bufname(a:bufnr)->xxd#core#buffer#parse()->get('options')
	let seek = options
				\->filter({_, v -> type(v) ==# v:t_dict && v->keys()[0] ==# 's'})
				\->get(0, #{s: 0})
				\->get('s', 0)
	let len = options
				\->filter({_, v -> type(v) ==# v:t_dict && ( v->keys()[0] ==# 'l' || v->keys()[0] ==# 'len' )})
				\->get(0, #{l: -1})
				\->get('l', -1)
	let len = options
				\->filter({_, v -> type(v) ==# v:t_dict && ( v->keys()[0] ==# 'l' || v->keys()[0] ==# 'len' )})
				\->get(0, #{l: len})
				\->get('len', len)
	let bytes = readfile(file, 'B')
	for line in getbufline(a:bufnr, 1, '$')
		let address = xxd#util#line2address(line)
		let b = xxd#util#line2blob(line)
		if address + len(b) >= len(bytes)
			if address > len(bytes)
				let bytes += repeat(0z00, address - len(bytes))
				let bytes += b
			else
				let bytes[address:] = b[:len(bytes) - address - 1]
				let bytes += b[len(bytes) - address:]
			endif
		else
			let bytes[address:address + len(b) - 1] = b
		endif
	endfor
	call writefile(bytes, file, 'b')
	call setbufvar(a:bufnr, "&modified", 0)
endfunction

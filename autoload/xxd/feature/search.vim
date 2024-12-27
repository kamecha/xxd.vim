" vimっぽい検索機能を提供したい
" :help search-commandsを参照する
" /：前方検索
" ?：後方検索
" ↑どちらも排他的で現在カーソル位置に該当する箇所はマッチしない
"	ただ一個しかない時は次のマッチが同じになる
" 移動した後の、nだからもう一度同じ処理で移動できる
" 探すbyte列と検索方向だけ保存しとけば良さげかな

function xxd#feature#search#start(bytes_str) abort
	let b:xxd_search_confirmed_str = get(b:, 'xxd_search_confirmed_str', '')
	let b:xxd_search_confirmed_match = get(b:, 'xxd_search_confirmed_match', [])
	let b:xxd_search_match = get(b:, 'xxd_search_match', [])
	" inputを途中でやめると返り値が空文字列になる
	if a:bytes_str == ''
		let bytes_str = input('Search byte sequence/', '0z')
	else
		let bytes_str = a:bytes_str
	endif
	" 空文字列での<CR> or <ESC>の場合
	if bytes_str == ''
		" 検索を中断する
		for match in b:xxd_search_match
			call matchdelete(match, win_getid())
			let b:xxd_search_match = []
		endfor
		call xxd#feature#search#byte(
					\win_getid(),
					\b:xxd_search_confirmed_str->xxd#util#str2blob()
					\)
	else
		" 検索文字列を確定させる
		let b:xxd_search_confirmed_str = bytes_str
		let b:xxd_search_confirmed_match = b:xxd_search_match
		call xxd#feature#search#byte(
					\win_getid(),
					\b:xxd_search_confirmed_str->xxd#util#str2blob()
					\)
		" 検索箇所にジャンプ
		eval win_getid()
					\->xxd#core#view#byte#address2pos(b:xxd_search_result[0][0])
					\->xxd#core#view#byte#cursor()
	endif
endfunction

" 検索とハイライト
" input中に常時発動するイメージ
function xxd#feature#search#byte(winid, bytes) abort
	" 前回の検索ハイライトを消す
	for match in b:xxd_search_match
		call matchdelete(match, a:winid)
		let b:xxd_search_match = []
	endfor
	let blobs = xxd#core#view#byte#getbytes(
				\ a:winid,
				\ [ 0, 0 ],
				\ xxd#core#view#byte#getpos('$')
				\)
	let next_direction_address = xxd#core#view#byte#pos2address(
				\ a:winid,
				\ xxd#core#view#byte#getpos('.')
				\)
	let b:xxd_search_result = xxd#util#searchblob(blobs, a:bytes)
				\->xxd#feature#search#sortbyte(next_direction_address, 'forward')
	if b:xxd_search_result->len()
		let next_match = b:xxd_search_result[0]
		let b:xxd_search_match += xxd#core#view#byte#matchaddaddrlen("IncSearch", next_match[0], next_match[1])
		if b:xxd_search_result->len() > 1
			for result in b:xxd_search_result[1:]
				let b:xxd_search_match += xxd#core#view#byte#matchaddaddrlen("Search", result[0], result[1])
			endfor
		endif
		" ↓これautocmd中だから？とりあえず必要
		redraw
	endif
endfunction

" search_result: [ [ start, length ], [ ... ], ... ]
" address: 現在のアドレス
" direction: 'forward' or 'backward'
" ↓address以降の検索結果に並び換え
" return: [ [ start, length ], [ ... ], ... ]
"	一番目の要素が次のマッチ
function xxd#feature#search#sortbyte(search_result, address, direction) abort
	let ret = []
	" TODO: いったんforwardのみを意識
	" マッチを選択
	" 二分探索とか良さそう
	" ng側を設定して、それのmodとった次をマッチにすると1個の時もそのまま対応できそう
	let ng = -1
	let ok = len(a:search_result)
	while ng + 1 < ok
		let mid = (ng + ok) / 2
		if a:address >= a:search_result[mid][0]
			let ng = mid
		else
			let ok = mid
		endif
	endwhile
	for i in range(len(a:search_result))
		let idx = (i + ok) % len(a:search_result)
		call add(ret, a:search_result[idx])
	endfor
	return ret
endfunction


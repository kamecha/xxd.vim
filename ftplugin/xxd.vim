
nnoremap <buffer><silent> <Plug>(xxd-search-start-forwad)
			\ <Cmd>call xxd#feature#search#start('', 'forward')<CR>

nnoremap <buffer><silent> <Plug>(xxd-search-start-backward)
			\ <Cmd>call xxd#feature#search#start('', 'backward')<CR>

nnoremap <buffer><silent> <Plug>(xxd-search-next)
			\ <Cmd>call xxd#feature#search#start(
			\	b:xxd_search_confirmed_str,
			\	b:xxd_search_confirmed_direction
			\)<CR>

nnoremap <buffer><silent> <Plug>(xxd-search-prev)
			\ <Cmd>call xxd#feature#search#start(
			\	b:xxd_search_confirmed_str,
			\	b:xxd_search_confirmed_direction == 'forward' ? 'backward' : 'forward'
			\)<CR>


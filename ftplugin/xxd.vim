
nnoremap <buffer><silent> <Plug>(xxd-search-start)
			\ <Cmd>call xxd#feature#search#start('')<CR>

nnoremap <buffer><silent> <Plug>(xxd-search-next)
			\ <Cmd>call xxd#feature#search#start(b:xxd_search_confirmed_str)<CR>

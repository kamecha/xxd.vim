
" !Xxd hoge.txt みたくして通常のxxdコマンドの結果をそのまま表示
" Xxd! ←こっちでも良いかも？、てかこっちじゃないと仕様的に無理そう
command! -nargs=* -bang
			\ -complete=customlist,xxd#command#complete
			\ Xxd
			\ call xxd#command#call(<q-bang>, <q-args>)

let g:xxd_inspector_list = get(g:, 'xxd_inspector_list', [])

augroup xxd
	autocmd!
	autocmd BufWriteCmd xxd://* call xxd#command#_raw#write(bufnr())
	" CmdlineChangedのパターンはコマンドラインの種類
	autocmd CmdlineChanged @ if &filetype == 'xxd'
				\ | call xxd#feature#search#byte(
				\     win_getid(),
				\     getcmdline()->xxd#util#str2blob()
				\   )
				\ | endif
	autocmd CursorMoved xxd://* eval
				\ xxd#feature#inspector#getblob()
				\ ->xxd#feature#inspector#draw(g:xxd_inspector_list)
augroup END


" !Xxd hoge.txt みたくして通常のxxdコマンドの結果をそのまま表示
" Xxd! ←こっちでも良いかも？、てかこっちじゃないと仕様的に無理そう
command! -nargs=* -bang
			\ -complete=customlist,xxd#command#complete
			\ Xxd
			\ call xxd#command#call(<q-bang>, <q-args>)

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
augroup END

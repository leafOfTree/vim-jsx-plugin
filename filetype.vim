autocmd BufNewFile,BufRead *.js,*.ts,*.tsx call s:SetFiletype()

function! s:SetFiletype()
  let &filetype = 'jsx'
endfunction

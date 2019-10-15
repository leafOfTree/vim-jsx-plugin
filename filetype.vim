autocmd BufNewFile,BufRead *.js call s:SetFiletype()

function! s:SetFiletype()

  let &filetype = 'jsx'
endfunction

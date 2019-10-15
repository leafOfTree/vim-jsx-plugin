let s:name = 'vim-jsx-plugin'
let s:debug = exists("g:vim_jsx_plugin_debug")
      \ && g:vim_jsx_plugin_debug == 1

function! jsx#Log(msg)
  if s:debug
    echom '['.s:name.']['.v:lnum.'] '.a:msg
  endif
endfunction

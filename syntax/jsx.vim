
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Functions {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:LoadSyntax(group, type)
  if s:load_full_syntax
    call s:LoadFullSyntax(a:group, a:type)
  else
    call s:LoadDefaultSyntax(a:group, a:type)
endfunction

function! s:LoadDefaultSyntax(group, type)
  unlet! b:current_syntax
  let syntaxPaths = ['$VIMRUNTIME', '$VIM/vimfiles', '$HOME/.vim']
  for path in syntaxPaths
    let file = expand(path).'/syntax/'.a:type.'.vim'
    if filereadable(file)
      execute 'syntax include '.a:group.' '.file
    endif
  endfor
endfunction

function! s:LoadFullSyntax(group, type)
  unlet! b:current_syntax
  execute 'syntax include '.a:group.' syntax/'.a:type.'.vim'
endfunction
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Load main syntax {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call s:LoadFullSyntax('@JavaScriptSyntax', 'javascript')

" Load syntax/*.vim to syntax group
call s:LoadFullSyntax('@HTMLSyntax', 'html')
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Syntax highlight {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" All start with html/javascript/css for emmet-vim in-file type detection
syntax region javascriptDefault fold
      \ start=+.*+
      \ end=+.*+
      \ contains=@JavaScriptSyntax,jsxTemplate,jsxTemplateEmpty

""" Template
" Ends with ;|,
syntax region jsxTemplate fold
      \ start=+<[a-zA-Z0-9.]\+\(.*\/>\)\@!.*\(>\|\s*$\)+
      \ end=+</[a-zA-Z0-9.]\+>\ze\(\n\s*\)*)\?\(;\|,\)\s*$+
      \ keepend 
      \ contains=@HTMLSyntax,jsxInlineExpression
" Surrouded by '(...)'
syntax region jsxTemplate fold
      \ start=+(\n\s*<[a-zA-Z0-9.]\+\(.*\/>\)\@!.*\(>\|\s*$\)+
      \ end=+</[a-zA-Z0-9.]\+>\ze\(\n\s*\)*)\s*$+
      \ keepend 
      \ contains=@HTMLSyntax,jsxInlineExpression

" In one line
syntax match jsxTemplate fold
      \ +<[a-zA-Z0-9]\+[^>]*>.*</[a-zA-Z0-9]\+>$+
      \ contains=@HTMLSyntax,jsxInlineExpression
" Empty
syntax region jsxTemplateEmpty fold
      \ start=+<[a-zA-Z0-9\.]\+$+
      \ end=+^\s*/>\s*$+
      \ keepend 
      \ contains=@HTMLSyntax,jsxInlineExpression

" Empty tag
let empty_tag_regexp = '<[a-zA-Z0-9]\+\(.*<[^>]\+>\)\@!.\{-}\(\n\(.*<[^>]\+>\)\@!.\{-}\)*.\/>'

syntax region jsxInlineExpression fold
      \ start=+{+
      \ end=+}\ze\s*\($\|<\)+
      \ keepend 
      \ contained
      \ contains=jsxInlineTemplate,@JavaScriptSyntax
syntax region jsxAttrExpression fold
      \ start=+{+
      \ end=+}\ze\([[:blank:]\/>]\+\|\s*$\)+
      \ contained
      \ keepend
      \ containedin=htmlValue
      \ contains=jsxInlineTemplate,@JavaScriptSyntax

syntax region jsxInlineTemplate fold
      \ start=+<[a-zA-Z0-9]\+[^/>]*\(>\|\s*$\)+
      \ end=+</[a-zA-Z0-9]\+>+
      \ keepend 
      \ contained
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxInlineTemplate
" Empty tag 
syntax region jsxInlineTemplate fold
      \ start=+<[a-zA-Z0-9]\+[^/>]*\(>\|\s*$\)+
      \ end=+/>+
      \ keepend 
      \ contained
      \ keepend
      \ containedin=htmlValue
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxInlineTemplate

syntax match htmlTagN contained +<\s*[-a-zA-Z0-9\.]\++hs=s+1 
      \ contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster,JsxComponentName
syntax match htmlTagN contained +</\s*[-a-zA-Z0-9\.]\++hs=s+2 
      \ contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster,JsxComponentName

syntax match JsxComponentName /\v\C[A-Z][-a-zA-Z0-9.]+/ containedin=htmlTagN contained
highlight default link JsxComponentName htmlTagName
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Patch {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight! link htmlError None
" vim: fdm=marker

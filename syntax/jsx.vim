if exists("b:current_syntax") && b:current_syntax == 'jsx'
  finish
endif

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
" Load syntax/*.vim to syntax group
call s:LoadFullSyntax('@HTMLSyntax', 'html')

" Avoid overload
if hlexists('javaScriptComment') == 0
  call s:LoadSyntax('@htmlJavaScript', 'javascript')
endif
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
      \ contains=@htmlJavaScript,jsxTemplateOuter,jsxTemplateEmpty

""" Template
" Surrouded by '(' and ')'
syntax region jsxTemplateOuter fold
      \ start=+\(\w\)\@<!<[a-zA-Z0-9.]\+\(.*\/>\)\@![^>]*\(>\|\s*$\)+
      \ end=+<\/[a-zA-Z0-9.]\+>\ze\(\n\s*\)*\()\|,\|;\|\s*$\)\(\n\s*<\)\@!+
      \ keepend
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxTemplate
" Empty
syntax region jsxTemplateOuter fold
      \ start=+<[a-zA-Z0-9.]\+[^>]*$+
      \ end=+/>\s*$+
      \ keepend
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxTemplate
syntax match jsxTemplateOuter fold 
      \ +<[a-zA-Z0-9.]\+[^>]*/>\s*$+
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxTemplate

syntax region jsxTemplate fold
      \ start=+\(\w\)\@<!<[a-zA-Z0-9.]\+\(.*\/>\)\@![^>]*\(>\|\s*$\)+
      \ end=+<\/[a-zA-Z0-9.]\+>+
      \ contained
      \ contains=@HTMLSyntax,jsxInlineExpression

" In one line
syntax match jsxTemplate fold
      \ +<[a-zA-Z0-9]\+[^>]*>.*</[a-zA-Z0-9]\+>$+
      \ contains=@HTMLSyntax,jsxInlineExpression

" Empty
syntax region jsxTemplateEmpty fold
      \ start=+<[a-zA-Z0-9.]\+[^>]*$+
      \ end=+/>\s*$+
      \ keepend
      \ contains=@HTMLSyntax,jsxInlineExpression

" syntax region jsxInlineExpression fold
      " \ start=+{+
      " \ end=+}\ze\s*\($\|<\)+
      " \ keepend 
      " \ contained
      " \ contains=jsxInlineTemplate,@htmlJavaScript
syntax region jsxInlineExpression fold
      \ start=+^\s*\zs{+
      \ end=+}\ze\s*$+
      \ keepend 
      \ contained
      \ contains=jsxInlineTemplate,@htmlJavaScript
syntax region jsxAttrExpression fold
      \ start=+=\zs{+
      \ end=+}\ze\([[:blank:]\/>]\+\|\s*$\)+
      \ contained
      \ keepend
      \ containedin=jsxTemplate,htmlValue
      \ contains=jsxInlineTemplate,@htmlJavaScript

" Template in expression
syntax region jsxInlineTemplate fold
      \ start=+<[a-zA-Z0-9]\+[^>]*\(>\|\s*$\)+
      \ end=+</[a-zA-Z0-9]\+>+
      \ keepend 
      \ contained
      \ contains=@HTMLSyntax,jsxInlineExpression,jsxInlineTemplate
" Empty tag 
syntax region jsxInlineTemplate fold
      \ start=+<[a-zA-Z0-9]\+[^>]*\(>\|\s*$\)+
      \ end=+/>+
      \ keepend
      \ contained
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
"}}}

let b:current_syntax = 'jsx'
" vim: fdm=marker

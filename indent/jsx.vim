"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Settings {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:template = ['jsxTemplate', 'jsxTemplateEmpty']
let s:inline_template = ['jsxInlineTemplate']
let s:inline_expression = ['jsxInlineExpression']
let s:inline_attr = ['jsxAttrExpression']
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Load indent method {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use lib/indent/ files for compatibility
unlet! b:did_indent
runtime lib/indent/xml.vim

" Use normal indent files
unlet! b:did_indent
runtime lib/indent/javascript.vim
let b:javascript_indentexpr = &indentexpr
"""}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Settings {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
setlocal shiftwidth=2 tabstop=2
" JavaScript indentkeys
setlocal indentkeys=0{,0},0),0],0\,,!^F,o,O,e,:
" XML indentkeys
setlocal indentkeys+=*<Return>,<>>,<<>,/
setlocal indentexpr=GetJsxIndent()
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Functions {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetJsxIndent()
  let ind = 0
  let prevlnum = prevnonblank(v:lnum - 1)
  let prevsyns = s:SynsSOL(prevlnum)
  " let prevsyns = s:SynsEOL(prevlnum)

  let curline = getline(v:lnum)
  let cursyns = s:SynsSOL(v:lnum)
  " let cursyns = s:SynsEOL(v:lnum)

  let prev_syn_type = s:SynType(prevsyns)
  let cur_syn_type = s:SynType(cursyns)
  call jsx#Log('prev syn type: '.prev_syn_type)
  call jsx#Log('cur syn type: '.cur_syn_type)

  " XML
  " if prev_syn_type == 'inline_template' || prev_syn_type == 'template'
        " \ && cur_syn_type == 'inline_template'
    " let ind = s:GetXMLIndent()
  " endif
  " if prev_syn_type == 'inline_expression' && cur_syn_type == 'template'
        " \ || prev_syn_type == 'inline_expression' && cur_syn_type == 'inline_template'
        " \ || prev_syn_type == 'template' && cur_syn_type == 'inline_expression'
    " let ind = s:GetXMLIndent()
  " endif
  if prev_syn_type != 'default' 
        \ && (cur_syn_type == 'template' || cur_syn_type == 'inline_template')
    let ind = s:GetXMLIndent()
  endif
  if prev_syn_type == 'template' && cur_syn_type == 'inline_expression'
    let ind = s:GetXMLIndent()
  endif

  " JavaScript
  if prev_syn_type == 'template' && cur_syn_type == 'inline_attr'
    let ind = s:GetJavaScriptIndent()
  endif
  if prev_syn_type == 'defualt' || cur_syn_type == 'default'
    let ind = s:GetJavaScriptIndent()
  endif

  if !ind
    call jsx#Log('---- No indent ----')
    let ind = s:GetJavaScriptIndent()
  endif
  call jsx#Log('indent: '.ind)
  return ind
endfunction

function! s:GetXMLIndent()
  call jsx#Log('syntax: xml')
  return XmlIndentGet(v:lnum, 0)
endfunction

function! s:GetJavaScriptIndent()
  call jsx#Log('syntax: javascript')
  return eval(b:javascript_indentexpr)
endfunction

function! s:SynType(syns)
  let type = 'default'
  for syn in reverse(a:syns)
    if count(s:template, syn) != 0
      let type = 'template'
      break
    elseif count(s:inline_template, syn) != 0
      let type = 'inline_template'
      break
    elseif count(s:inline_expression, syn) != 0
      let type = 'inline_expression'
      break
    elseif count(s:inline_attr, syn) != 0
      let type = 'inline_attr'
      break
    endif
  endfor
  return type
endfunction

function! s:SynsSOL(lnum)
  let lnum = prevnonblank(a:lnum)
  let col = match(getline(lnum), '^\s*\zs') + 1
  return map(synstack(lnum, col), 'synIDattr(v:val, "name")')
endfunction

function! s:SynsEOL(lnum)
  let lnum = prevnonblank(a:lnum)
  let col = strlen(getline(lnum))
  return map(synstack(lnum, col), 'synIDattr(v:val, "name")')
endfunction

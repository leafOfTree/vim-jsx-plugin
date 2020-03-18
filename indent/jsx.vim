"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Settings {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:template = ['jsxTemplate', 'jsxTemplateEmpty']
let s:inline_template = ['jsxInlineTemplate']
let s:inline_expression = ['jsxInlineExpression']
let s:inline_attr = ['jsxAttrExpression']
let s:tag_end = '\v^\s*\/?\>\s*'
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
function! s:Appears(arrs, str)
  return count(arrs, str) > 0
endfunction

function! s:NotAppears(arrs, str)
  return count(arrs, str) == 0
endfunction

function! s:BothAppearsInSyn(appears, prev_syn, cur_syn)
  let both = 0
  for pairs in a:appears
    if pairs[0] == a:prev_syn && pairs[1] == a:cur_syn
      let both = 1
    endif
  endfor
  return both
endfunction

function! GetJsxIndent()
  let prevlnum = prevnonblank(v:lnum - 1)
  let prevline = getline(prevlnum)
  let prevsyns = s:SynsSOL(prevlnum)
  " let prevsyns = s:SynsEOL(prevlnum)

  let curline = getline(v:lnum)
  let cursyns = s:SynsSOL(v:lnum)
  " let cursyns = s:SynsEOL(v:lnum)

  let prev_syn = s:SynType(prevsyns)
  let cur_syn = s:SynType(cursyns)
  call jsx#Log('prev syn: '.prev_syn)
  call jsx#Log('cur syn: '.cur_syn)

  " XML indent
  echom 'check...'
  let is_xml = s:BothAppearsInSyn([
        \['template', 'template'],
        \['inline_attr', 'template'],
        \], prev_syn, cur_syn)
  echom 'is_xml='.is_xml
  " if NotAppears(['default', 'inline_expression', 'inline_attr', 'template'], prev_syn)
        " \ && Appears(['template', 'inline_template'], cur_syn)
    " let is_xml = 1
  " endif
  " if s:Appears(['template'], prev_syn)
        " \ && s:Appears(['template'], cur_syn)
    " let is_xml = 1
  " endif
  " if Appears(['template'], prev_syn)
        " \ && Appears(['inline_expression'], cur_syn)
    " let is_xml = 1
  " endif

  " JavaScript
  " if prev_syn == 'template' && cur_syn == 'inline_attr'
    " let ind = s:GetJavaScriptIndent()
  " endif
  " if prev_syn == 'defualt' || cur_syn == 'default'
    " let ind = s:GetJavaScriptIndent()
  " endif

  if is_xml
    call jsx#Log('---- XML indent ----')
    let ind = s:GetXMLIndent()
    " Align '/>' and '>' with '<' for multiline tags.
    if curline =~? s:tag_end 
      let ind = ind - &sw
    endif
    " Then correct the indentation of any element following '/>' or '>'.
    if prevline =~? s:tag_end
      let ind = ind + &sw
    endif
  else
    " JavaScript indent
    call jsx#Log('---- JavaScript indent ----')
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

" Vim indent file " Language:	  Apex
" Maintainer:	Eric Holmes <eric@ejholmes.net>
" URL:		https://github.com/ejholmes/vim-forcedotcom

if exists("b:did_indent")
    finish
endif

runtime! indent/java.vim

function! s:LineHasOpeningBrackets(lnum)
  let open_0 = 0
  let open_2 = 0
  let open_4 = 0
  let line = getline(a:lnum)
  let pos = match(line, '[][(){}]', 0)
  while pos != -1
    if !s:IsInStringOrComment(a:lnum, pos + 1)
      let idx = stridx('(){}[]', line[pos])
      if idx % 2 == 0
        let open_{idx} = open_{idx} + 1
      else
        let open_{idx - 1} = open_{idx - 1} - 1
      endif
    endif
    let pos = match(line, '[][(){}]', pos + 1)
  endwhile
  return (open_0 > 0) . (open_2 > 0) . (open_4 > 0)
endfunction

function! GetApexIndent()
    let theIndent = GetJavaIndent()
    let lnum = prevnonblank(v:lnum - 1)
    let line = getline(lnum)
    let ind = indent(lnum)
    if line =~ '^\s*@.*$'
        let theIndent = indent(lnum)
    endif

    "If line has brackets and we've already indented
    if line =~'[[({]' && theIndent > ind
        " Make sure none were opened in a string
        let counts = s:LineHasOpeningBrackets(lnum)
        " Check if any bracket type was not found now that we ingore strings
        if counts[0] != '1' && counts[1] != '1' && counts[2] != '1'
            " If none were found, set the indent to the previous indent
            let theIndent = ind
        endif
    endif

    return theIndent
endfunction
setlocal indentexpr=GetApexIndent()

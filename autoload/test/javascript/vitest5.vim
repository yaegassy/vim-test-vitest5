" vim-test runner for Vitest 5+
"
" Vitest 5 matches -t (--testNamePattern) against the test's full name joined
" with ' > ' (e.g. 'math > adds'). Before Vitest 5, the segments were joined
" with a single space, which is what vim-test's built-in vitest runner sends.
" This runner is the same as the built-in one except that :TestNearest joins
" the suite and test names with ' > '.
"
" Based on autoload/test/javascript/vitest.vim from vim-test
" (https://github.com/vim-test/vim-test, MIT License).

if !exists('g:test#javascript#vitest5#file_pattern')
  let g:test#javascript#vitest5#file_pattern = '\v(__tests__/.*|(spec|test))\.(js|jsx|ts|tsx)$'
endif

function! test#javascript#vitest5#test_file(file) abort
  if a:file !~# g:test#javascript#vitest5#file_pattern
    return 0
  endif
  if exists('g:test#javascript#runner')
    return g:test#javascript#runner ==# 'vitest5'
  endif
  return test#javascript#has_import(a:file, 'vitest')
        \ || test#javascript#has_package('vitest')
endfunction

function! test#javascript#vitest5#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '-t '.shellescape(escape(name, '()[]'), 1)
    endif
    return ['run', name, shellescape(a:position['file'])]
  elseif a:type ==# 'file'
    return ['run', shellescape(a:position['file'])]
  else
    return ['run']
  endif
endfunction

let s:yarn_command = '\<yarn\>'
function! test#javascript#vitest5#build_args(args, color) abort
  let args = a:args

  if !a:color
    let args = ['--no-color'] + args
  endif

  if exists('g:test#javascript#vitest5#executable')
    \ && g:test#javascript#vitest5#executable =~# s:yarn_command
    return filter(args, 'v:val != "--"')
  else
    return args
  endif
endfunction

function! test#javascript#vitest5#executable() abort
  if filereadable('node_modules/.bin/vitest')
    return 'node_modules/.bin/vitest'
  elseif executable('npx')
    return 'npx vitest'
  else
    return 'vitest'
  endif
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#javascript#patterns)
  " Vitest 5 joins the suite chain and the test name with ' > '
  return test#base#escape_regex(join(name['namespace'] + name['test'], ' > '))
endfunction

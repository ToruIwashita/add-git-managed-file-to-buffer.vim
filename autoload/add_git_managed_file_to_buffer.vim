" File: autoload/add_git_managed_file_to_buffer.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

fun! s:git_exec(cmd, args) abort
  let results = split(system('\git '.a:cmd.' '.a:args.' 2>/dev/null; echo $?'), "\n")
  let exit_status = remove(results, -1)

  if exit_status
    throw 'failed to '.a:cmd.' command.'
  endif

  return results
endf

fun! s:delete_all_buffers() abort
  for buf_num in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    exec 'silent bdelete' buf_num
  endfor
endf

fun! s:assign_buffers_to_tabs()
  exec 'tab ball'
  tabfirst
  tabc
endf

fun! add_git_managed_file_to_buffer#add_changed_files_to_buffer(bang) abort
  try
    if a:bang
      call s:delete_all_buffers()
    endif

    for changed_file in s:git_exec('diff', '--name-only origin/HEAD...HEAD')
      exec 'silent badd '.changed_file
    endfor

    if a:bang
      call s:assign_buffers_to_tabs()
    endif
  catch /failed to diff/
    redraw!
    echo 'file extraction failed.'
  endtry
endf

let &cpo = s:cpo_save
unlet s:cpo_save

" File: autoload/add_git_managed_file_to_buffer.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! s:git_exec(cmd, args) abort
  let l:results = split(system('\git '.a:cmd.' '.a:args.' 2>/dev/null; echo $?'), "\n")
  let l:exit_status = remove(l:results, -1)

  if l:exit_status
    throw 'failed to '.a:cmd.' command.'
  endif

  return l:results
endf

fun! s:add_any_files_to_buffer(extract_file_funcref) abort
  try
    for l:maneged_file in a:extract_file_funcref()
      exec 'silent badd '.l:maneged_file
    endfor
  catch /failed to diff/
    redraw!
    echo 'file extraction failed.'
  endtry
endf

fun! s:add_any_files_to_tab(extract_file_funcref) abort
  try
    call s:delete_all_buffers()

    for l:maneged_file in a:extract_file_funcref()
      exec 'silent badd '.l:maneged_file
    endfor

    call s:assign_buffers_to_tabs()
  catch /Cannot close last tab page/
    redraw!
  catch /failed to diff/
    redraw!
    echo 'file extraction failed.'
  endtry
endf

fun! s:assign_buffers_to_tabs() abort
  call s:tab_all()
  tabfirst
  tabc
endf

fun! s:delete_all_buffers() abort
  for l:buf_num in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    exec 'silent bdelete' l:buf_num
  endfor
endf

fun! s:tab_all() abort
  let s:current_tpm = &tabpagemax
  set tabpagemax=100
  exec 'tab ball'
  let &tabpagemax = s:current_tpm
endf

fun! s:toplevel_dir_path() abort
  return s:git_exec('rev-parse', '--show-toplevel')[0].'/'
endf

fun! s:changed_files() abort
  return map(s:git_exec('diff', '--name-only origin/HEAD...HEAD'), 's:toplevel_dir_path().v:val')
endf

fun! s:modified_files() abort
  return map(filter(s:git_exec('status', '--short'), "v:val =~# '^ M'"), 'matchstr(v:val, "^ M \\zs\\(.*\\)\\ze", 0)')
endf

fun! s:untracked_files() abort
  return map(filter(s:git_exec('status', '--short'), "v:val =~# '^??'"), 'matchstr(v:val, "^?? \\zs\\(.*\\)\\ze", 0)')
endf

fun! add_git_managed_file_to_buffer#add_changed_files_to_buffer() abort
  call s:add_any_files_to_buffer(funcref('s:changed_files'))
endf

fun! add_git_managed_file_to_buffer#add_modified_files_to_buffer() abort
  call s:add_any_files_to_buffer(funcref('s:modified_files'))
endf

fun! add_git_managed_file_to_buffer#add_untracked_files_to_buffer() abort
  call s:add_any_files_to_buffer(funcref('s:untracked_files'))
endf

fun! add_git_managed_file_to_buffer#add_changed_files_to_tab() abort
  call s:add_any_files_to_tab(funcref('s:changed_files'))
endf

fun! add_git_managed_file_to_buffer#add_modified_files_to_tab() abort
  call s:add_any_files_to_tab(funcref('s:modified_files'))
endf

fun! add_git_managed_file_to_buffer#add_untracked_files_to_tab() abort
  call s:add_any_files_to_tab(funcref('s:untracked_files'))
endf

fun! add_git_managed_file_to_buffer#open_all_buffers_in_tab()
  call s:tab_all()
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save

" File: plugin/add_git_managed_file_to_buffer.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

if exists('g:loaded_add_git_managed_file_to_buffer')
  finish
endif
let g:loaded_add_git_managed_file_to_buffer = 1

let s:cpo_save = &cpo
set cpo&vim

command! -bang AddCToBuffer call add_git_managed_file_to_buffer#add_changed_files_to_buffer(<bang>0)
command! -bang AddMToBuffer call add_git_managed_file_to_buffer#add_modified_files_to_buffer(<bang>0)
command! -bang AddUToBuffer call add_git_managed_file_to_buffer#add_untracked_files_to_buffer(<bang>0)

let &cpo = s:cpo_save
unlet s:cpo_save

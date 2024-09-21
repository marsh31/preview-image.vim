" NAME:   preview-image
" AUTHOR: marsh
" 
" NOTE:
" 
" let g:preview_cmd
" User define g:preview_cmd for image opener.
" {{_image_}} keyword is replaced with the path to the image file.
" example:
"   feh {{_image_}}.
"

if exists('loaded_preview_image')
  finish
endif
let g:loaded_preview_image = 1

command! PreviewImage call preview_image#preview()

" vim:tw=80 ts=2 et sw=2 wrap ff=unix fenc=utf-8 :

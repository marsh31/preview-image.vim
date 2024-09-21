" NAME:   preview_image
" AUTHOR: marsh
"
" NOTE:
" `curl -o https:\/\/xxx.png`
" 

if !exists('s:is_init')
  let s:is_init = v:false
endif

if !exists('s:preview_cmd')
  let s:preview_cmd = ''
endif

if !exists('s:ext_dict')
  let s:ext_dict = {}
endif


function! preview_image#get_ext_dict()
  return s:ext_dict
endfunction

function! preview_image#extend(funcname, priority, ext) abort
  let s:ext_dict[a:funcname] = { "priority": a:priority, "extension": a:ext }
endfunction


function! preview_image#set_priority(funcname, priority)
  if has_key(s:ext_dict, a:funcname)
    let s:ext_dict[a:funcname]["priority"] = a:priority
  else
    echoerr "preview-image: Extension " . string(a:funcname) . " is not registered."
  endif
endfunction


function! preview_image#set_extension(funcname, ext) abort
  if has_key(s:ext_dict, a:funcname)
    let s:ext_dict[a:funcname]["extension"] = a:priority
  else
    echoerr "preview-image: Extension " . string(a:funcname) . " is not registered."
  endif
endfunction


function! preview_image#preview() abort
  if ! s:is_init
    call <SID>init()
  endif

  let file_on_cursor = expand('<cfile>')
  if filereadable(file_on_cursor)
    call <SID>open(file_on_cursor)

  else
    for funcname in <SID>filter_and_sort()
      if <SID>try(funcname)
        return
      endif
    endfor
  endif
endfunction


function! s:init() abort
  let s:preview_cmd = get(g:, 'preview_cmd', 'feh')
endfunction


function! s:open(image_path) abort
  let l:cmd = printf('%s %s', s:preview_cmd, a:image_path)

  if has('nvim')
    let chid = jobstart(l:cmd)
    if chid == 0
      echoerr "invalid arguments"

    elseif chid == -1
      echoerr printf("%s is not executable", l:cmd)
    endif

  else
    let chid = job_start(['/bin/sh', '-c', l:cmd])

    " TODO: fix to use chid
  endif
endfunction


function! s:try(funcname)
  let p = function(a:funcname)()
  if p isnot 0
    call s:open(p.path)
    return !0
  else
    return 0
  endif
endfunction


function! s:filter_and_sort()
  let ft = &filetype
  if ft != ''
    let val = filter(deepcopy(s:ext_dict), printf('v:val["extension"] == "*" || v:val["extension"] == "%s"', ft))
  else
    let val = filter(deepcopy(s:ext_dict), printf('v:val["extension"] == "*" || v:val["extension"] == ""'))
  endif

  return
  \ map(
  \   sort(
  \     map(
  \       keys(val),
  \       '[printf("%06d %s", val[v:val]["priority"], v:val), v:val]'
  \     )
  \   ),
  \   'v:val[1]'
  \ )
endfunction


" vim:tw=80 ts=2 et sw=2 wrap ff=unix fenc=utf-8 :

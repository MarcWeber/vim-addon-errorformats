if !exists('g:vim_addon_errorformats') | let g:vim_addon_errorformats = {} | endif | let s:c = g:vim_addon_errorformats

let s:c.sources = get(s:c, 'sources', {})
let s:c.efms = get(s:c, 'efms', {})
let s:d = s:c.efms

" list of { efm : fun, list: fun }
" efm should return the error format by key
" list should return all kown keys
let s:c.sources['efms_shipping_with_this_plugin'] = {}
let s:c.sources['efms_rtp'] = {}


" API {{{1

" list all known formats
fun! vim_addon_errorformats#KnownFormats()
  let l = []
  for [key, dict] in items(s:c.sources)
    let r = call(dict.list, [], dict)
    call extend(l, r)
    unlet key dict
  endfor
  return l
endf

" return errorformat by name
"
" key can be a list of names, eg 'ocaml_trace, default' or a list
" ['ocaml_trace', 'default']
fun! vim_addon_errorformats#ErrorFormat(keys) abort
  let formats = []
  for key in type(a:keys) == type([]) ? a:keys : split(a:keys, '\s\+')

    let c = 0
    for [k, dict] in items(s:c.sources)
      let r = call(dict.efm, [key], dict)
      if r != ""
        let c += 1
        call add(formats, r)
      endif
      unlet k dict
    endfor

    if c > 1 | echom "warning: multiple error formats found for key ".key | endif
    if c == 0 | throw "no error format found for key: ".key | endif

  endfor
  let r = join(formats, ',')
  return r
endf

" set error format
fun! vim_addon_errorformats#SetErrorFormat(keys) abort
  exec 'set efm='.vim_addon_errorformats#ErrorFormat(a:keys)
endf

" ask user for error formats
fun! vim_addon_errorformats#InputErrorFormat() abort
  return vim_addon_errorformats#ErrorFormat(vim_addon_errorformats#InputErrorFormatNames())
endf



" helpers {{{1
let s:plugin_root = expand('<sfile>:h:h')

" error formats provided by this plugin {{{2
fun s:c.sources.efms_shipping_with_this_plugin.efm(key)
  let file = s:plugin_root.'/efms/'.a:key
  if !file_readable(file) | return "" | endif
  let lines = readfile(file)
  call filter(lines, 'v:val =~ '.string('#EFMCOMMENT'))
  return join(lines,',')
endf
fun s:c.sources.efms_shipping_with_this_plugin.list()
  return map(glob(s:plugin_root.'/efms/*', 0, 1), '"rtp_".fnamemodify(v:val, ":t:r")')
endf


" erorr formats taken from compiler/* files {{{2
" Yes, this is impure and sets errorformat. Fix it if you want.
" You should set efm before each action anyway, see vim-addon-actions which
" does this - because one time you need grep, then you run the compiler.
fun s:c.sources.efms_rtp.efm(key)
  let name = matchstr(a:key, 'rtp_\zs.*')
  for rtp in split(&runtimepath,",")
    let file = rtp.'/compiler/'.name.'.vim'
    if file_readable(file)
      " this may fail .. this is hacky!
      let state = "out"
      let lines = []
      for l in readfile(file)
        if state == "out" && l =~ 'CompilerSet errorformat='
          let state = "in"
        endif
        if state == "in"
          if l =~ '^\s*$' || l[0] !~ '\s'
            let state = "out"
          else
            call add(lines, l)
          endif
        endif
      endfor
      execute substitute(join(lines, "\n"), 'CompilerSet ', 'set', '')
      return &efm
    endif

  endfor
  return ""
endf
fun s:c.sources.efms_rtp.list()
  let r = []
  for rtp in split(&runtimepath,",")
    call extend(r, map(glob(rtp.'/compiler/*.vim', 0, 1), '"rtp_".fnamemodify(v:val, ":t:r")'))
  endfor
  return r
endf



" completion stuff {{{2
fun! vim_addon_errorformats#CommandCompletion(A, L, P) abort
  let s = matchstr(a:A[0:a:P], '\S*$')
  return filter(vim_addon_errorformats#KnownFormats(), 'v:val =~ '.string('^'.s))
endf

fun! vim_addon_errorformats#InputErrorFormatNames() abort
  return input('error format(s):', '', 'customlist,vim_addon_errorformats#CommandCompletion')
endf

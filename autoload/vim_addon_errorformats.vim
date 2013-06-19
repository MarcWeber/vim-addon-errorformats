if !exists('g:vim_addon_errorformats') | let g:vim_addon_errorformats = {} | endif | let s:c = g:vim_addon_errorformats

let s:c.ocaml_trace = get(s:c, 'ocaml_trace', 'Called\ from\ file\ \\\"%f\\\"\\,\ line\ %l\\,\ characters\ %c-%m')

" ocaml simple:
" let s:efm = 'set efm=%+AFile\ \"%f\"\\,\ line\ %l\\,\ characters\ %c-%*\\d:,%Z%m'

" taken from vim-addon-ocaml (I'm not the original author, dates back to 2004,
" see history of that plugin)
let s:c.ocaml_long = get(s:c, 'ocaml_long', 
      \'%EFile\ \"%f\"\\,\ line\ %l\\,\ characters\ %c-%*\\d:,'
      \.'%EFile\ \"%f\"\\,\ line\ %l\\,\ character\ %c:%m,'
      \.'%+EReference\ to\ unbound\ regexp\ name\ %m,'
      \.'%Eocamlyacc:\ e\ -\ line\ %l\ of\ \"%f\"\\,\ %m,'
      \.'%Wocamlyacc:\ w\ -\ %m,'
      \.'%-Zmake%.%#,'
      \.'%C%m,'
      \.'%D%*\\a[%*\\d]:\ Entering\ directory\ `%f'."'".','
      \.'%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f'."'".','
      \.'%D%*\\a:\ Entering\ directory\ `%f'."'".','
      \.'%X%*\\a:\ Leaving\ directory\ `%f'."'".','
      \.'%DMaking\ %*\\a\ in\ %f')

fun! vim_addon_errorformats#ErrorFormat(key) abort
  return s:c[a:key]
endf

fun! vim_addon_errorformats#SetErrorFormat(key) abort
  exec 'set efm='.vim_addon_errorformats#ErrorFormat(a:key)
endf

fun! vim_addon_errorformats#CommandCompletion(A, L, P) abort
  return filter(keys(s:c), 'v:val =~ '.string('^'.a:A))
endf

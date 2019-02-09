command! -bar -nargs=* -complete=customlist,vim_addon_errorformats#CommandCompletion Errorformat :call vim_addon_errorformats#SetErrorFormat([<f-args>])

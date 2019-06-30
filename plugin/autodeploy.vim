"{
"    "autodeploy": {
"        "type" : "sftp",
"        "host" : "68.",
"        "port" : "22",
"        "user" : "root",
"        "pass" : "",
"        "path" : "/home",
"    }
"}

:autocmd BufWritePost * call s:onSaveAutoDeploy()

function s:onSaveAutoDeploy()

    if has('win32') 
        let s:sep = "\\" 
    else 
        let s:sep = "/" 
    endif

    let s:path = split(expand('%:p:h'), s:sep)
    let s:pathToSearch = s:sep
    let s:pathConfig = ""

    for s:part in s:path
        let s:pathToSearch = s:pathToSearch . s:part . s:sep 
        if filereadable(s:pathToSearch . ".one-project")
            let s:pathConfig = s:pathToSearch . ".one-project"
        endif
    endfor

    if s:pathConfig != ""
        let g:array = ""
        let s:lines = readfile(s:pathConfig)
        for s:line in s:lines
            let g:array = g:array . s:line
        endfor
        exec "let g:array =" . substitute(g:array, "\n", "", "")
        
        let s:sftp = g:array['autodeploy']["user"].'@'.g:array['autodeploy']["host"].':'.g:array['autodeploy']["path"]
        exec ":! sftp ".s:sftp" <<< $'put ".expand('%:p')."' & yes"
        
        
        "[sshpass -p "password" ssh username@hostname],
    endif

    ":echo @%
    ":echo expand('%:t')
    ":echo expand('%:p')
    ":echo expand('%:p:h')
    "ftp://lieven@example.com//path//to//file
endfunction

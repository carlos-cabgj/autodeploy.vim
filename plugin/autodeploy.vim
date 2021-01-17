let g:OneIdeVimEspaceRegex       = '~\[|^'

augroup oneenc
    autocmd BufWritePost  * call s:onSaveAutoDeploy('', expand('%:t'))
augroup end

function s:onSaveAutoDeploy(fileFull, fileName)

    let pathSearch = onefunctions#getFileInTree('.one-project')
    let fileName   = a:fileName
    if pathSearch != []

        let config = onefunctions#readConfig(pathSearch[0])

        if config['autodeploy']['status'] == '' || config['autodeploy']['status'] == 0
            return ''
        endif

        if a:fileFull == ''
            let basePathServer   = substitute(expand('%:p:h').g:sep, escape(pathSearch[1], g:OneIdeVimEspaceRegex), "", "g")
            let basePathServer   = substitute(basePathServer, config['autodeploy']["pathLocal"], "", "g")
            let fileServerFull   = basePathServer.expand('%:t')
            let pathLocal  = expand('%:p')
            let fileName = expand('%:t')
        else
            let fileServerFull = substitute(a:fileFull, escape(config['encryption']['pathDecode'], '\'), "", "g")
            let pathLocal  = a:fileFull
        endif

        let pathFileServer = s:convertPathToServer(config['autodeploy']["pathServer"].fileServerFull)
        let pathLocal = s:convertPathToServer(pathLocal)

        let pathFolderServer = substitute(pathFileServer, fileName, '', '')

        if config['autodeploy']['program'] == 'PSCPPLINK'
            call s:uploadWithPscp(config, pathFileServer, pathFolderServer, pathLocal)
        elseif config['autodeploy']['program'] == 'PYTHON3'
            :AsyncRun call s:uploadWithPython3(config, pathFileServer, pathFolderServer, pathLocal)
        else
            :echoerr onefunctions#i18n('deploy.noMethod')
        endif
    endif
endfunction

function! s:uploadWithPscp(config, pathFileServer, pathFolderServer, pathLocal)

    if has_key(a:config['autodeploy'], 'plink') == 0 || a:config['autodeploy']['plink'] == '' || filereadable(a:config['autodeploy']['plink']) == 0
        :echoerr onefunctions#i18n('deploy.plinkNotFound')
        return ''
    endif

    if has_key(a:config['autodeploy'], 'pscp') == 0 || a:config['autodeploy']['pscp'] == '' || filereadable(a:config['autodeploy']['pscp']) == 0
        :echoerr onefunctions#i18n('deploy.pscpNotFound')
        return ''
    endif

    let PSCPsftp   = a:config['autodeploy']["user"].'@'.a:config['autodeploy']["host"].':'.a:pathFileServer
    let PSCPauth   = ' -pw '.a:config['autodeploy']["pass"].' -l '.a:config['autodeploy']["user"]
    let PLINKBegin = a:config['autodeploy']["plink"].' -ssh '.a:config['autodeploy']["user"].'@'.a:config['autodeploy']["host"]
    let PLINKauth  = ' -pw '.a:config['autodeploy']["pass"].' "mkdir -p '.s:convertPathToServer(a:pathFolderServer).'"'

    :silent exec ":AsyncRun ".a:config['autodeploy']["pscp"]." -q -r ".PSCPauth." ".a:pathLocal." ".PSCPsftp
    :silent exec ":AsyncRun ".PLINKBegin.PLINKauth
endfunction

function! s:convertPathToServer(path)
    return substitute(a:path, '\', '/', 'g')
endfunction

function! s:uploadWithPython3(config, pathFileServer, pathFolderServer, pathLocal)
python3 << EOF
import ftplib
import re

ftp = ftplib.FTP(
    vim.eval("a:config['autodeploy']['host']"),
    vim.eval("a:config['autodeploy']['user']"),
    vim.eval("a:config['autodeploy']['pass']")
)

def isDirectoryFtp(dir):
    dir = re.sub('\/$', '', dir);
    filelist = []
    ftp.retrlines('LIST',filelist.append)
    for f in filelist:
        if f.split()[-1] == dir and f.upper().startswith('D'):
            return True
    return False

file = open(vim.eval('a:pathLocal'),'rb')

if isDirectoryFtp(vim.eval('a:pathFolderServer')) is False:
    ftp.mkd(vim.eval('a:pathFolderServer'))

ftp.storbinary('STOR '+vim.eval('a:pathFileServer'), file)

file.close()
ftp.quit()
EOF
endfunction

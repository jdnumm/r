#!/bin/sh

# MIT License

# Copyright (c) 2020
# mono // layereight@blacktre.es

name=$(echo $(pwd) | tr / '_')

function _push {
    ssh $R_SSH_REMOTE "mkdir -p ~/.rremote$(pwd)"
    if [ -f .rignore ]; then
        rsync -azv --delete --exclude-from=.rignore --exclude=.rignore ./ $R_SSH_REMOTE:~/.rremote$(pwd)
    else
        rsync -azv --delete --exclude=.rignore ./ $R_SSH_REMOTE:~/.rremote$(pwd)
    fi
}

function _pull {
    if [ -f .rignore ]; then
        rsync -azv --exclude-from=.rignore $R_SSH_REMOTE:~/.rremote$(pwd)/* $(pwd)
    else
        rsync -azv $R_SSH_REMOTE:~/.rremote$(pwd)/* $(pwd)
    fi
}

function _exit_if_no_remote {
    if [ -z ${R_SSH_REMOTE+x} ]; then
        echo "Environment Variable \$R_SSH_REMOTE is not set."
        exit 1
    fi
}

function _exit_if_no_remote_dir {
        r=$(ssh $R_SSH_REMOTE sh -c "\"if [ -d ~/.rremote$(pwd) ]; then echo 1; else echo 0; fi\"")
        if [ $r -eq 0 ]
        then
            echo project not pushed
            exit 1
        fi
}

function _exit_if_remote_screen {
    r=$(ssh $R_SSH_REMOTE bash -c "\"if pgrep -f $name >/dev/null 2>&1 ; then echo 1; else echo 0; fi\"")
    if [ $r -eq 1 ]
    then
        echo project is already running.
        exit 1
    fi
}

function _exit_if_no_argument {
    if [ $# -eq 0 ]; then
        echo "No arguments supplied"
        exit 1
    fi
}

function _rm_log {
    ssh $R_SSH_REMOTE sh -c "\"if [ -f ~/.rremote/$name.log ]; then rm ~/.rremote/$name.log; fi\""
}

function _rm_remote {
    ssh $R_SSH_REMOTE sh -c "\"if [ -d ~/.rremote$(pwd) ]; then rm -rf ~/.rremote$(pwd); fi\""
}

function _run {
    ssh -t $R_SSH_REMOTE screen -S $name -L -Logfile .rremote/$name.log "sh -c \"cd ~/.rremote$(pwd); $@\""
}

case $1 in
    --install)
        target_file=/usr/local/bin/r
            curl -s https://codeberg.org/mono/r/raw/branch/main/r > $target_file
            chmod +x $target_file
        exit
    ;;
    -d|--destroy)
        _rm_log
        _rm_remote
    ;;
    -l|--log)
        ssh $R_SSH_REMOTE sh -c "\"if [ -f ~/.rremote/$name.log ]; then cat ~/.rremote/$name.log; fi\""
    ;;
    -a|--attach)
        ssh -t $R_SSH_REMOTE "screen -r $name"
    ;;
    -p|--push)
        _push
    ;;
    -f|--fetch)
        _exit_if_no_remote
        _exit_if_no_remote_dir
        _pull
    ;;
    -r|--run)
        shift
        _exit_if_no_argument $@
        _exit_if_no_remote
        _exit_if_no_remote_dir
        _exit_if_remote_screen
        _rm_log
        _run $@
    ;;
    -h|--help)
        echo "A simple wrapper to run local scripts, programs and commands on a remote machine."
        echo ""
        echo "Copy current local directory to remote and run the given command inside a screen session."
        echo ""
        echo "    r \"ls -la; sleep 60\""
        echo ""
        echo "Other options:"
        echo ""
        echo "    r -r|--run \"ls -la\"       : Run command on remote but dont sync files."
        echo "    r -p|--push               : Push local files to remote."
        echo "    r -f|--fetch              : Pull remote files. !!! Can Overwrite local files !!!"
        echo "    r -l|--log                : Display the remote log."
        echo "    r -a|--attach             : Attach the remote screen session if running."
        echo "    r -d|--destroy            : Remove the files on the remote machine."
        echo ""
        echo "To exclude files or folders add them to a .rignore file."
        echo ""
    ;;
    *)
        _exit_if_no_argument $@
        _exit_if_no_remote
        _exit_if_remote_screen
        _rm_log
        _push
        _run $@
    ;;
esac

#!/bin/bash
# // 2024-11-01 Fri 01:33

declare DIR
declare DESTINATION


function help_show_usage() {
cat << EOF
USAGE
    $ rwatch <ssh_alias>:<path_remote_destination_folder>

EXAMPLE
    $ rwatch vul-4:~/srv/http/station.paperdrift
    $ rwatch vul-4:~/srv/http/ww2.inkonpages

FLAGS
    -h    This help.

EOF
exit
}

function do_rsync() {
    # local TIMESTAMP;
    # TIMESTAMP=$(date +%H:%M:%S)
    # echo "☡  Rsync changed: $TIMESTAMP"
    echo "☡  Rsync changed. Syncing..."
    rsync -qzahuP --delete --force --stats --append-verify \
    --exclude-from="$HOME/.gitignore_global" \
    --exclude-from="./.gitignore" \
    --exclude={"*archive*","archv","*copy*","NOTES","TODO","etc/*",".venv/*",".git/*","*xxx","*/__pycache__","*/scss"} \
    ./ \
    "$DESTINATION"

    sleep .3
    tmux send-keys -t .0 "url" enter

    # Not sure why, but doing ./* doesn't seem to delete files in destination; have to do ./; I swear the prior had worked beforee;
    # Exclude --delete-excluded to effectively do an "ignore"; we want to ignore the --excclude files; not sync it at all;

    # rsync -qzahuP --delete --force --stats --append-verify --delete-excluded --exclude={".venv/*",".git/*","*/*xxx","*/__pycache__","*/scss"} --exclude="*xxx" ./* vul-4:~/tmp/ww2
}

function begin_watch() {

    while true; do
        echo "🔥 Watching..."
        inotifywait --exclude ".git" -re modify,create,delete,move,attrib "$DIR" &> /dev/null
          # -r : recursive
          # -e : event types
          # exclude git because just doing git status seems to make file change in .git and trigger inotifywait;
        do_rsync
    done

}

DIR=$(pwd)
DESTINATION="$*"

if [[ -z "$DESTINATION" ]]; then
    echo "Need to provide ssh alias and destination path."
    help_show_usage
fi

echo "$DESTINATION"
echo "Watching source: $DIR"
echo "Rsync destination: $DESTINATION"

begin_watch
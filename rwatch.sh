#!/bin/bash
# // 2024-11-01 Fri 01:33
# // 2025-02-11 Tue 04:17

declare DIR
declare DESTINATION


function help_show_usage() {
cat << EOF
SUMMARY
    Syncs PWD to destination.
    Destination may be a local or remote directory.
    If logging into remote, then using persistent ssh connection, such as ControlMaster, is recommended.

USAGE
    $ rwatch <ssh_alias>:<path_remote_destination_folder>

EXAMPLE
    $ rwatch vul-4:/srv/http/station.paperdrift
    $ rwatch vul-4:/srv/http/ww2.inkonpages

FLAGS
    -h    This help.

EOF
exit
}

# rsync -zahuP --delete --force --stats --append-verify --exclude-from="$HOME/.gitignore_global" --exclude-from="./.gitignore" --exclude={"*archive*","archv","*copy*","NOTES","TODO","etc/*",".venv/*",".git/*","*xxx","*/__pycache__","*/scss"} ./ vul-4:/srv/http/ww2.inkonpages

function do_rsync() {
    # local TIMESTAMP;
    # TIMESTAMP=$(date +%H:%M:%S)

    local GITIGNORE=''
    local GITIGNORE_GLOBAL=''

    # Check if .gitignore (in pwd) and gitignore_globa (in home) exists;
    if [[ -f ./.gitignore ]]; then
        GITIGNORE="./.gitignore"
    fi
    if [[ -f $HOME/.gitignore_global ]]; then
        GITIGNORE_GLOBAL="$HOME/.gitignore_global"
    fi

    # echo "☡  Rsync changed: $TIMESTAMP"
    echo "☡  Rsync changed. Syncing..."
    # rsync -qzahuP --delete --force --stats --append-verify \
    # rsync -vviizahuP --delete --force --stats \   # this gives me very verbose stats
    #--exclude-from="$HOME/.gitignore_global" \
    #--exclude-from="./.gitignore" \
    rsync -zahuP --delete --force \
    --exclude-from="$GITIGNORE_GLOBAL" \
    --exclude-from="$GITIGNORE" \
    --exclude={"*archive*","archv","*copy*","*Copy*","NOTES","TODO","etc/*",".venv/*",".git/*","*xxx","*/__pycache__","*/scss"} \
    ./ \
    "$DESTINATION"

    # sleep .3
    # tmux send-keys -t .0 "url #$TIMESTAMP" enter
      # If you want to reload uwsgi with alias url; and provide timestamp; in pane 0;

    # Not sure why, but doing ./* doesn't seem to delete files in destination; have to do ./; I swear the prior had worked beforee;
    # Exclude --delete-excluded to effectively do an "ignore"; we want to ignore the --excclude files; not sync it at all;

    # rsync -qzahuP --delete --force --stats --append-verify --delete-excluded --exclude={".venv/*",".git/*","*/*xxx","*/__pycache__","*/scss"} --exclude="*xxx" ./* vul-4:~/tmp/ww2
}

function begin_watch() {

    while true; do
        echo "🔥 rwatch Watching..."
        # inotifywait --exclude ".git" -re modify,create,delete,move,attrib "$DIR" &> /dev/null
        inotifywait -q --exclude ".git" -re modify,create,delete,move,attrib "$DIR"
          # -q : quiet; can specify once or twice;
            # This doesn't seem to mute message: "setting up watches. Beware: since -r was given, this may take a while!"
          # -r : recursive
          # -e : event types
          # exclude git because just doing git status seems to make file change in .git and trigger inotifywait;
        do_rsync
    done

}

DIR=$(pwd)
  # The folder being watched is assumed to be pwd; but I should probably make that optional;
DESTINATION="$*"
  # The destination; can be flags too;


if [[ "$DESTINATION" == "-h" ]]; then
    help_show_usage
elif [[ -z "$DESTINATION" ]]; then
    echo "Need to provide destination path."
    echo "Try 'rwatch -h' for help."
    exit
fi
# echo "➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Watching Source: $DIR"
echo "Rsync Destination: $DESTINATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

begin_watch


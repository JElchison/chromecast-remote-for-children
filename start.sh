#!/bin/bash

# don't use -e, since we want to keep all of our sub-jobs running as long as possible, even when encountering a `read` error
set -ufx

# variables
LOG_FILE=/var/log/logkeys.log
CONFIG_JSON=config.json
INPUT_DEV=$(jq -r '.input_dev' $CONFIG_JSON)
CHROMECAST_DEV=$(jq -r '.chromecast_dev' $CONFIG_JSON)

killall_castnow_processes() {
    pkill -f 'node.*castnow'
}

play_youtube() {
    youtube-dl -o - "$1" | castnow --device "$CHROMECAST_DEV" --quiet -
}

play_youtube_playlist_random() {
    youtube-dl --playlist-random -o - "$1" | castnow --device "$CHROMECAST_DEV" --quiet -
}

# start keylogger
sudo logkeys --start --device="$INPUT_DEV"

# when this script is killed, also kill all sub-jobs
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

#
# control functions
#

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<Esc\>\\\" | while read -r; do
        echo ===== Stop =====
        killall_castnow_processes
        castnow --device \"$CHROMECAST_DEV\" --command s --exit
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<Tab\>\\\" | while read -r; do
        echo ===== Next =====
        castnow --device \"$CHROMECAST_DEV\" --command n --exit
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP+\>\\\" | while read -r; do
        echo ===== Volume Up =====
        castnow --device \"$CHROMECAST_DEV\" --command up --volume-step 0.25 --exit
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP-\>\\\" | while read -r; do
        echo ===== Volume Down =====
        castnow --device \"$CHROMECAST_DEV\" --command down --volume-step 0.25 --exit
    done
done" &

#
# numpad mappings
#

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP0\>\\\" | while read -r; do
        echo ===== Playing Polaroid Memories =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=shNP5H13a1M
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP1\>\\\" | while read -r; do
        echo ===== Playing Claymation Christmas =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/playlist?list=PLd6uqVNEu-peflL0eT4lOwVrRnshaod98
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP2\>\\\" | while read -r; do
        echo ===== Playing The Snowman =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=ZE9KpobX9J8
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP3\>\\\" | while read -r; do
        echo ===== Playing Carl the Super Truck =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=JUeru7ioMyk
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP4\>\\\" | while read -r; do
        echo ===== Playing Mister Rogers =====
        killall_castnow_processes
        play_youtube_playlist_random https://www.youtube.com/playlist?list=PLf22vOV7unX-ly5LC98UyZTOSG8ckDqmt
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP5\>\\\" | while read -r; do
        echo ===== Playing Daniel Tiger =====
        killall_castnow_processes
        play_youtube_playlist_random https://www.youtube.com/playlist?list=PLKzJHcOwWn3KWJco0w6gVvhcrhXDb4TFi
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP6\>\\\" | while read -r; do
        echo ===== Playing Thomas and Friends =====
        killall_castnow_processes
        play_youtube_playlist_random https://www.youtube.com/playlist?list=PLI2i4PrLia3gAAYjMaVbAwdt1xrOsUaXS
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP7\>\\\" | while read -r; do
        echo ===== Playing Colored Lullaby =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=Wm15rvkifPc
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP8\>\\\" | while read -r; do
        echo ===== Playing Animal Lullaby =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=IofXhvcafuo
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP9\>\\\" | while read -r; do
        echo ===== Playing White Noise =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=j8L5vrTHhHs
    done
done" &

#
# symbol mappings
#

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP/\>\\\" | while read -r; do
        echo ===== Playing OSU Marching Band =====
        killall_castnow_processes
        play_youtube_playlist_random https://www.youtube.com/playlist?list=PLyXb8EZU88Q-qSxRiLOzTcn1Rer7VMgJa
    done
done" &

sudo bash -c "while :; do
    tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \\\"\<KP*\>\\\" | while read -r; do
        echo ===== Playing Baby Crying =====
        killall_castnow_processes
        play_youtube https://www.youtube.com/watch?v=qS7nqwGt4-I
    done
done" &
# last command here intentionally missing '&'

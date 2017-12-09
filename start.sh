#!/bin/bash

set -ufx

LOG_FILE=/var/log/logkeys.log
CONFIG_JSON=config.json
INPUT_DEV=$(jq -r '.input_dev' $CONFIG_JSON)
CHROMECAST_DEV=$(jq -r '.chromecast_dev' $CONFIG_JSON)

sudo logkeys --start --device="$INPUT_DEV"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<Esc\>\" | while read -r; do echo ===== Stop =====; castnow --device "$CHROMECAST_DEV" --command s --exit; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<Tab\>\" | while read -r; do echo ===== Next =====; castnow --device "$CHROMECAST_DEV" --command n --exit; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP+\>\" | while read -r; do echo ===== Volume Up =====; castnow --device "$CHROMECAST_DEV" --command up --volume-step 0.25 --exit; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP-\>\" | while read -r; do echo ===== Volume Down =====; castnow --device "$CHROMECAST_DEV" --command down --volume-step 0.25 --exit; done) &

(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP1\>\" | while read -r; do echo ===== Playing Polaroid Memories =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/watch?v=shNP5H13a1M | castnow --device "$CHROMECAST_DEV" --quiet -; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP2\>\" | while read -r; do echo ===== Playing OSU Marching Band =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/playlist?list=PLyXb8EZU88Q-qSxRiLOzTcn1Rer7VMgJa | castnow --device "$CHROMECAST_DEV" --quiet -; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP4\>\" | while read -r; do echo ===== Playing Mister Rogers =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/playlist?list=PLf22vOV7unX-ly5LC98UyZTOSG8ckDqmt | castnow --device "$CHROMECAST_DEV" --quiet -; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP5\>\" | while read -r; do echo ===== Playing Daniel Tiger =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/playlist?list=PLKzJHcOwWn3KWJco0w6gVvhcrhXDb4TFi | castnow --device "$CHROMECAST_DEV" --quiet -; done) &
(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP9\>\" | while read -r; do echo ===== Playing Baby Crying =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/watch?v=qS7nqwGt4-I | castnow --device "$CHROMECAST_DEV" --quiet -; done) &

(sudo tail -f -n0 $LOG_FILE | stdbuf -o0 bgrep -b \"\<KP0\>\" | while read -r; do echo ===== Playing White Noise =====; ps ax | grep castnow | grep node | awk '{print $1}' | xargs kill; youtube-dl -o - https://www.youtube.com/watch?v=j8L5vrTHhHs | castnow --device "$CHROMECAST_DEV" --quiet -; done)

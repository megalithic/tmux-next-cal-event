#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cal_event_icon_option_string="@cal_event_icon"
no_cal_icon_event_option_string="@no_cal_event_icon"
cal_option_string="@cal"

cal_event_icon_osx=""
cal_event_icon=""
no_cal_event_icon_osx=""
no_cal_event_icon=""
cal_osx="Calendar"
cal="Calendar"

source $CURRENT_DIR/shared.sh

is_macos() {
  [ $(uname) == "Darwin" ]
}

cal_event_icon_default() {
  if is_macos; then
    echo "$cal_event_icon_osx"
  else
    echo "$cal_event_icon"
  fi
}

no_cal_event_icon_default() {
  if is_macos; then
    echo "$no_cal_event_icon_osx"
  else
    echo "$no_cal_event_icon"
  fi
}

cal_default() {
  if is_macos; then
    echo "$cal_osx"
  else
    echo "$cal"
  fi
}

cal() {
  printf "$(get_tmux_option "$cal_option_string" "$(cal_default)")"
}

cal_event_icon() {
  printf "$(get_tmux_option "$cal_event_icon_option_string" "$(cal_event_icon_default)")"

}

no_cal_event_icon() {
  printf "$(get_tmux_option "$no_cal_event_icon_option_string" "$(no_cal_event_icon_default)")"
}

next_event() {
  event=$(/usr/local/bin/icalBuddy -n -li 1 -npn -nc -b "" -iep "title,datetime" -ps "|=|" -po "datetime,title" -tf "=%H:%M" -df "" -eed eventsToday+)
  event_time=$(echo $event | awk -F "=" '{print substr($2,0,5)}')
  event_title=$(echo $event | awk -F "=" '{print $3}')

  if [[ -z $event ]]
  then
    echo ""
  else
    echo "$event_title @ $event_time"
  fi
}

print_event() {
  if [[ -z $(next_event) ]]
  then
    echo "$(no_cal_event_icon)"
  else
    echo "$(cal_event_icon) $(next_event)"
  fi
}

main() {
  print_event
}
main
exit 0

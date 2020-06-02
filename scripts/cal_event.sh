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

event_from_cal() {
  current_time=$(date +%H:%M)
  next_events=$(icalBuddy -n -npn -nc -b "" -iep "title,datetime" -ps "|=|" -po "datetime,title" \  -tf "=%H:%M" -df "" -eed eventsToday+)
  event=$(echo $next_events | head -n 1)
  event_time=$(echo $event | awk -F "=" '{print substr($2,0,5)}')

  if [[ "$current_time" < "$time" ]]; then
    event_title=$(echo $event | awk -F "=" '{print $3}')
    echo "$event_title @ $event_time"
  else
    echo ""
  fi
}

next_event() {
  next_event=$(/usr/local/bin/icalBuddy -n -li 1 -iep title,datetime -ic 'Calendar,Personal Calendar' -ps '/|/' eventsToday+1 | sed 's/^.*(\\(.*\\)).*uid: \\(.*\\)$/\\1|\\2/' | awk -F "|" '{print substr($1,3,10) "@ " substr($2,10,8)}')

  printf "$next_event"
}

print_event() {
  next_event = $(next_event)

  if [[ -z "$next_event" ]]
  then
    echo "$(no_cal_event_icon)"
  else
    echo "$(cal_event_icon) $next_event"
  fi
}

main() {
  print_event
}
main

#!/usr/bin/env bash

while getopts 4:6::b:c:d:f:hi:l:n:o:r:s:t:v:w:x: opt
do
  case "$opt" in
    4) HOSTADDRESS=$OPTARG ;;
    6) HOSTADDRESS6=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) LONGDATETIME=$OPTARG ;; # required
    f) MAILFROM=$OPTARG ;;
    h) Help ;;
    i) ICINGAWEB2URL=$OPTARG ;;
    l) HOSTNAME=$OPTARG ;; # required
    n) HOSTDISPLAYNAME=$OPTARG ;; # required
    o) HOSTOUTPUT=$OPTARG ;; # required
    r) USEREMAIL=$OPTARG ;; # required
    s) HOSTSTATE=$OPTARG ;; # required
    t) NOTIFICATIONTYPE=$OPTARG ;; # required
    v) VERBOSE=$OPTARG ;;
    w) TELEGRAM_BOT_TOKEN=$OPTARG ;; # required
    x) TELEGRAM_CHAT_ID=$OPTARG ;; # required
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Error ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Error ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Error ;;
  esac
done

if [ -n "$ICINGAWEB2URL" ]; then
    HOSTDISPLAYNAME="<a href=\"$ICINGAWEB2URL/monitoring/host/show?host=$HOSTNAME\">$HOSTDISPLAYNAME</a>"
fi
template=$(cat <<TEMPLATE
<strong>$NOTIFICATIONTYPE</strong> $HOSTDISPLAYNAME is $HOSTSTATE!

<pre>$HOSTOUTPUT</pre>

When: $LONGDATETIME
Host: $HOSTNAME
TEMPLATE
)

## Check whether IPv4 was specified.
if [ -n "$HOSTADDRESS" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE
IPv4:	 $HOSTADDRESS"
fi

## Check whether IPv6 was specified.
if [ -n "$HOSTADDRESS6" ] ; then
  NOTIFICATION_MESSAGE="$NOTIFICATION_MESSAGE
IPv6:	 $HOSTADDRESS6"
fi

## Check whether author and comment was specified.
if [ -n "$NOTIFICATIONCOMMENT" ]; then
    template="$template

Comment by $NOTIFICATIONAUTHORNAME:
  $NOTIFICATIONCOMMENT"
fi

/usr/bin/curl --silent --output /dev/null \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${template}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "disable_web_page_preview=true" \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

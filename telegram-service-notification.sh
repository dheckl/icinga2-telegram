#!/usr/bin/env bash

while getopts 4:6:b:c:d:e:f:hi:l:n:o:r:s:t:u:v:w:x: opt
do
  case "$opt" in
    4) HOSTADDRESS=$OPTARG ;;
    6) HOSTADDRESS6=$OPTARG ;;
    b) NOTIFICATIONAUTHORNAME=$OPTARG ;;
    c) NOTIFICATIONCOMMENT=$OPTARG ;;
    d) LONGDATETIME=$OPTARG ;; # required
    e) SERVICENAME=$OPTARG ;; # required
    f) MAILFROM=$OPTARG ;;
    h) Usage ;;
    i) ICINGAWEB2URL=$OPTARG ;;
    l) HOSTNAME=$OPTARG ;; # required
    n) HOSTDISPLAYNAME=$OPTARG ;; # required
    o) SERVICEOUTPUT=$OPTARG ;; # required
    r) USEREMAIL=$OPTARG ;; # required
    s) SERVICESTATE=$OPTARG ;; # required
    t) NOTIFICATIONTYPE=$OPTARG ;; # required
    u) SERVICEDISPLAYNAME=$OPTARG ;; # required
    v) VERBOSE=$OPTARG ;;
    w) TELEGRAM_BOT_TOKEN=$OPTARG ;; # required
    x) TELEGRAM_CHAT_ID=$OPTARG ;; # required
   \?) echo "ERROR: Invalid option -$OPTARG" >&2
       Usage ;;
    :) echo "Missing option argument for -$OPTARG" >&2
       Usage ;;
    *) echo "Unimplemented option: -$OPTARG" >&2
       Usage ;;
  esac
done

if [ -n "$ICINGAWEB2URL" ]; then
    HOSTDISPLAYNAME="<a href=\"$ICINGAWEB2URL/monitoring/host/show?host=$HOSTNAME\">$HOSTDISPLAYNAME</a>"
    SERVICEDISPLAYNAME="<a href=\"$ICINGAWEB2URL/monitoring/service/show?host=$HOSTNAME&service=$SERVICENAME\">$SERVICEDISPLAYNAME</a>"
fi
template=$(cat <<TEMPLATE
<strong>$NOTIFICATIONTYPE</strong> $SERVICEDISPLAYNAME on $HOSTDISPLAYNAME is $SERVICESTATE

<pre>$SERVICEOUTPUT</pre>

When:    $LONGDATETIME
Service: $SERVICENAME
Host:    $HOSTNAME
TEMPLATE
)

## Check whether IPv4 was specified.
if [ -n "$HOSTADDRESS" ] ; then
  template="$template
IPv4:    $HOSTADDRESS"
fi

## Check whether IPv6 was specified.
if [ -n "$HOSTADDRESS6" ] ; then
  template="$template
IPv6:    $HOSTADDRESS6"
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

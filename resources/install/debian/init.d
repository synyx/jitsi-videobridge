#! /bin/sh
#
# INIT script for Jitsi Videobridge
# Version: 1.0  01-May-2014  yasen@bluejimp.com
#
### BEGIN INIT INFO
# Provides:          jitsi-videobridge
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Jitsi Videobridge
# Description:       WebRTC compatible Selective Forwarding Unit (SFU)
### END INIT INFO

# Include videobridge defaults if available
if [ -f /etc/default/jitsi-videobridge ]; then
    . /etc/default/jitsi-videobridge
fi

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/share/jitsi-videobridge/jvb.sh
NAME=jvb
USER=jvb
PIDFILE=/var/run/jitsi-videobridge.pid
LOGFILE=/var/log/jitsi/jvb.log
DESC=jitsi-videobridge
DAEMON_OPTS=" --host=localhost --domain=$JVB_HOSTNAME --port=$JVB_PORT --secret=$JVB_SECRET"

test -x $DAEMON || exit 0

set -e

stop() {
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
    fi
    echo -n "Stopping $DESC: "
    if [ $PID ]; then
        kill $(ps -o pid --no-headers --ppid $PID)
        rm $PIDFILE
        echo "$NAME stopped."
    elif [ $(ps -C jvb.sh h) ]; then
        kill $(ps -o pid --no-headers --ppid $(pgrep -o jvb.sh))
        rm $PIDFILE
        echo "$NAME stopped."
    else
        echo "$NAME doesn't seem to be running."
    fi
}

start() {
    if [ -f $PIDFILE ]; then
        echo "$DESC seems to be already running, we found pidfile $PIDFILE."
        exit 1
    fi
    echo -n "Starting $DESC: "
    start-stop-daemon --start --quiet --background --chuid $USER --make-pidfile --pidfile $PIDFILE \
        --exec /bin/bash -- -c "exec $DAEMON $DAEMON_OPTS < /dev/null >> $LOGFILE 2>&1"
    echo "$NAME started."
}

reload() {
    echo 'Not yet implemented.'
}

status() {
    echo 'Not yet implemented.'
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  reload)
    reload
    ;;
  status)
    status
    ;;
  *)
    N=/etc/init.d/$NAME
    echo "Usage: $N {start|stop|restart|reload|status}" >&2
    exit 1
    ;;
esac

exit 0

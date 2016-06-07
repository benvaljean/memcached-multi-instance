#! /bin/bash
#
# chkconfig: - 99 45
# description:  The memcached daemon is a network memory cache service.
# processname: memcached
# config: /etc/sysconfig/${MEMCACHEDTYPEFILE}
#
NAME="memcached multi instance creator and manager Benjamin Goodacre git@github.com:benvaljean/memcached-multi-instance.git"
VERSION=0.4.27

USAGE=$(cat <<'EOF'
Symbolic link to this init.d script in the format of memcached.TYPE where type is the name 
of the sharded multi instance. Options are sourced from /etc/sysconfig/memcached.TYPE

 For example:

	$ ln -s memcached-multi-instance.sh memcached.content
	$ ln -s memcached-multi-instance.sh memcached.locks
	$ ln -s memcached-multi-instance.sh memcached.sessions
	$ ls -l memcached*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.content -> memcached-multi-instance.sh*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.locks -> memcached-multi-instance.sh*
	-rwxr-xr-x 1 bgoodacre bgoodacre 2.7K Aug 12 09:59 memcached-multi-instance.sh*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.sessions -> memcached-multi-instance.sh*
EOF
)

# Source function library.
. /etc/rc.d/init.d/functions

critical()
{
  echo "Critical error: $@" 1>&2
  exit 1
}

multi-usage() {
	echo "$NAME"
	echo "$USAGE"
}

BASENAME=$(basename $0) || ( critical Cannot get basename of script ; usage )
[[ $BASENAME == "memcached-multi-instance.sh" ]] && multi-usage

prog="memcached"

DEBUG=0

# Get memcache type from BASENAME - allows us to not need to maintain 3 versions of the init.d script
MEMCACHEDTYPE=$(echo $BASENAME | awk -F. '{print $2}') || critical Cannot ascertain MEMCACHEDTYPE from basename. The format is ${prog}.type
# Declaring a type file for re-use with the lock file, sysconfig and pid file
MEMCACHEDTYPEFILE=${prog}.${MEMCACHEDTYPE}
pidfile=/var/run/${MEMCACHEDTYPEFILE}
LOCKFILE=/var/lock/subsys/${MEMCACHEDTYPEFILE}
SYSCONFIGFILE=/etc/sysconfig/${MEMCACHEDTYPEFILE}

if [[ $DEBUG == 1 ]]
then
	echo BASENAME $BASENAME
	echo MEMCACHEDTYPEFILE ${MEMCACHEDTYPEFILE}
	echo pidfile ${pidfile}
	echo LOCKFILE ${LOCKFILE}
	echo SYSCONFIGFILE ${SYSCONFIGFILE}
fi

[ -f ${SYSCONFIGFILE} ] && . ${SYSCONFIGFILE}

#Establish default vaules
PORT=${PORT:-"11211"}
DAEMONUSER=${DAEMONUSER:-"nobody"}
OPTIONS=${OPTIONS:-"-t 12"}
CACHESIZE=${CACHESIZE:-"64"}
MAXCONN=${MAXCONN:-"1024"}

if [[ $DEBUG == 1 ]]
then
	echo PORT $PORT
	echo DAEMONUSER $DAEMONUSER
	echo OPTIONS $OPTIONS
	echo CACHESIZE $CACHESIZE
	echo MAXCONN $MAXCONN
fi

# Check that networking is up.
if [ "$NETWORKING" = "no" ]
then
    exit 0
fi

RETVAL=0

start () {
    [ -e ${pidfile} ] && critical Pid file ${pidfile} already exists
	[ -e ${LOCKFILE} ] && critical Lock file ${LOCKFILE} already exists
	echo -n $"Starting ${MEMCACHEDTYPEFILE}: "
    touch ${pidfile}
    chown $DAEMONUSER ${pidfile}
    daemon memcached -d -p $PORT -u $DAEMONUSER  -m $CACHESIZE -c $MAXCONN -P $pidfile $OPTIONS
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch ${LOCKFILE}
}
stop () {
    echo -n $"Stopping ${MEMCACHEDTYPEFILE}: "
	killproc -p ${pidfile} $prog
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && rm -f ${LOCKFILE} ${pidfile}
}

restart () {
    stop
    start
}


# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
    stop
    ;;
    status)
    status -p ${pidfile} ${MEMCACHEDTYPEFILE}
    ;;
    restart|reload)
    restart
    ;;
    condrestart)
    [ -f ${LOCKFILE} ] && restart || :
    ;;
    *)
    echo $"Usage: $0 {start|stop|status|restart|reload|condrestart}"
    exit 1
esac

exit $?


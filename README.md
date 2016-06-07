# memcached-multi-instance

Create and operate multiple instances of memcached on the same host

Symbolic link to this init.d script in the format of memcached.TYPE where type is the name 
of the sharded multi instance. Options are sourced from /etc/sysconfig/memcached.TYPE

For example:

	$ ln -s memcached-multi-instance-manager.sh memcached.content
	$ ln -s memcached-multi-instance-manager.sh memcached.locks
	$ ln -s memcached-multi-instance-manager.sh memcached.sessions
	$ ls -l memcached*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.content -> memcached-multi-instance-manager.sh*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.locks -> memcached-multi-instance-manager.sh*
	-rwxr-xr-x 1 bgoodacre bgoodacre 2.7K Aug 12 09:59 memcached-multi-instance-manager.sh*
	lrwxrwxrwx 1 bgoodacre bgoodacre   35 Aug 12 10:02 memcached.sessions -> memcached-multi-instance-manager.sh*


# percona-haproxy

Docker image of HaProxy, configurable via environment variables.

## Environment variables

You can pass the following environment variables:

### PRIMARY_SERVERS

Pass a comma separated list of \<hostname>:\<ip_address>:\<port> for use in the primary section.

##### NOTE: \<port> is optional, defaults to 5432

```
PRIMARY_SERVERS=pg1:10.8.0.20:5432,pg2:10.8.0.21:5432
```
This will render as:

```
listen primary
    bind *:5000
    option httpchk /primary
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1 10.8.0.20:5432 maxconn 100 check port 8008
    server pg2 10.8.0.21:5432 maxconn 100 check port 8008
    server pg3 10.8.0.22:5432 maxconn 100 check port 8008
```

### STANDBY_SERVERS

Pass a comma separated list of <hostname>:<ip_address>:\<port> for use in the secondary section.

##### NOTE: \<port> is optional, defaults to 5432

```
STANDBY_SERVERS=pg1:10.8.0.20:5432,pg2:10.8.0.21:5432
```
This will render as:

```
listen standbys
    balance roundrobin
    bind *:5001
    option httpchk /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server pg1 10.8.0.20:5432 maxconn 100 check port 8008
    server pg2 10.8.0.21:5432 maxconn 100 check port 8008
    server pg3 10.8.0.22:5432 maxconn 100 check port 8008
```

### MAXCONN

Determines the max connections (defaults to 100)

### CHECK_PORT

The port where to check the Patroni status (defaults to 8008)

## Ports

This image exposes the following ports:

#### 5000/TCP

Main writer instance port

#### 5001/TCP

Read only instance port

#### 7000/TCP

Exposes the stats page

#!/bin/bash

output_prefix="server"
default_port="5432"
max_connections="${MAXCONN:-100}"
check_port="8008"

generate_server_block() {
  local input_string="$1"
  local output=""
  local tmpfile=$(mktemp)
  IFS=',' read -ra servers <<< "$input_string"
  for server_info in "${servers[@]}"; do
    IFS=':' read -r hostname ip_address <<< "$server_info"
    echo "    $output_prefix $hostname $ip_address:$default_port maxconn $max_connections check port $check_port" >> "${tmpfile}"
  done
  cat "$tmpfile"
}

if ! [ -f /etc/haproxy/haproxy.cfg ]; then
  export PRIMARY_SERVERS="$(generate_server_block ${PRIMARIES})"
  export STANDBY_SERVERS="$(generate_server_block ${STANDBYS})"

  envsubst < /etc/haproxy/haproxy.cfg.template > /etc/haproxy/haproxy.cfg
fi

exec haproxy -f /etc/haproxy/haproxy.cfg
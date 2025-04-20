#!/bin/bash

output_prefix="server"
max_connections="${MAXCONN:-100}"
check_port="${CHECK_PORT:-8008}"

generate_server_block() {
  local input_string="$1"
  local output=""
  local tmpfile=$(mktemp)
  IFS=',' read -ra servers <<< "$input_string"
  for server_info in "${servers[@]}"; do
    IFS=':' read -r hostname ip_address port <<< "$server_info"
    echo "    $output_prefix $hostname $ip_address:${port:-5432} maxconn $max_connections check port $check_port" >> "${tmpfile}"
  done
  cat "$tmpfile"
}

if ! [ -f /etc/haproxy.cfg ]; then
  export PRIMARIES="$(generate_server_block ${PRIMARY_SERVERS})"
  export STANDBYS="$(generate_server_block ${STANDBY_SERVERS})"

  envsubst < /etc/haproxy/haproxy.cfg.template > /etc/haproxy.cfg
fi

exec haproxy -f /etc/haproxy.cfg
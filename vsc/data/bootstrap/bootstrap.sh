#!/usr/bin/env bash

# atoi: Returns the integer representation of an IP arg, passed in ascii
# dotted-decimal notation (x.x.x.x)
atoi() {
  local IP=$1
  local IPnum=0
  for (( i=0 ; i<4 ; ++i ))
  do
    ((IPnum+=${IP%%.*}*$((256**$((3-${i}))))))
    IP=${IP#*.}
  done
  echo $IPnum
}

# itoa: returns the dotted-decimal ascii form of an IP arg passed in integer
# format
itoa() {
  echo -n $(($(($(($((${1}/256))/256))/256))%256)).
  echo -n $(($(($((${1}/256))/256))%256)).
  echo -n $(($((${1}/256))%256)).
  echo $((${1}%256))
}

source /bootstrap/functions.sh
get_environment

getIP() {

  local_ifaces=($(ip link show | grep -v noop | grep state | grep -v LOOPBACK | awk '{print $2}' | tr -d : | sed 's/@.*$//'))
  local IP MASK
  for iface in "${local_ifaces[@]}"; do
    # Get my IPv4 address (including netmask)
    local IPs=$(ip address show dev $iface | grep inet | awk '/inet / { print $2 }' | cut -f1 -d/)
    IPs=($IPs)

    if ! [[ -z "$SELECTED_NETWORK" ]]; then
      local given_ip given_mask
      IFS=/ read given_ip given_mask <<< $SELECTED_NETWORK
      local given_addr=$(atoi $given_ip)
      local given_cidr=$given_mask
      local given_mask=$((0xffffffff << (32 - $given_mask) & 0xffffffff))
      local given_broadcast=$((given_addr | ~given_mask & 0xffffffff))
      local given_network=$((given_addr & given_mask))

      for configured_ip in "${IPs[@]}"; do
        local configured_ip=$(atoi $configured_ip)
        if [[ $configured_ip -gt $given_network && $configured_ip -lt $given_broadcast ]]; then
          IP=$(itoa $configured_ip)
          CIDR=$given_cidr
          NETWORK=$(itoa $given_network)
        fi
      done
      [[ -z "$IP" ]] && echo "WARNING: SELECTED_NETWORK ($SELECTED_NETWORK) not found in $iface interface."
    else
      IP=${IPs[0]}
    fi
  done
  echo "$IP" "$CIDR" "$NETWORK"
}

read MY_IP MY_CIDR MY_NETWORK < <(getIP)
echo $MY_IP / $MY_CIDR - $MY_NETWORK

export FAKE_GW=$(itoa $( expr "$(atoi $MY_NETWORK)" + 1 ))
echo "FAKE_GW=$FAKE_GW"

# Get the local GW
read _ _ MY_GW _ < <(ip route list match 0/0)

# Get my DNS server. When using K8S this is set at runtime in "/etc/resolv.conf"
read _ MY_DNS  < <(cat /etc/resolv.conf | grep nameserver)

MY_HOSTNAME=`hostname`

export MY_CIDR
export MY_IP
export MY_GW
export MY_DNS
export MY_HOSTNAME
export LIBGUESTFS_BACKEND=direct

guestmount -a /image/image -m /dev/sda1  /mnt
# Fix the VSC config files
fix_configs /bootstrap/*.cfg
cp -f /bootstrap/*.cfg /mnt
### (!!!) The "bof.cfg" _must_ be world-wide executable but "config.cfg" _not_
chmod 0755 /mnt/bof.cfg
chmod 0644 /mnt/config.cfg

guestunmount /mnt

exec /usr/local/bin/startvm "$@" -device virtio-net-pci,netdev=net99,mac=FE:05:00:00:00:00 -netdev tap,id=net99,vhost=on,fd=99 -smbios type=1,product=TIMOS -nographic

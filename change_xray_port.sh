#!/bin/bash

host='192.168.1.1'
nport=10086
user=root

show_help() {
    version
    echo "Usage: $0  command ...[parameters]....
    --help                      Show this help message
    --version, -v               Show version info
    --host, -h                  Set remote host ip
    --port, -p                  Set xray new port to be change
    --user, -u                  Set remote server login user
    --check, -c                 Check xray port status 
    "
}

check_port() {
    echo "nc -zv $host $nport"
    `nc -zv $host $nport`
}

comfirm_to_change() {
    while :; do echo
        read -e -p "Do you want to change $host xray port to $nport ? [y/n]: " chg_flag
        if [[ ! ${chg_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            [ "${chg_flag}" == 'y' ] && change_xray_port
            break
        fi
    done
}

change_xray_port() {
    echo "remote sh on $user@$host "

    ssh -tt $user@$host <<RSH
oport=\$(grep port /usr/local/etc/xray/config.json | sed 's/[^0-9]//g')
echo "the old port is \$oport"

if [[ -z "\$oport" ]]; then
  echo "no old port" 
  exit 
elif [[ "\$oport" = "$nport" ]]; then 
  echo "no change"
  exit 
else
  echo "restart xray" 

  sed -i "s/\$oport/$nport/g" /usr/local/etc/xray/config.json
  firewall-cmd --zone=public --add-port=$nport/tcp
  systemctl restart xray

  echo "the xray port changed from \$oport to $nport" 
  exit
fi
RSH

    echo "done!"
    check_port
}

version() {
    echo "version: 0.3.0"
}

while [ -n "$1" ]
do
    case "$1" in
      -h|--host)
        host=$2
        shift
        ;;
      -p|--port)
        nport=$2
        shift
        ;;
      -u|--user)
        user=$2
        shift
        ;;
      -c|--check)
        check_port; exit 0
        ;;
      --help)
        show_help; exit 0
        ;;
      -v|--version)
        version; exit 0
        ;;
      --)
        shift
        ;;
      *)
        echo "${CWARNING}ERROR: unknown argument! ${CEND}" && show_help && exit 1
        ;;
    esac
shift
done

comfirm_to_change

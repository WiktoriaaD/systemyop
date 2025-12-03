#!/bin/bash


get_cpu() {

    model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
    echo -e "CPU: $model"
}

get_ram() {

    read total used <<< $(free -m | awk '/^Mem:/{print $2, $3}')

    if [ "$total" -gt 0 ]; then
        percent=$(( 100 * used / total ))
    else
        percent=0
    fi
    
    echo -e "RAM: \033[34m$used\033[0m / \033[34m$total\033[0m MiB (\033[31m${percent}%\033[0m used)"
}

get_load() {

    load=$(cut -d " " -f 1-3 /proc/loadavg)
    echo -e "Load: $load"
}

get_uptime() {

    up=$(uptime -p | sed 's/^up //')
    echo -e "Uptime: $up"
}

get_kernel() {
    kernel=$(uname -r)
    echo -e "Kernel: $kernel"
}

get_gpu() {
    gpu=$(lspci | grep -iE "vga|3d" | head -n 1 | cut -d: -f3 | sed 's/^[ \t]*//')

    gpu_colored=$(echo "$gpu" | sed -E 's/([0-9]+)/\\033[34m\1\\033[0m/g')
    echo -e "GPU: $gpu_colored"
}

get_user() {
    echo -e "User: $USER"
}

get_shell() {
    echo -e "Shell: $(basename "$SHELL")"
}

get_processes() {

    count=$(ps -e --no-headers | wc -l)
    echo -e "Processes: \033[34m$count\033[0m"
}

get_threads() {

    count=$(ps -eLf --no-headers | wc -l)
    echo -e "Threads: \033[34m$count\033[0m"
}

get_ip() {

    ips=$(ip -4 -o addr show | awk '{print $4}' | tr '\n' ' ')
    echo -e "IP: $ips"
}

get_dns() {

    dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | head -n 1)
    echo -e "DNS: $dns"
}

get_internet() {

    if timeout 1 ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "Internet: OK"
    else
        echo -e "Internet: Error"
    fi
}


if [ $# -eq 0 ]; then
    get_cpu
    get_ram
    get_load
    get_uptime
    get_kernel
    get_gpu
    get_user
    get_shell
    get_processes
    get_threads
    get_ip
    get_dns
    get_internet
else

    for arg in "$@"; do

        case "${arg,,}" in
            cpu) get_cpu ;;
            ram) get_ram ;;
            load) get_load ;;
            uptime) get_uptime ;;
            kernel) get_kernel ;;
            gpu) get_gpu ;;
            user) get_user ;;
            shell) get_shell ;;
            processes) get_processes ;;
            threads) get_threads ;;
            ip) get_ip ;;
            dns) get_dns ;;
            internet) get_internet ;;

        esac
    done
fi

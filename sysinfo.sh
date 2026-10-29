#!/bin/bash

show_host() {
    echo "Hostname: $(hostname)"
}

show_time() {
    echo "Time: $(uptime -p)"
}

show_memory() {
    local total_kb available_kb

    total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    available_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

    if [[ -z "$total_kb" || -z "$available_kb" ]]; then
        echo "Error: no se pudo obtener la memoria" >&2
        return 1
    fi

    local total=$((total_kb / 1024))
    local available=$((available_kb / 1024))
    local used=$((total - available))

    echo "Memory total: ${total} MiB"
    echo "Memory available: ${available} MiB"
    echo "Memory used (approx.): ${used} MiB"
}

show_network() {
    local interface gateway ip

    interface=$(ip route | awk '/^default/ {print $5; exit}')
    gateway=$(ip route | awk '/^default/ {print $3; exit}')

    if [[ -z "$interface" ]]; then
        echo "Error: no se encontró una ruta predeterminada" >&2
        return 1
    fi

    ip=$(ip -o -4 addr show dev "$interface" |
        awk '{split($4, a, "/"); print a[1]; exit}')

    echo "Interface: $interface"
    echo "Local IPv4: ${ip:-No disponible}"
    echo "Gateway: ${gateway:-No disponible}"
}

case "$1" in
    --host)
        show_host
        ;;
    --time)
        show_time
        ;;
    --memoinfo)
        show_memory
        ;;
    --network)
        show_network
        ;;
    --all)
        show_host
        show_time
        show_memory || exit 1
        show_network
        ;;
    --help|-h)
        echo "Uso: ./sysinfo.sh [ --host | --time | --memoinfo | --network | --all]"
        ;;
    *)
        echo "Argumento inválido. Usá --help para ver las opciones." >&2
        exit 1
        ;;
esac

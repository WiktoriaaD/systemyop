#!/bin/bash

#FUNKCJE DLA KAŻDEJ OPCJI MENU

function top_cpu() {
    echo " Top 5 CPU "
    # ps aux: wyświetla procesy
    # --sort=-%cpu: sortuje malejąco (-) po zużyciu CPU
    # head -n 6: bierze 6 pierwszych linii (1 nagłówek + 5 procesów)
    ps aux --sort=-%cpu | head -n 6
}

function top_mem() {
    echo " Top 5 Memory "

    ps aux --sort=-%mem | head -n 6
}

function show_tree() {
    pstree
}

function show_name_by_pid() {
    read -p "PID: " pid
    # -p: wybierz proces o danym PID
    # -o comm command
    ps -p "$pid" -o comm | tail -n 1
}

function show_pid_by_name() {
    read -p "Name of process: " name
    # pgrep: szuka PID dla podanej nazwy
    # -l: wyświetla też nazwę obok numeru (dla pewności)
    pgrep -l "$name"
}

function kill_pid() {
    read -p "PID: " pid
    kill "$pid" && echo "PID sent to die $pid"
}

function kill_name() {
    read -p "Name of process to kill: " name
    # Najpierw znajdujemy PIDy za pomocą pgrep, potem przekazujemy je do kill
    # $() to podstawienie wyniku komendy
    pids=$(pgrep "$name")
    
    if [ -z "$pids" ]; then
        echo "Nie znaleziono takiego procesu."
    else
        kill $pids && echo "Killed process: $name"
    fi
}



while true; do
    echo -e "\nProcess Control:"
    echo "1) List top 5 processes by CPU usage"
    echo "2) List top 5 processes by memory usage"
    echo "3) Show process tree"
    echo "4) Show process name by PID"
    echo "5) Show process PID(s) by name"
    echo "6) Kill process by PID"
    echo "7) Kill process by name"
    echo "q) Exit"
    echo -e "\n"
    
    read -p "Choice: " choice

    case $choice in
        1) top_cpu ;;
        2) top_mem ;;
        3) show_tree ;;
        4) show_name_by_pid ;;
        5) show_pid_by_name ;;
        6) kill_pid ;;
        7) kill_name ;;
        q) exit 0 ;;
        *) echo "Unknown choice." ;;
    esac
done

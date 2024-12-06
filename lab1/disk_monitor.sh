#!/bin/bash

# Храним PID
MONITOR_FILE="./disk_monitor.pid"
# Через какой промежуток будем запускать снова мониторинг
INTERVAL=60
# Время, когда запустили мониторинг
START_TIMESTAMP="00-00-00"

monitor_disk() {
    while true; do
        # Получаем текущую дату и время
        current_date=$(date +"%Y-%m-%d")
        current_time=$(date +"%Y%m%d_%H%M%S")

        csv_file="inode_monitoring_${current_date}_${START_TIMESTAMP}.csv"

        # Если файла нет, создать и добавить заголовки
        if [ ! -f "$csv_file" ]; then
            echo "Time,Filesystem,Used Space,Available Space,Used Inodes,Free Inodes" > "$csv_file"
        fi

        # Получение информации по дисковому пространству
        df_output=$(df -h | tail -n +2)

        # Получение информации по inode
        inode_output=$(df -i | tail -n +2)

        # Отсеиваем информацию из обоих выводов
        while IFS= read -r disk_line && IFS= read -r inode_line <&3; do
            filesystem=$(echo "$disk_line" | awk '{print $1}')
            used_space=$(echo "$disk_line" | awk '{print $3}')
            avail_space=$(echo "$disk_line" | awk '{print $4}')
            used_inodes=$(echo "$inode_line" | awk '{print $3}')
            avail_inodes=$(echo "$inode_line" | awk '{print $4}')

            # Записываем данные в CSV файл
            echo "$current_time,$filesystem,$used_space,$avail_space,$used_inodes,$avail_inodes" >> "$csv_file"
        done < <(echo "$df_output") 3< <(echo "$inode_output")

        # Ждем интервал перед следующей проверкой
        sleep "$INTERVAL"
    done
}

start_monitoring() {
    # Проверка запущен ли процесс
    if [ -f "$MONITOR_FILE" ] && kill -0 $(cat "$MONITOR_FILE") 2>/dev/null; then
        echo "Мониторинг работает, PID: $(cat "$MONITOR_FILE")"
        exit 1
    fi

    # Запуск мониторинга в фоне
    START_TIMESTAMP=$(date +"%H-%M-%S")
    monitor_disk &
    echo $! > "$MONITOR_FILE"
    echo "Мониторинг запущен, PID: $!"
}

stop_monitoring() {
    # Если файла нет, то не запустились
    if [ ! -f "$MONITOR_FILE" ]; then
        echo "Мониторинг не запущен."
        exit 1
    fi

    # Вытаскиваем pid и останаливаем процесс, если он запущен, иначе обрабатываем ошибку
    PID=$(cat "$MONITOR_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm "$MONITOR_FILE"
        echo "Мониторинг остановлен."
    else
        echo "Процесс с $PID не найден."
    fi
}

status_monitoring() {
    # Проверяем запущены ли мы или нет
    if [ -f "$MONITOR_FILE" ] && kill -0 $(cat "$MONITOR_FILE") 2>/dev/null; then
        echo "Мониторинг запущен, PID: $(cat "$MONITOR_FILE")"
    else
        echo "Мониторинг не запущен."
    fi
}

# Обработчик команд
case "$1" in
    START)
        start_monitoring
        ;;
    STOP)
        stop_monitoring
        ;;
    STATUS)
        status_monitoring
        ;;
    *)
        exit 1
        ;;
esac

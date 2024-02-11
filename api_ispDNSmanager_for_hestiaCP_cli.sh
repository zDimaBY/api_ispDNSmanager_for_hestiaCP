#!/bin/bash

# Встановлюємо значення URL, ім'я користувача та пароль. Приклад змінної URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
USERNAME=""
PASSWORD=""

LOG_FILE="/usr/local/hestia/log/system.log"

v_add_dns_domain_to_DNSmanager() {
    response=$(curl -s -X GET "$URL_DNS_MANAGER?out=json&func=auth&username=$USERNAME&password=$PASSWORD")
    key=$(echo "$response" | jq -r '.doc.auth["$"]')
    if [ -z "$key" ]; then
        echo "Не вдалося отримати ключ. Помилка автентифікації."
        exit 1
    fi
    # Додаємо домен через ключ аутентифікації authinfo
    query=$(curl -X GET "$URL_DNS_MANAGER?auth=$key&out=json&func=domain.edit&plid=0&sok=ok&name=$domen&masterip=$ip_domen&dtype=slave")

    echo "$query"
}

v_add_dns_domain() {
    # Замінюємо одинарні лапки на ніщо за допомогою sed
    line_without_quotes=$(echo "$line" | sed "s/'//g")

    # Розбиваємо рядок на поля, використовуючи пробіл як роздільник
    IFS=' ' read -r -a fields <<<"$line_without_quotes"

    # Перевіряємо, чи в рядку є достатньо полів
    if [ "${#fields[@]}" -ge 4 ]; then
        timestamp="${fields[0]} ${fields[1]}"
        action="${fields[2]}"
        domen="${fields[4]}"
        ip_domen="${fields[5]}"
        parameters="${fields[@]:3}" # Всі інші поля як параметри

        echo "Timestamp: $timestamp"
        echo "Action: $action"
        echo "Domen: $domen"
        echo "IP: $ip_domen"
        echo "Parameters: $parameters"

        case "$action" in
        "v-add-dns-domain")
            v_add_dns_domain_to_DNSmanager
            ;;
        *)
            # Інші випадки
            ;;
        esac
    else
        echo "Недостатньо даних для розпарсення"
    fi
}

tail -n0 -f "$LOG_FILE" | grep --line-buffered -E "v-(delete|add|change)-dns-" | while read -r line; do
    echo "$line"
    echo "Відповідна дія, яку потрібно виконати"

    case "$line" in
    *v-add-dns-domain*)
        echo "Викликано /usr/local/hestia/bin/v-add-dns-domain"
        v_add_dns_domain
        ;;
    *v-add-dns-records*)
        echo "Викликано /usr/local/hestia/bin/v-add-dns-records"

        ;;
    *)
        echo "Не можу визначити викликаний файл"
        ;;
    esac
done

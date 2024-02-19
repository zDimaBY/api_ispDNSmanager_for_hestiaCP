#!/bin/bash

# Встановлюємо значення URL, ім'я користувача та пароль. Приклад змінної URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
USERNAME=""
PASSWORD=""

LOG_FILE="/usr/local/hestia/log/system.log"
key_to_DNSmanager(){
    # Виконуємо запит для аутентифікації та отримання ключа
    response=$(curl -s -X POST -d "out=json&func=auth&username=$USERNAME&password=$PASSWORD" "$URL_DNS_MANAGER")
    key=$(echo "$response" | jq -r '.doc.auth["$"]')
    if [ -z "$key" ]; then
        echo "Не вдалося отримати ключ. Помилка автентифікації."
        exit 1
    fi
}

check_domains_in_DNSmanager(){
    # Перевірка на існування домену
    check_response=$(curl -s -X POST -d "auth=$key&out=json&func=domain&sok=ok" "$URL_DNS_MANAGER")
    domains_in_DNSmanager=$(echo "$check_response" | jq -r '.doc.elem[].name."$"')
    echo -e "$domains_in_DNSmanager"
}

v_add_dns_domain_to_DNSmanager() {
    # Додаємо тестовий домен через ключ аутентифікації authinfo
    query=$(curl -s -X POST -d "auth=$key&out=json&func=domain.edit&name=$domen&masterip=$ip_domen&dtype=master&sok=ok" "$URL_DNS_MANAGER")
    # query=$(curl -s -X POST -d "auth=$key&out=json&func=domain.edit&name=$domen&masterip=$ip_domen&dtype=slave&sok=ok" "$URL_DNS_MANAGER")
    # query=$(curl -X GET "$URL_DNS_MANAGER?auth=$key&domain=zdimaby.pp.ua&record_type=A&out=json&sok=ok")
    echo "$query"
}

v_add_dns_domain() {
    # Замінюємо одинарні лапки на порожні рядки за допомогою sed
    line_without_quotes=$(echo "$line" | sed "s/'//g")

    # Розбиваємо рядок на поля, використовуючи пробіли як роздільник
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
            echo -e "\e[31mcheck\e[0m key-to-DNSmanager"
            key_to_DNSmanager
            echo -e "\e[31mcheck_domains_in_DNSmanager:\e[0m"
            check_domains_in_DNSmanager
            echo -e "\e[31mv-add-dns-domain\e[0m"
            v_add_dns_domain_to_DNSmanager
            ;;
        *)
        echo "$action"
            ;;
        esac
    else
        echo "Недостатньо даних для розпарсення"
    fi
}

domain_edit(){
    query=$(curl -s -X POST -d "auth=$key&out=json&func=domain.edit&name=$domen&masterip=$ip_domen&elid=domain.record&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
}

domain_record_edit(){
    query=$(curl -s -X POST -d "auth=$key&out=json&func=domain.record.edit&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
}

v_add_dns_records() {
    # Замінюємо одинарні лапки на порожні рядки за допомогою sed
    line_without_quotes=$(echo "$line" | sed "s/'//g")

    # Розбиваємо рядок на поля, використовуючи пробіли як роздільник з регулярними виразами
    IFS=$'\n' read -d '' -r -a fields <<< "$(awk -vFPAT="([^ ]+)|('[^']*')|(\"[^\"]*\")" '{for (i=1; i<=NF; i++) print $i}' <<< "$line_without_quotes")"

    # Перевіряємо, чи в рядку є достатньо полів
    if [ "${#fields[@]}" -ge 4 ]; then
        timestamp="${fields[0]} ${fields[1]}"
        action="${fields[2]}"
        domen="${fields[4]}"
        sub_domen="${fields[5]}"
        type="${fields[6]}" # Select a record type. Values and additional parameters may vary based on the record type selected
        value="${fields[7]}"
        parameters="${fields[@]:3}" # Всі інші поля як параметри

        echo "Timestamp: $timestamp"
        echo "Action: $action"
        echo "Domen: $domen"
        echo "Sub domen: $sub_domen"
        echo "Тип запису: $type"
        echo "Запис: $value"
        echo "Parameters: $parameters"

        case "$action" in
        "v-add-dns-record")
        echo -e "\e[31mdomain_edit\e[0m"
        domain_edit
        # echo -e "\e[31mdomain_record_edit\e[0m"
        # domain_record_edit
            ;;
        *)
        echo "$action"
            ;;
        esac
    else
        echo "Недостатньо даних для розпарсення"
    fi
}

tail -n0 -f "$LOG_FILE" | grep --line-buffered -E "v-(delete|add|change)-dns-" | while read -r line; do
    case "$line" in
    *v-add-dns-domain*)
        echo -e "Викликано /usr/local/hestia/bin/v-add-dns-domain\n$line"
        v_add_dns_domain
        ;;
    *v-add-dns-record*)
        echo -e "Викликано /usr/local/hestia/bin/v-add-dns-record\n$line"
        v_add_dns_records
        ;;
    *)
        echo -e "Не можу визначити викликаний метод:\n$line"
        ;;
    esac
done
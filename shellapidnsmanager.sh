#!/bin/bash

# Встановлюємо значення URL, ім'я користувача та пароль. Приклад змінної URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
URL_DNS_MANAGER="https://xx.xxxxxxxx.xxx:1500/dnsmgr"
USERNAME=""
PASSWORD=""

key_to_DNSmanager() {
    # Виконуємо запит для аутентифікації та отримання ключа
    responsekeydnsmanager=$(curl -s -X POST -d "out=json&func=auth&lang=ua&username=$USERNAME&password=$PASSWORD" "$URL_DNS_MANAGER")
    keyauthdnsmanager=$(echo "$responsekeydnsmanager" | jq -r '.doc.auth["$"]') # Ключ сесії зберігається протягом години з часу останнього запиту. Якщо протягом години не було виконано жодних запитів, необхідно заново пройти авторизацію.
    if [ -z "$keyauthdnsmanager" ]; then
        echo "Не вдалося отримати ключ. Помилка автентифікації."
        exit 1
    fi
}

check_domains_in_DNSmanager(){
    # Перевірка на існування домену
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain&sok=ok" "$URL_DNS_MANAGER")
    domains_in_DNSmanager=$(echo "$query" | jq -r '.doc.elem[].name."$"')
    echo -e "$domains_in_DNSmanager"
}

v-add-dnsmanager-domain() { # $1 = "$user" $2 = "$domain" $3 = "$ip" $4 = "$template" $5 = "$ttl" $6 = "$exp" $7 = "$soa" $8 = "$serial" $9 = "$records" $10 = "$dnssec" $11 = "$time" $12 = "$date"
    echo -e "\e[31mcheck_domains_in_DNSmanager:\e[0m"
    check_domains_in_DNSmanager
    echo "Додаємо домен. Аргументи: $@"
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain.edit&name=$2&masterip=$3&dtype=master&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain.record.edit&plid=$2&name=@&rtype=a&ip=$3&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
}

v-add-dnsmanager-record(){ # $1 = "$user" $2 = "$domain" $3 = "$record" $4 = "$rtype" $5 = "$dvalue" $6 = "$priority" $7 = "$id" $8 = "$restart"
    echo "Додаємо записи для домена. Аргументи: $@"
    rtype=$(echo "$4" | tr '[:upper:]' '[:lower:]')
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain.record.edit&plid=$2&name=$3&rtype=$rtype&ip=$5&value=$5&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
}

v-delete-dnsmanager-domain() { # $1 = user, $2 = domain, $3 = restart
    echo "Видаляємо домен. Аргументи: $@"
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain.delete&elid=$2&sok=ok" "$URL_DNS_MANAGER")
    echo "$query"
}

v-delete-dnsmanager-record() { # $1 = user, $2 = domain, $3 = id, $4 = sub_domen
    echo "Видаляємо записи для домен. Аргументи: $@"
    query=$(curl -s -X POST -d "auth=$keyauthdnsmanager&out=json&lang=ua&func=domain.record.delete&plid=$2&name=$4&sok=ok" "$URL_DNS_MANAGER")
}

v-apidnsmanager-domain() {
    echo -e "\e[31mcheck\e[0m key-to-DNSmanager"
    key_to_DNSmanager
    case "$1" in
    v-add-dns-domain)
        shift # Пропускаєм перший аргумент
        v-add-dnsmanager-domain "$@"
        ;;
    v-add-dns-record)
        shift
        v-add-dnsmanager-record "$@"
        ;;
    v-delete-dns-domain)
        shift
        v-delete-dnsmanager-domain "$@"
        ;;
    v-delete-dns-record)
        shift
        v-delete-dnsmanager-record "$@"
        ;;
    *)
        echo "Невідомий аргумент: $1"
        ;;
    esac
}

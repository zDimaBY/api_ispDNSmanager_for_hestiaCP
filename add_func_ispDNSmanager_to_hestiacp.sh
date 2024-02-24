#!/bin/bash
wget -N -O /usr/local/hestia/func/shellapidnsmanager.sh https://raw.githubusercontent.com/zDimaBY/api_ispDNSmanager_for_hestiaCP/main/shellapidnsmanager.sh && chmod 644 /usr/local/hestia/func/shellapidnsmanager.sh

# v-add-dns-domain
file="/usr/local/hestia/bin/v-add-dns-domain"
string1="source \$HESTIA/func/shellapidnsmanager.sh"
string2="# shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh"
string3="v-apidnsmanager-domain"

if grep -qF "$string1" "$file" && grep -qF "$string2" "$file" && grep -qF "$string3" "$file"; then
    echo "Changes were not made /usr/local/hestia/bin/v-add-dns-domain"
else
    sed -i '/Includes/a source $HESTIA/func/shellapidnsmanager.sh' "$file"
    sed -i '/Includes/a # shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh' "$file"
    sed -i '/exit$/i\v-apidnsmanager-domain "v-add-dns-domain" "$user" "$domain" "$ip" "$template" "$ttl" "$exp" "$soa" "$serial" "$records" "$dnssec" "$time" "$date"' "$file"
    echo "add new function in /usr/local/hestia/bin/v-add-dns-domain"
fi

# v-delete-dns-domain
file="/usr/local/hestia/bin/v-delete-dns-domain"
string1="source \$HESTIA/func/shellapidnsmanager.sh"
string2="# shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh"

if grep -qF "$string1" "$file" && grep -qF "$string2" "$file" && grep -qF "$string3" "$file"; then
    echo "Changes were not made /usr/local/hestia/bin/v-delete-dns-domain"
else
    sed -i '/Includes/a source $HESTIA/func/shellapidnsmanager.sh' "$file"
    sed -i '/Includes/a # shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh' "$file"
    sed -i '/exit$/i\v-apidnsmanager-domain "v-delete-dns-domain" "$@"' "$file"
    echo "add new function in /usr/local/hestia/bin/v-delete-dns-domain"
fi

# v-add-dns-record
file="/usr/local/hestia/bin/v-add-dns-record"
string1="source \$HESTIA/func/shellapidnsmanager.sh"
string2="# shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh"

if grep -qF "$string1" "$file" && grep -qF "$string2" "$file" && grep -qF "$string3" "$file"; then
    echo "Changes were not made /usr/local/hestia/bin/v-add-dns-record"
else
    sed -i '/Includes/a source $HESTIA/func/shellapidnsmanager.sh' "$file"
    sed -i '/Includes/a # shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh' "$file"
    sed -i '/exit$/i\v-apidnsmanager-domain "v-add-dns-record" "$@"' "$file"
    echo "add new function in /usr/local/hestia/bin/v-add-dns-record"
fi

# v-delete-dns-record
file="/usr/local/hestia/bin/v-delete-dns-record"
string1="source \$HESTIA/func/shellapidnsmanager.sh"
string2="# shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh"

if grep -qF "$string1" "$file" && grep -qF "$string2" "$file" && grep -qF "$string3" "$file"; then
    echo "Changes were not made /usr/local/hestia/bin/v-delete-dns-record"
else
    sed -i '/Includes/a source $HESTIA/func/shellapidnsmanager.sh' "$file"
    sed -i '/Includes/a # shellcheck source=/usr/local/hestia/func/shellapidnsmanager.sh' "$file"
    sed -i "/# Deleting record/a record_deleting=\$(grep \"ID='\$id'\" \"\$USER_DATA/dns/\$domain.conf\" | awk -F\"'\" '/RECORD/{print \$4}')" "$file"
    sed -i '/exit$/i\v-apidnsmanager-domain "v-apidnsmanager-domain "v-delete-dns-record" "$@" "$record_deleting"' "$file"
    echo "add new function in /usr/local/hestia/bin/v-delete-dns-record"
fi
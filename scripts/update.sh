#!/bin/sh
# pdate geoip lists
mkdir -p /etc/mosdns
wget https://cdn.jsdelivr.net/gh/17mon/china_ip_list@master/china_ip_list.txt -O /etc/mosdns/geoip_cn.txt > /dev/null 2>&1
wget https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/reject-list.txt -O /etc/mosdns/geosite_category-ads-all.txt > /dev/null 2>&1
wget https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/proxy-list.txt -O /etc/mosdns/geosite_geolocation-not-cn.txt > /dev/null 2>&1
wget https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt -O /etc/mosdns/geosite_cn.txt > /dev/null 2>&1
echo "Update geoip lists completed."

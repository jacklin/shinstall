#!/bin/sh
#
if [[ ! -d "/data/docker-compose/ipsec-vpn/" ]]; then
	#create docker-compose dir
	mkdir -p /data/docker-compose/ipsec-vpn/
fi
if [[ ! -f /data/docker-compose/ipsec-vpn/vpn.env ]]; then
	touch /data/docker-compose/ipsec-vpn/vpn.env
fi
if [[ ! -f /data/docker-compose/ipsec-vpn/docker-compose.yml ]]; then
	touch /data/docker-compose/ipsec-vpn/docker-compose.yml
fi
chmod 655 -R /data/docker-compose/ipsec-vpn/*

cat <<EOF > /data/docker-compose/ipsec-vpn/vpn.env
# Note: All the variables to this image are optional.
# See README for more information.
# To use, uncomment and replace with your own values.

# Define IPsec PSK, VPN username and password
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
VPN_IPSEC_PSK=YOUR_IPSEC_PRE_SHARED_KEY
VPN_USER=ljc
VPN_PASSWORD=Game7723...

# Define additional VPN users
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
# - Usernames and passwords must be separated by spaces
VPN_ADDL_USERS=user1 user2
VPN_ADDL_PASSWORDS=Game7723_P Game7723_P

# Use a DNS name for the VPN server
# - The DNS name must be a fully qualified domain name (FQDN)
# VPN_DNS_NAME=vpn.example.com

# Specify a name for the first IKEv2 client
# - Use one word only, no special characters except '-' and '_'
# - The default is 'vpnclient' if not specified
# VPN_CLIENT_NAME=your_client_name

# Use alternative DNS servers
# - By default, clients are set to use Google Public DNS
# - Example below shows Cloudflare's DNS service
# VPN_DNS_SRV1=1.1.1.1
# VPN_DNS_SRV2=1.0.0.1

# Protect IKEv2 client config files using a password
# - By default, no password is required when importing IKEv2 client configuration
# - Uncomment if you want to protect these files using a random password
VPN_PROTECT_CONFIG=yes
EOF
cat <<EOF > /data/docker-compose/ipsec-vpn/docker-compose.yml
version: '3'
services:
  vpn:
    image: hwdsl2/ipsec-vpn-server
    restart: always
    env_file:
      - ./vpn.env
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
    cap_add:
      - NET_ADMIN
    devices:
      - "/dev/ppp:/dev/ppp"
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.accept_redirects=0
      - net.ipv4.conf.all.send_redirects=0
      - net.ipv4.conf.all.rp_filter=0
      - net.ipv4.conf.default.accept_redirects=0
      - net.ipv4.conf.default.send_redirects=0
      - net.ipv4.conf.default.rp_filter=0
      - net.ipv4.conf.eth0.send_redirects=0
      - net.ipv4.conf.eth0.rp_filter=0
    hostname: ipsec-vpn-server
    container_name: ipsec-vpn-server
    volumes:
      - ikev2-vpn-data:/etc/ipsec.d
      - /lib/modules:/lib/modules:ro
volumes:
  ikev2-vpn-data:
EOF

docker-compose up -d 

sleep 3
docker-compose ps

docker-compose logs -f 

echo "Copy the password aboev. "
echo "使用客户端连接上的VPN"
cat  << EOF
Android 安装为例：
将生成的 .sswan 文件安全地传送到你的 Android 设备。
从 Google Play，F-Droid 或 strongSwan 下载网站下载并安装 strongSwan VPN 客户端。
启动 strongSwan VPN 客户端。
单击右上角的 "更多选项" 菜单，然后单击 导入VPN配置。
选择你从服务器传送过来的 .sswan 文件。
注： 要查找 .sswan 文件，单击左上角的抽拉式菜单，然后浏览到你保存文件的目录。
在 "导入VPN配置" 屏幕上，单击 从VPN配置导入证书，并按提示操作。
在 "选择证书" 屏幕上，选择新的客户端证书并单击 选择。
单击 导入。
单击新的 VPN 配置文件以开始连接。
查看更多：https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto-zh.md
EOF
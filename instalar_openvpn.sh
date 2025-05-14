#!/bin/bash

set -e

echo "[+] Atualizando sistema e instalando dependências..."
apt update && apt install openvpn easy-rsa iptables-persistent -y

echo "[+] Criando diretório da CA..."
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

#-----------------------------------------------------------------------------------------------------#
echo "[+] Configurando variáveis de certificado..."
cat > vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "BR"
set_var EASYRSA_REQ_PROVINCE   "SP"
set_var EASYRSA_REQ_CITY       "SaoPaulo"
set_var EASYRSA_REQ_ORG        "MinhaEmpresa"
set_var EASYRSA_REQ_EMAIL      "admin@minhaempresa.com"
set_var EASYRSA_REQ_OU         "TI"
EOF
#-----------------------------------------------------------------------------------------------------#
echo "[+] Inicializando PKI..."
./easyrsa init-pki
echo "[+] Gerando CA..."
echo | ./easyrsa build-ca nopass
echo "[+] Gerando chave e certificado do servidor..."
./easyrsa gen-req server nopass
echo yes | ./easyrsa sign-req server server
echo "[+] Gerando chave e certificado do cliente..."
./easyrsa gen-req cliente1 nopass
echo yes | ./easyrsa sign-req client cliente1
echo "[+] Gerando parâmetros adicionais..."
openvpn --genkey --secret ta.key
./easyrsa gen-dh

echo "[+] Copiando arquivos para /etc/openvpn/..."
cp pki/ca.crt pki/issued/server.crt pki/private/server.key \
   pki/dh.pem ta.key /etc/openvpn/

echo "[+] Criando arquivo de configuração do servidor..."
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA256
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
explicit-exit-notify 1
EOF

echo "[+] Habilitando IP forwarding..."
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

#-----------------------------------------------------------------------------------------------------#

echo "[+] Aplicando regras de NAT com iptables..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

#-----------------------------------------------------------------------------------------------------#

echo "[+] Ativando e iniciando OpenVPN..."
systemctl enable openvpn@server
systemctl start openvpn@server

echo "[+] Preparando diretório do cliente..."
mkdir -p ~/cliente-openvpn
cp pki/ca.crt pki/issued/cliente1.crt pki/private/cliente1.key ta.key ~/cliente-openvpn/

echo "[+] Gerando arquivo cliente1.ovpn..."
IP_SERVER=$(curl -s ifconfig.me) # ou use IP fixo

cat > ~/cliente-openvpn/cliente1.ovpn <<EOF
client
dev tun
proto udp
remote $IP_SERVER 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3

<ca>
$(cat ~/cliente-openvpn/ca.crt)
</ca>

<cert>
$(cat ~/cliente-openvpn/cliente1.crt)
</cert>

<key>
$(cat ~/cliente-openvpn/cliente1.key)
</key>

<tls-auth>
$(cat ~/cliente-openvpn/ta.key)
</tls-auth>
EOF

echo "[+] Tudo pronto!"
echo "=> Pegue os arquivos em ~/cliente-openvpn/"
echo "=> Copie 'cliente1.ovpn' para o Windows e conecte com o OpenVPN GUI."

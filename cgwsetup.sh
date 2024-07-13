#!/bin/bash
#
#   StrongSwan(IPSec) + Quaaga (BGP) Setup Script for EC2 Virtual Router
#   - 2023/02/23
#
#  How to use
#    1. Allocate EIP to EC2 located at public subnet
#    2. Create CGW which is using EIP of EC2 virtual router,
#       and then make S2S VPN tunnel connection between TGW and the CGW
#    3. From the VPN tunnel config, get two of Outside IPs and run this script
#

# CGW(EC2 Instance) Eth0
pCgwEth0Ip=$(hostname -i)
pCgwEip=$(curl -s ifconfig.me)
pCgwCidr="`echo $pCgwEth0Ip | cut -d "." -f 1-2`.0.0/16"

# IPSec Tunnel #1 Info
pTu1CgwOutsideIp=$pCgwEip
pTu1CgwInsideIp=169.254.11.2
pTu1VgwInsideIp=169.254.11.1

# IPSec Tunnel #2 Info
pTu2CgwOutsideIp=$pCgwEip
pTu2CgwInsideIp=169.254.12.2
pTu2VgwInsideIp=169.254.12.1

#BGP ASN and PSK Info
pVgwAsn=64512
pCgwAsn=65016
pTuPsk=strongswan_awsvpn

echo "=============================================================="
echo " Let's begin to set up IPSEC/BGP using StrongSWAN and Quagga  "
echo "--------------------------------------------------------------"
echo "  0. strongswan and quagga has been installed "
echo "----------------------------------------------------------"
echo "  1. IPSec Info - Input VPN Tunnel Outside IP addresses "
read -p "    - Tunnel #1 Outside IP Addr : " pTu1VgwOutsideIp
read -p "    - Tunnel #2 Outside IP Addr : " pTu2VgwOutsideIp
echo "----------------------------------------------------------"
echo "  2. BGP Info -  ASN numbers are set as below"
echo "    - TGW ASN Number (64512-65534) : $pVgwAsn "
echo "    - CGW ASN Number (64512-65534) : $pCgwAsn "
echo "=========================================================="
read -p "  informations above is correct? If yes, please continue (y/N)? " answer2
echo

if [ "${answer2,,}" != "y" ]
then
    exit 100
fi

echo "3. Set IPSEC config on /etc/strongswan/ipsec.conf "

cat <<EOF > /etc/strongswan/ipsec.conf
#
# /etc/strongswan/ipsec.conf
#
conn %default
        # Authentication Method : Pre-Shared Key
        leftauth=psk
        rightauth=psk
        # Encryption Algorithm : aes-128-cbc
        # Authentication Algorithm : sha1
        # Perfect Forward Secrecy : Diffie-Hellman Group 2
        ike=aes128-sha1-modp1024!
        # Lifetime : 28800 seconds
        ikelifetime=28800s
        # Phase 1 Negotiation Mode : main
        aggressive=no
        # Protocol : esp
        # Encryption Algorithm : aes-128-cbc
        # Authentication Algorithm : hmac-sha1-96
        # Perfect Forward Secrecy : Diffie-Hellman Group 2
        esp=aes128-sha1-modp1024!
        # Lifetime : 3600 seconds
        lifetime=3600s
        # Mode : tunnel
        type=tunnel
        # DPD Interval : 10
        dpddelay=10s
        # DPD Retries : 3
        dpdtimeout=30s
        # Tuning Parameters for AWS Virtual Private Gateway:
        keyexchange=ikev1
        rekey=yes
        reauth=no
        dpdaction=restart
        closeaction=restart
        leftsubnet=0.0.0.0/0,::/0
        rightsubnet=0.0.0.0/0,::/0
        leftupdown=/etc/strongswan/ipsec-vti.sh
        installpolicy=yes
        compress=no
        mobike=no
conn TU1
        # Customer Gateway
        left=${pCgwEth0Ip}
        leftid=${pTu1CgwOutsideIp}
        # Virtual Private Gateway
        right=${pTu1VgwOutsideIp}
        rightid=${pTu1VgwOutsideIp}
        auto=start
        mark=100
conn TU2
        # Customer Gateway
        left=${pCgwEth0Ip}
        leftid=${pTu2CgwOutsideIp}
        # Virtual Private Gateway
        right=${pTu2VgwOutsideIp}
        rightid=${pTu2VgwOutsideIp}
        auto=start
        mark=200
EOF


echo "4. Set IPSEC config on /etc/strongswan/ipsec.secrets "

cat <<EOF > /etc/strongswan/ipsec.secrets
#
# /etc/strongswan/ipsec.secrets
#
${pTu1CgwOutsideIp} ${pTu1VgwOutsideIp} : PSK ${pTuPsk}
${pTu2CgwOutsideIp} ${pTu2VgwOutsideIp} : PSK ${pTuPsk}
EOF

echo "5. Set IPSEC tunnel options on /etc/strongswan/ipsec-vti.sh "

cat <<EOF > /etc/strongswan/ipsec-vti.sh
#!/bin/bash

#
# /etc/strongswan/ipsec-vti.sh
#

IP=\$(which ip)
IPTABLES=\$(which iptables)

PLUTO_MARK_OUT_ARR=(\${PLUTO_MARK_OUT//// })
PLUTO_MARK_IN_ARR=(\${PLUTO_MARK_IN//// })

case "\$PLUTO_CONNECTION" in
        TU1)
        VTI_INTERFACE=vti1
        VTI_LOCALADDR=${pTu1CgwInsideIp}/30
        VTI_REMOTEADDR=${pTu1VgwInsideIp}/30
        ;;
        TU2)
        VTI_INTERFACE=vti2
        VTI_LOCALADDR=${pTu2CgwInsideIp}/30
        VTI_REMOTEADDR=${pTu2VgwInsideIp}/30
        ;;
esac

case "\${PLUTO_VERB}" in
        up-client)
        #\$IP tunnel add \${VTI_INTERFACE} mode vti local \${PLUTO_ME} remote \${PLUTO_PEER} okey \${PLUTO_MARK_OUT_ARR[0]} ikey \${PLUTO_MARK_IN_ARR[0]}
        \$IP link add \${VTI_INTERFACE} type vti local \${PLUTO_ME} remote \${PLUTO_PEER} okey \${PLUTO_MARK_OUT_ARR[0]} ikey \${PLUTO_MARK_IN_ARR[0]}
        sysctl -w net.ipv4.conf.\${VTI_INTERFACE}.disable_policy=1
        sysctl -w net.ipv4.conf.\${VTI_INTERFACE}.rp_filter=2 || sysctl -w net.ipv4.conf.\${VTI_INTERFACE}.rp_filter=0
        \$IP addr add \${VTI_LOCALADDR} remote \${VTI_REMOTEADDR} dev \${VTI_INTERFACE}
        \$IP link set \${VTI_INTERFACE} up mtu 1436
        \$IPTABLES -t mangle -I FORWARD -o \${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        \$IPTABLES -t mangle -I INPUT -p esp -s \${PLUTO_PEER} -d \${PLUTO_ME} -j MARK --set-xmark \${PLUTO_MARK_IN}
        \$IP route flush table 220
        #/etc/init.d/bgpd reload || /etc/init.d/quagga force-reload bgpd
        ;;
        down-client)
        #\$IP tunnel del \${VTI_INTERFACE}
        \$IP link del \${VTI_INTERFACE}
        \$IPTABLES -t mangle -D FORWARD -o \${VTI_INTERFACE} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        \$IPTABLES -t mangle -D INPUT -p esp -s \${PLUTO_PEER} -d \${PLUTO_ME} -j MARK --set-xmark \${PLUTO_MARK_IN}
        ;;
esac

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.eth0.disable_xfrm=1
sysctl -w net.ipv4.conf.eth0.disable_policy=1
# Disable IPv4 ICMP Redirect
sysctl -w net.ipv4.conf.eth0.accept_redirects=0
sysctl -w net.ipv4.conf.eth0.send_redirects=0
EOF

sudo chmod +x /etc/strongswan/ipsec-vti.sh


echo "6. Set BGP setting using Quagga /etc/quagga/bgpd.conf "

cat <<EOF > /etc/quagga/bgpd.conf
#
# /etc/quagga/bgpd.conf
#
router bgp ${pCgwAsn}
bgp router-id ${pTu1CgwInsideIp}
neighbor ${pTu1VgwInsideIp} remote-as ${pVgwAsn}
neighbor ${pTu2VgwInsideIp} remote-as ${pVgwAsn}
network ${pCgwCidr}
EOF

echo "7. Start StrongSWAN and Quagga BGP "

sudo systemctl enable --now strongswan

sudo systemctl start zebra
sudo systemctl enable zebra
sudo systemctl start bgpd
sudo systemctl enable bgpd
sudo chmod -R 777 /etc/quagga/


sudo strongswan restart


echo "=========================================================="
echo " Using below command, verify IPSec Tunnel and BGP Routing tables"
echo " -. IPsec status    : sudo strongswan statusall  "
echo " -. Routing tables : sudo ip route  "
echo " -. BGP detail config : Enter teminal mode > sudo vtysh and then > show ip bgp "
echo "=========================================================="

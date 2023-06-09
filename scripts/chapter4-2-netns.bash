#!/bin/bash

#!/bin/bash

# rootユーザーが必要
if [ $UID -ne 0 ]; then
  echo "Root privileges are required"
  exit 1;
fi

# 全てのnetnsを削除
ip -all netns delete

# 4つのnetnsを作成
ip netns add host1
ip netns add router1
ip netns add router2
ip netns add host2

# リンクの作成
ip link add name host1-router1 type veth peer name router1-host1 # host1とrouter1のリンク
ip link add name router1-router2 type veth peer name router2-router1 # router1とrouter2のリンク
ip link add name router2-host2 type veth peer name host2-router2 # router2とhost2のリンク
ip link add name router1-router3 type veth peer name router3-router1 # router1とrouter3のリンク

# リンクの割り当て
ip link set host1-router1 netns host1
ip link set router1-host1 netns router1
ip link set router1-router2 netns router1
ip link set router2-router1 netns router2
ip link set router2-host2 netns router2
ip link set host2-router2 netns host2
ip link set router1-router3 netns router1

# host1のリンクの設定
ip netns exec host1 ip addr add 192.168.1.2/24 dev host1-router1
ip netns exec host1 ip link set host1-router1 up
ip netns exec host1 ethtool -K host1-router1 rx off tx off
ip netns exec host1 ip route add default via 192.168.1.1

# router1のリンクの設定
ip netns exec router1 ip link set router1-host1 up
ip netns exec router1 ethtool -K router1-host1 rx off tx off
ip netns exec router1 ip link set router1-router2 up
ip netns exec router1 ethtool -K router1-router2 rx off tx off
ip netns exec router1 ip link set router1-router3 up
ip netns exec router1 ethtool -K router1-router3 rx off tx off
# router1のipv4フォワードを無効にする
ip netns exec router1 sysctl -w net.ipv4.ip_forward=0

# goでip設定するのが面倒くさいので追加
ip netns exec router1 ip addr add 192.168.1.1/24 dev router1-host1
ip netns exec router1 ip link set router1-host1 up
ip netns exec router1 ethtool -K router1-host1 rx off tx off
ip netns exec router1 ip addr add 192.168.0.1/24 dev router1-router2
ip netns exec router1 ip link set router1-router2 up
ip netns exec router1 ethtool -K router1-router2 rx off tx off
ip netns exec router1 ip addr add 192.168.3.1/24 dev router1-router3
ip netns exec router1 ip link set router1-router3 up
ip netns exec router1 ethtool -K router1-router3 rx off tx off


# router2のリンクの設定
ip netns exec router2 ip addr add 192.168.0.2/24 dev router2-router1
ip netns exec router2 ip link set router2-router1 up
ip netns exec router2 ethtool -K router2-router1 rx off tx off
ip netns exec router2 ip route add default via 192.168.0.1
ip netns exec router2 ip addr add 192.168.2.1/24 dev router2-host2
ip netns exec router2 ip link set router2-host2 up
ip netns exec router2 ethtool -K router2-host2 rx off tx off
ip netns exec router2 sysctl -w net.ipv4.ip_forward=1

# host2のリンクの設定
ip netns exec host2 ip addr add 192.168.2.2/24 dev host2-router2
ip netns exec host2 ip link set host2-router2 up
ip netns exec host2 ethtool -K host2-router2 rx off tx off
ip netns exec host2 ip route add default via 192.168.2.1

# 追加の設定

# netnsの作成
ip netns add router3
ip netns add host3

# リンクの作成
#ip link add name router1-router3 type veth peer name router3-router1 # router1とrouter3のリンク
ip link add name router3-host3 type veth peer name host3-router3 # router1とrouter2のリンク

# リンクの割り当て
#ip link set router1-router3 netns router1
ip link set router3-router1 netns router3
ip link set router3-host3 netns router3
ip link set host3-router3 netns host3

# router1のリンクの設定(自作プログラムを動かすためIPアドレスなどは設定しない)
#ip netns exec router1 ip link set router1-router3 up
#ip netns exec router1 ethtool -K router1-router3 rx off tx off

# router3のリンクの設定
ip netns exec router3 ip addr add 192.168.3.2/24 dev router3-router1
ip netns exec router3 ip link set router3-router1 up
ip netns exec router3 ethtool -K router3-router1 rx off tx off
ip netns exec router3 ip route add default via 192.168.3.1
ip netns exec router3 ip addr add 192.168.4.1/24 dev router3-host3
ip netns exec router3 ip link set router3-host3 up
ip netns exec router3 ethtool -K router3-host3 rx off tx off
ip netns exec router3 sysctl -w net.ipv4.ip_forward=1

# host3のリンクの設定
ip netns exec host3 ip addr add 192.168.4.2/24 dev host3-router3
ip netns exec host3 ip link set host3-router3 up
ip netns exec host3 ethtool -K host3-router3 rx off tx off
ip netns exec host3 ip route add default via 192.168.4.1

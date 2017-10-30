from scapy.all import *

p = Ether(src="aa:bb:cc:dd:ee:ff") / IP(dst="10.0.1.10") / TCP() / "aaaaaaaaaaaaaaaa"
sendp(p, iface = "veth1", verbose = 0)

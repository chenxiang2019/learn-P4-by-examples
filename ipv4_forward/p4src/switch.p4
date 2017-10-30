// example: l3 forwarding 

// TODO List:
//
// * Header: Add ethernet header
//
// * Parser: Add IPv4 state transition
// 
// * Table: Add the statements of "match" in table l3_forward
// 
// * Control Flow: Add validation statement of IPv4 header

/* Definitions */

#define ETHERTYPE_IPV4         0x0800
#define ETHERTYPE_IPV6         0x86dd
#define ETHERTYPE_ARP          0x0806

#define IP_PROTOCOLS_ICMP              1
#define IP_PROTOCOLS_IPV4              4
#define IP_PROTOCOLS_TCP               6
#define IP_PROTOCOLS_UDP               17

/* header */

header_type ethernet_t {
    fields {
        // TODO: Add 48bits "srcAddr", 48bits "dstAddr", and 16bits "etherType"
    }
}

header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        diffserv : 8;
        totalLen : 16;
        identification : 16;
        flags : 3;
        fragOffset : 13;
        ttl : 8;
        protocol : 8;
        hdrChecksum : 16;
        srcAddr : 32;
        dstAddr: 32;
    }
}

header_type icmp_t {
    fields {
        typeCode : 16;
        hdrChecksum : 16;
    }
}

header_type tcp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        seqNo : 32;
        ackNo : 32;
        dataOffset : 4;
        res : 4;
        flags : 8;
        window : 16;
        checksum : 16;
        urgentPtr : 16;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}

/* parser */

parser start {
    return parse_ethernet;
}

header ethernet_t ethernet;

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        // TODO: IPv4 state transition
        default: ingress;
    }
}

header ipv4_t ipv4;

parser parse_ipv4 {
    extract(ipv4);
    return select(latest.fragOffset, latest.ihl, latest.protocol) {
        IP_PROTOCOLS_IPHL_ICMP : parse_icmp;
        IP_PROTOCOLS_IPHL_TCP : parse_tcp;
        IP_PROTOCOLS_IPHL_UDP : parse_udp;
        default: ingress;
    }
}

header icmp_t icmp;

parser parse_icmp {
    extract(icmp);
    return select(latest.typeCode) { 
        default: ingress;
    }
} 

header tcp_t tcp;

parser parse_tcp {
    extract(tcp);
    return select(latest.dstPort) { 
        default: ingress;
    }
}

header udp_t udp;

parser parse_udp {
    extract(udp);
    return select(latest.dstPort) { 
        default: ingress;
    }
}

/* actions */

action _drop() {
	drop();
}

action _nop() {
}

action forward(port) {
	modify_field(standard_metadata.egress_spec, port);
}

/* tables */

table l3_forward {
	reads { 
		// TODO: Using longest prefix match to read source IP
	}
	actions {
		_nop; forward;
	}	
}

/* control flows */

control ingress {
    // TODO: judge if the ipv4 header is valid or not
	apply(l3_forward);
}

control egress {
}

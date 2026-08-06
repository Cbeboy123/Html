## 3.2 - Local Networks {#chapter-03-02}

Before an IP packet reaches a router, a host must deliver a frame to the next
hop on its local link.

A **switch** forwards link-layer frames using learned addresses. A router
forwards IP packets between networks. A host compares the destination with its
local routes: a local destination is reached directly; a remote destination is
sent to a gateway.

For IPv4, **ARP** maps a local IPv4 address to a link-layer address. IPv6 uses
Neighbor Discovery, carried through ICMPv6, for related functions. These
mechanisms are local-link protocols and are not general Internet directories.

**DHCP** supplies configuration such as an address, prefix, gateway, and DNS
resolver information. Exact options and lease behavior vary. DHCP does not
prove that the assigned route or DNS service is reachable.

Local-network failures include duplicate addresses, stale neighbor entries,
wrong VLAN membership, incorrect prefixes, and asymmetric security policy.
Packet capture should be taken at the boundary relevant to the hypothesis: an
application capture cannot show a frame dropped before reaching the host.

Broadcast and multicast traffic have bounded domains. Network segmentation
limits failure and trust scope, but adds routing and policy boundaries.

::: {.gotcha}
**Gotcha**

ARP does not find a remote server’s hardware address. The host resolves the
link-layer address of the next hop—often its gateway.
:::

::: {.interview-tip}
**Interview Tip**

Walk through the routing decision before ARP/Neighbor Discovery. That prevents
the common error of resolving the final remote host on the local link.
:::

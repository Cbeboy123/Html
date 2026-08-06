## 3.3 - IP Addressing and Routing {#chapter-03-03}

An IP address identifies an interface in a routing context, not a permanent
machine identity. Hosts can have several interfaces and addresses; addresses
can move or change.

**CIDR** writes an address prefix with its prefix length. The prefix identifies
the shared leading bits used for route aggregation and subnet reasoning. A
router commonly uses **longest-prefix match**: among matching routes, choose the
most specific prefix, then apply product-specific policy among equivalent
candidates.

~~~mermaid
flowchart LR
    host([Source host]) --> r1[Router: longest-prefix lookup]
    r1 -->|selected next hop| r2[Next router]
    r2 --> destination([Destination network])
    r1 --x|no route or policy deny| drop{Drop}
~~~

*Diagram key: rounded boxes are endpoint networks; rectangles route; diamond is
a terminal condition; solid arrows forward; cross-ended arrow is a failed path.*

IPv4 address scarcity led to widespread **NAT**, which rewrites addressing
information at a boundary. NAT is not a firewall by definition, though devices
often combine both. IPv6 provides a much larger address space and removes the
technical need for address-conservation NAT, but security policy remains
necessary.

**ICMP** carries control and diagnostic messages, including error reporting.
Blocking all ICMP can break diagnostics and mechanisms such as path size
discovery. Filtering should distinguish message types and threat model.

Routing can be asymmetric: forward and return paths need not match. Stateful
firewalls, NAT, and troubleshooting assumptions must account for this.

::: {.interview-tip}
**Interview Tip**

Given a destination, apply the routing table’s longest matching prefix and name
the next hop. Do not decide “same subnet” from visual similarity of addresses.
:::

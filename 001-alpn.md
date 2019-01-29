# Automatic DC protocol negotiation

## Rationale

Since the beginning, many developers noted flaws and mistakes made by the authors of NMDC protocol.
However, ADC protocol that was introduced to fix NMDC issues failed to replace it. After many years
DC network is still dominated by NMDC hubs, while most clients support both NMDC and ADC protocols.

One of the possible reasons for hubs to continue using NMDC may be the fact that protocol
handshakes are incompatible, and it was not possible for a hub to upgrade the protocol
without breaking existing users.

Some hubs developed workarounds to support both protocols (see Flexhub). Still, those
workarounds were not widely deployed.

This lead to a situation when the DC network protocol becomes effectively frozen and it's
nearly impossible to improve the base protocol.

To solve this issue, another mechanism based on ALPN is proposed, as well as an old automatic
protocol detection approach is clarified.

## ALPN

Since HTTP2 was introduced, all major browsers required TLS (HTTPS) support to enable the new protocol.
To minimize handshakes that are necessary to agree on using this new protocol on a specific
connection, the protocol negotiation process was built into the TLS. This mechanism is called
Application-Layer Protocol Negotiation (ALPN).

The negotiation begins when the client sends `ClientHello` TLS message with a list of
supported protocols for ALPN.
The server picks a preferred protocol and sends it back with a `ServerHello`. If the TLS
handshake is successful, application can start using the selected protocol over established
TLS connection without further negotiation.

For the full specification, see https://tools.ietf.org/html/rfc7301

## Proposal

The proposed solution is to implement DC protocol negotiation at the TLS level by using ALPN.
However, this negotiation applies only to TLS connections.

The second part of the proposal describes how to automatically detect NMDC/ADC/TLS protocols
for incoming connections. It should be implemented by hubs to ensure seamless migration from
unencrypted NMDC/ADC connections to NMDC/ADC over TLS to enable ALPN.

### NMDC

#### Client-to-Hub

NMDC protocol defines no standard URI scheme for signalling a TLS support on the connection,
and has no support for negotiating TLS for client-hub connection during `$Support` handshake.

The proposal is to reuse `adcs://` URI scheme for establishing a secure NMDC connection to a hub,
if the hub supports it.

The client should add at least `nmdc` name to ALPN's list of supported protocols. Client
is also allowed to include any other supported protocol to the ALPN list, for example `adc`.
The list should be in an order from the most preferred protocol to the least preferred one.

If the server does not support ALPN, TLS+ADC (ADCS) protocol should be assumed, according
to `adcs://` URI scheme.

If the server supports ALPN, and TLS handshake is successful, NMDC protocol handshake begins
over an established TLS connection as usual.

The client should always add `TLS` extension to `$Support` and set both 5th and 6th bits in
`$MyINFO`'s flag when connecting over TLS. If any of those conditions are not met, hub should
close the connection.

#### Client-to-Client

NMDC's `TLS` extensions allows adding `S` suffix to a peer address to initiate a secure
client-client connection.

The client should add at least `nmdc` name to ALPN's list of supported protocols. Client
is also allowed to include any other supported protocol to the ALPN list, for example `adc`.
The list should be in an order from the most preferred protocol to the least preferred one.

If peer does not support ALPN, TLS+NMDC protocol should be assumed.

If TLS handshake is successful and ALPN negotation selects `nmdc`, the NMDC protocol handshake
begins over established TLS connection as usual.

Clients should not signal `TLS` support in `$Supports` after negotiating NMDC protocol
using ALPN, since it already requires a TLS connection. 

### ADC

#### Client-to-Hub

ADC protocol supports establishing TLS connection to a hub by specifying a `adcs://` URL scheme.

The client should add at least `adc` name to ALPN's list of supported protocols. Client
is also allowed to include any other supported protocol to the ALPN list, for example `nmdc`.
The list should be in an order from the most preferred protocol to the least preferred one.

If a hub does not support ALPN, TLS+ADC (ADCS) protocol should be assumed, according to the
`adcs://` URI scheme.

If TLS handshake is successful, ADC protocol handshake begins over an established TLS
connection as usual.

#### Client-to-Client

ADC clients should set `ADCS/0.10` as a protocol for `CTM` and `RCM` commands.

When establishing a client-client connection, at least `adc` name should be added to ALPN's
list of supported protocols. Clients are also allowed to include any other supported protocol
to the ALPN list, for example `nmdc`. The list should be in an order from the most preferred
protocol to the least preferred one.

In both cases of a peer supporting ALPN and negotiating `adc` and not supporting ALPN the
client should proceed to a usual ADC handshake over an established TLS connection.

### Detecting the DC protocol for incoming connections

To propose a way to migrate existing hubs that don't use TLS yet, this section describes an
approach that should be used by hubs to automatically detect a DC protocol for incoming
connections.

First, the hub sets a read deadline on the connection to 2x of a maximal expected RTT
(round trip time). Assuming a maximal RTT of 250ms, a deadline of 500ms should be used.
This number is a sensible default for generic use case.

The hub then tries to read at least 4 bytes from the connection.

If the deadline of 2x RTT is reached, the hub should assume NMDC protocol. It should increase
the read deadline for this connection and send `$Lock` as usual. It may also drop the connection
if NMDC is not supported.

If received 4 bytes match the `HSUP` sequence, the hub should assume ADC protocol. It should
increase the read deadline on this connection, keep `HSUP` on the read buffer and proceed
with ADC handshake. It may also drop the connection if ADC is not supported.

If the first two received bytes match `0x16 0x03` sequence, the hub should assume TLS.
It should increase the read deadline, keep 4 bytes on the read buffer and proceed with
TLS handshake, setting an appropriate list of supported protocols for ALPN.

If TLS is detected, but ALPN negotiation fails, hub may still use an approach described above
for an established TLS connection and detect NMDC or ADC protocol on it. Implementations
should not allow running TLS over TLS.

#### Internet Relay Chat (IRC)

An approach above can be also used to detect other protocols like IRC, if supported by the hub.
For this case, an expected 4 byte sequence is `NICK` that corresponds to an IRC handshake.

### HTTPS support for pingers

The hub supporting ALPN may also set a `h2` protocol to the ALPN's list of supported protocols.

If `h2` protocol is negotiated during TLS handshake, the hub must switch to HTTP2 protocol
for this connection and be able serve at least the following HTTP request:

```
GET /api/v0/hubinfo.json
accept: application/json
user-agent: PingerX/1.0
```

`user-agent` header must be set and include the name and the version of a pinger software.

The response must be a valid JSON document containing hub information and live statistics.

```
content-type: application/json
server: NewHub/1.0
```

`server` header must be set and include the name and the version of a hub software.

```json
{
    "name": "Hub name",
    "desc": "Hub description",
    "addr": [
        "some.hub.net:411",
        "fallback.hub.net:411"
    ],
    "icon": "/relative/img/path/favicon.png",
    "website": "https://www.hub.net",
    "email": "webmaster@hub.net",
    "users": 1000,
    "max-users": 2000,
    "share": 1234567890,
    "max-share": 12345678900,
    "uptime": 12345678,
    "encoding": "utf8"
}
```

`name` is a short name of the hub.

`desc` is a hub description.

`addr` is a list of alternative hub addresses, including fallback servers. List should be
sorted starting from the canonical address and followed by secondary addresses and
fallback servers.

`icon` is a relative URL path for a hub's favicon. Absolute URLs are not allowed and should
be ignored for security reasons.

`email` is a contact emails for hub's administration.

`users` is a current number of users on the hub.

`max-users` is a maximal number of users seen on the hub for its lifetime. 

`share` is a current total size of files shared by users on the hub. In MB, rounded up.

`max-share` is a maximal total share of users seen on the hub for its lifetime. In MB, rounded up.

`uptime` is a hub's uptime in seconds (unix epoch).

`encoding` is an optional label for NMDC hubs to specify encoding used for search and chat
messages. If not specified, `utf8` must be assumed. This value of this field must follow
[W3C encoding](https://www.w3.org/TR/encoding/) recommendation.

#### Website and redirects

Hub may also use an embedded HTTP server to serve a website, or use an HTTP redirect to
allow web browsers to automatically proceed to hub's website if hub's address was used.

# NMDC Protocol

- [Abstract](#abstract)
- [Authors](#authors)
- [General](#general)
  * [Status messages](#status-messages)
  * [Reference to hub in `$Lock`](#reference-to-hub-in-lock)
  * [Escape sequences](#escape-sequences)
  * [`$Key`/`$Lock` sequence](#keylock-sequence)
- [Security Considerations](#security-considerations)
- [Commands](#commands)
  * [Chat message](#chat-message)
  * [`$To`](#to)
  * [`$ConnectToMe`](#connecttome)
  * [`$RevConnectToMe`](#revconnecttome)
  * [`$GetPass`](#getpass)
  * [`$MyPass`](#mypass)
  * [`$LogedIn`](#logedin)
  * [`$Direction`](#direction)
  * [`$Cancel`](#cancel)
  * [`$Canceled`](#canceled)
  * [`$BadPass`](#badpass)
  * [`$HubIsFull`](#hubisfull)
  * [`$ValidateNick`](#validatenick)
  * [`$ValidateDenide`](#validatedenide)
  * [`$MyNick`](#mynick)
  * [`$MaxedOut`](#maxedout)
  * [`$Failed`](#failed)
  * [`$Error`](#error)
  * [`$Search`](#search)
  * [`$SR`](#sr)
  * [`$MyINFO`](#myinfo)
  * [`$Hello`](#hello)
  * [`$Version`](#version)
  * [`$HubName`](#hubname)
  * [`$GetNickList`](#getnicklist)
  * [`$OpList`](#oplist)
  * [`$Kick`](#kick)
  * [`$Close`](#close)
  * [`$OpForceMove`](#opforcemove)
  * [`$ForceMove`](#forcemove)
  * [`$Quit`](#quit)
  * [`$Lock`](#lock)
  * [`$Key`](#key)
- [Legacy commands](#legacy-commands)
  * [`$Ping`](#ping)
  * [`$GetINFO`](#getinfo)
  * [`$NickList`](#nicklist)
  * [`$Get`](#get)
  * [`$Send`](#send)
  * [`$FileLength`](#filelength)
  * [`$GetListLen`](#getlistlen)
  * [`$ListLen`](#listlen)
  * [`$MultiConnectToMe`](#multiconnecttome)
  * [`$MultiSearch`](#multisearch)
- [Standard extensions](#standard-extensions)
  * [`$Supports`](#supports)
  * [`NoHello`](#nohello)
  * [`NoGetINFO`](#nogetinfo)
  * [`$HubTopic`](#hubtopic)
  * [`SaltPass`](#saltpass)
  * [`$UserIP` extension (`UserIP2`)](#userip-extension-userip2)
  * [`$MCTo`](#mcto)
  * [`$ZOn`](#zon)
  * [`$UserCommand`](#usercommand)
  * [`TTHSearch`](#tthsearch)
  * [`XmlBZList`](#xmlbzlist)
  * [`TTHF`](#tthf)
  * [`ADCGet`](#adcget)
    + [`$ADCGET`](#adcget)
    + [`$ADCSND`](#adcsnd)
  * [TLS](#tls)
- [Extensions](#extensions)
  * [`$BotList`](#botlist)
  * [`$UserIP`](#userip)
  * [Pinger (`BotINFO` and `HubINFO`)](#pinger-botinfo-and-hubinfo)
    + [`$BotINFO`](#botinfo)
    + [`$HubINFO`](#hubinfo)
  * [`$NickChange`](#nickchange)
  * [`$ClientNick`](#clientnick)
  * [`NickRule`](#nickrule)
    + [`$NickRule`](#nickrule)
    + [`$BadNick`](#badnick)
  * [`SearchRule`](#searchrule)
  * [`FeaturedNetworks`](#featurednetworks)
  * [`$GetZBlock`](#getzblock)
  * [`$UGetBlock`](#ugetblock)
  * [`$UGetZBlock`](#ugetzblock)
  * [`$Sending`](#sending)
  * [`ChatOnly`](#chatonly)
  * [`Minislots`](#minislots)
  * [TTHL](#tthl)
  * [`ZLIG`](#zlig)
  * [`ACTM`](#actm)
    + [`$CTM`](#ctm)
    + [`$RCTM`](#rctm)
  * [`BZList`](#bzlist)
  * [`OpPlus`](#opplus)
  * [`Feed`](#feed)
  * [IPv4](#ipv4)
  * [IPv6](#ipv6)
  * [NAT traversal](#nat-traversal)
  * [DHT](#dht)
  * [Queue position](#queue-position)
  * [FailOver](#failover)
  * [Hub icon (`$SetIcon` and `$SetLogo`)](#hub-icon-seticon-and-setlogo)
- [Deprecated extensions](#deprecated-extensions)
  * [`$Capabilities`](#capabilities)
  * [`$IN`](#in)
  * [`$Z`](#z)
  * [`CHUNK`](#chunk)
  * [`$GetTestZBlock`](#gettestzblock)
  * [`ClientID`](#clientid)
  * [`QuickList`](#quicklist)
- [Examples](#examples)
  * [Client – Hub connection](#client-%E2%80%93-hub-connection)
  * [Client – Client connection](#client-%E2%80%93-client-connection)
- [License](#license)

## Abstract
Neo-Modus Direct Connect (NMDC) is a text protocol for a client-server network. The same protocol structure is used both for client-hub and client-client communication. This document is split into two parts; the first shows the structure of the protocol, while the second implements a specific system using this structure.

NMDC was written by Jon Hess, in the implementation of the (proprietary) NMDC client and hub software, but was never documented. The protocol was reverse-engineered later on by others, and soon followed open implementations. Extensions have followed over the years and may be incompatible with the original NMDC software.

## Authors
The protocol's basic outline was written by Jon Hess in 1998 for the NMDC client. Major influencers in the development that followed of NMDC include (in no particular order): Jacek Sieka, Sid, aDe, David Marwood, Suxxx, Stefan Gorling, Sphinx, HaArd and others.

This document uses information from many sources, including but not limited to;

* Ptokax Wiki ([new](http://wiki.ptokax.org), [snapshot](https://github.com/direct-connect/nmdc-code/tree/master/Other/PtokaxWiki), [archive](https://web.archive.org/web/20140108012040/http://wiki.ptokax.ch/)).
* TeamFair wiki ([snapshot](https://github.com/direct-connect/nmdc-code/tree/master/Other/TeamFair), [archive](https://web.archive.org/web/20090313025627/http://www.teamfair.info/wiki/index.php?title=Main_Page))
* The Nighthawk forum ([snapshot](https://github.com/direct-connect/nmdc-code/tree/master/Other/The%20NightHawk%20Forum))
* Mutor protocol doc ([snapshot](https://github.com/direct-connect/nmdc-code/blob/master/Other/mutor_protocoldoc.htm))

The initial version of this document was compiled by Fredrik Ullner.

## General
* URI scheme is `dchub://` for unencrypted and `nmdcs://` for encrypted connections. Also see the [URI scheme](./nmdc-uri-scheme.txt) document.
* Messages begin with a `$` (dollar sign). The only exception are [chat messages](#chat-message).
* Messages end with a `|` (pipe). Exceptions are [`$Cancel`](#cancel) and [`$Canceled`](#canceled) that are used in binary data transfer.
* Command names use a single space (` `) as a separator.
* Depending on the command, parameters use single space (` `), single (`$`) or double (`$$`) dollar signs, question marks (`?`) and code point 5 (`0x05`) as separators.
* There is no standardization on code page to use. The local charset of the computer system is commonly used. The original implementation used `win-1252`.
* Hub port defaults to `411`. The client should then try `412`, `413` etc.
* Client - Client port defaults to `412`. 
* Some command names are incorrectly spelled, per the original protocol. This document notes when a spelling error is 'intentional', per the original protocol.
* The hub should validate that the client sending the message is actually the correct user.
* This document does not (mainly) use `<` and `>` brackets for illustration purposes; any occurrence should be taken literally, unless otherwise noted.
* This document use `[` and `]` brackets for optional data; any literal occurrence will be noted as such.

There are different types of routed messages:
* Client to Hub (C-H)
* Client to Hub to Client (C-H-C)
* Hub to Client (H-C)
* Hub to Hub (H-H)
* Hub to Hublist (H-L)
* Pinger to Hub (P-H)

### Status messages
Most clients send a chat message to all users to indicate that a user has been kicked. That is, if a client A kicks client B, client A will send out a message to client C and D to indicate that the client B is kicked. To avoid being potentially flooded by this message, clients have implemented a de facto message to indicate kicks.
```
<john> is kicking peter because: I am not a dog person|
```
The key aspect here is the two phrases `is kicking` and `because:`. Including these two parts, regardless of the other content, will cause most clients to show the message as a status bar message.

Note that the hub will not actually treat this as a kick.

### Reference to hub in `$Lock`
To identify the source of the hub in a client - client connection, some clients add a reference to the hub in the [`$Lock`](#lock) that is sent, where the information is placed in the `Pk` parameter.

This information can also be provided in a client - hub connection.

Example:
```
$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk=DCPLUSPLUS0.666Ref=example.com:411
```

### Escape sequences
There are two ways protocol delimiters are displayable (dollar sign, pipe etc);

#### Method 1
By using `/%DCNXXX%/` where `XXX` is the decimal number for an ASCII character. 

This escape sequence method is used by all implementations for the [`$Lock`](#lock)/[`$Key`](#key) sequence (see below). This is also used by multiple implementations for normal viewing purposes (e.g. in a chat message). 

This escape sequence predates the second method listed below. 

The following escape sequences exist for this method;

| Escape sequence | Description
| --- | ---
| `/%DCN000%/` | `0x0a`, null character. Not allowed elsewhere in the protocol.
| `/%DCN005%/` | Enquiry character. Used by some commands.
| `/%DCN036%/` | `$`, dollar sign. Used by (almost) all commands.
| `/%DCN096%/` | ``` ` ```, grave accent.
| `/%DCN124%/` | `\|`, pipe. Used at end of commands.
| `/%DCN126%/` | `~`, tilde.

Example:
```
<John> I am going to display a dollar sign /%DCN036%/ and then a pipe /%DCN124%/.|
```

#### Method 2
By using the HTML equivalent of the character.

This escape sequence was created in and is used by DC++.

Note that DC++ uses the first method for the [`$Lock`](#lock)/[`$Key`](#key) sequence. DC++ uses this method for displayment purposes (e.g. chat messages).

The following escape sequences exist for this method;

| Escape sequence | Description
| --- | ---
| `&#36;` | `$`, dollar sign. Used by (almost) all commands.
| `&#124;` | `\|`, pipe. Used at end of commands.
| `&amp;` | `&`, ampersand.

Example:
```
<John> I am going to display a dollar sign &#36; and then a pipe &#124;.|
```

### `$Key`/`$Lock` sequence
After the first NMDC client and hub was introduced, others began to create their own implementation of the NMDC protocol. The original NMDC client and hub was freeware but not open source. In a way to combat other implementations, the author of the protocol decided upon a way to restrict the other implementations by a pseudo-cryptographic key exchange.

This exchange is typically referenced as a pseudo-Diffie-Hellman key exchange for its similarity, although they are not equivalent.

The [`$Key`](#key) and [`$Lock`](#lock) commands are not listed as extensions as they exist in at least NMDC hub 1.0.25 and NMDC client 1.0 Preview Build 9.1.

## Security Considerations

### Distributed Denial of Service Potential

The ongoing operation of NMDC's peer to peer connections provides
opportunities for both malicious clients on certain hubs and
malicious hubs to coordinate clients of those hubs in connecting en
masse to an arbitrarily specified IP address and port. Hubs SHOULD
mitigate this risk by only relaying such connection requests when
it can verify that the IP addresses and ports contained therein
belong to clients initiating such peer to peer connection requests.
Clients SHOULD effect similar amelioration through both attempting to
reconnect only to hubs to which they have initially connected once
and by providing upon connection referrer information regarding which
hub has relayed to them the IP and port to which they are connecting.

See also [Reference to hub in `$Lock`](#reference-to-hub-in-lock).

### Case-sensitivity Mismatches and Duplicated Shares Entries

Both accidentally due to differences in filesystem case-sensitivity
assumptions and intentionally by malicious clients can arise
filelists containing either entires either entirely or up to case
identical. Client software SHOULD detect these cases and avoid
wasteful downloading.

### Filelist Processing Memory Usage

The bzip2-compressed filelists that NMDC URIs ending in a separator
are required to process potentially expand due to malicious
construction to cause a processing client to exhaust its memory or
address-space capacity. Likewise, even non-malicious filelists can
grow arbitrarily large such that in combination with other memory
requirements of client software, similar exhaustion occurs. Client
software therefore SHOULD bound bzip2 decompression memory usage and
use streaming XML APIs to process filelists.

See [DC++ 0.75 and older vulnerable to bzip2 filelist bomb](https://dcpp.wordpress.com/2010/03/12/dc-0-75-and-older-vulnerable-to-bzip2-filelist-bomb/) for more information.

### Excessive Local Storage Consumption

The zlib compression supported by NMDC for client-client transfers
permits construction of transferred data which consume disk space
substantially more rapidly for the downloading client than network
bandwidth would indicate. Client software SHOULD monitor downloads
for impending storage capacity limits with a view to prevent local
denials of service resulting from exceeding them.

## Commands

### Chat message
```
<nick> message text|
```

Contexts: C-H-C, H-C

Will send a chat message by `nick`. The hub should broadcast the message to all clients if a client send this.

Note that the brackets (`<` and `>`) are required. Some implementations allow spaces in the nickname; be aware that other implementations may simply search for the first occurrence of a space. If the chat message contain a pipe, it should be replaced by its HTML equivalent.

Example:
```
|
hub message or status|
<John> cats are cute|
```

#### Keep-alive messages

Most implementations will send an empty chat messages to each other as a form of keep-alive
messages. This message consists of a single pipe character (`|`) and should be ignored.

Example:
```
|
```

#### Protocol error messages

On earlier protocol stages, such as [`$Lock`](#lock)/[`$Key`](#key) handshake,
[`$ValidateNick`](#validatenick), [`$GetPass`](#getpass) and others, the hub won't usually
send an [`$Error`](#error) or [`$Failed`](#failed) messages, and instead will send a regular
chat message followed by a connection close.

| Client | Hub
|--- |---
| | `$GetPass\|`
| `$GetNickList\|` |
| | `unexpected protocol message: GetNickList\|`
| | `<connection closed>`

#### Parsing considerations

Implementations should be prepared to handle the following cases:

Keep-alive messages (no nick and no text):
```
|
```

Hub-initiated messages (only a message, or empty nick):
```
message text|
<> message text|
```

Empty messages:
```
<nick>|
<nick> |
```

Messages with a line-break (`\n`) delimiter instead of a space (` `):
```
<nick>
message text
second line|
```

Messages with no space delimiter after `>`:
```
<nick>message text|
```

Some implementations also allow a nickname to contain `<` and `>` characters and/or spaces:
```
<< nick >> message|
```
Here a `< nick >` is the full nickname of a user.

The best parsing strategy is to first ensure that the message has a `<` prefix, and then
find the first `>` characters that is followed by any whitespace character (` `, `\n`, `\t`)
or the end of the message. If none character followed by a space were found, use the last
`>` character as a delimiter.

### `$To`
```
$To: othernick From: nick $<nick> message|
```

Contexts: C-H-C, H-C, C-C

Will send a private message from one user to another user. The same rules as a basic chat message apply. 

Example:
```
$To: john From: peter $<peter> dogs are more cute|
```

### `$ConnectToMe`
```
$ConnectToMe RemoteNick SenderIp:SenderPort|
$ConnectToMe RemoteNick SenderIp:SenderPort<flag>|
$ConnectToMe RemoteNick SenderIp:SenderPort<flag> SenderNick|
```

Contexts: C-H-C

Request that `RemoteNick` connect to the sending user for an active TCP connection for file transfers.
Clients sending this must allow incoming TCP connections. There is no default port.

Example:
```
$ConnectToMe john 192.168.1.2:412|
```

<!-- FIXME: What are the right flags/extensions names to support this?
            Old spec claims it's the TLS extension in $Support, but client can't detect it.
            Also, the spec claims that it's the 0x20 flag in $MyINFO, but the other
            [spec](https://webcache.googleusercontent.com/search?q=cache:WsW9g2m_bxUJ:https://forum.dcbase.org/viewtopic.php?f=81&t=814)
            from StrongDC++ mentions 0x20 flag in relation to NAT traversal.
-->

Secure connection (see [TLS](#tls)):
```
$ConnectToMe john 192.168.1.2:412S|
```

NAT traversal (see [NAT traversal](#nat-traversal)):
```
$ConnectToMe john 192.168.1.2:412NS peter|
$ConnectToMe peter 192.168.1.3:412RS|
```

#### Legacy

Some versions of NMDC client include the sender's nick as well, but it may not be compatible
with all implementations):
```
$ConnectToMe SenderNick RemoteNick SenderIp:SenderPort
```

Example:
```
$ConnectToMe peter john 192.168.1.2:412|
```

### `$RevConnectToMe`
```
$RevConnectToMe SenderNick RemoteNick|
```

Contexts: C-H-C

Request that the `RemoteNick` send a `ConnectToMe` back to `SenderNick`. Clients sending do not allow incoming TCP connections whereas the remote user does (or should).

Example:
```
$RevConnectToMe peter john|
```

### `$GetPass`
```
$GetPass|
```

Contexts: H-C

Request that the client send a password that correspond to a user account (matched by the user's nick name).

See also [`SaltPass`](#saltpass) extension.

### `$MyPass`
```
$MyPass password|
```

Contexts: C-H

Providing the password (in plain text) to the hub after a request. Implementations should be aware of potential pipe and dollar signs in the password.

Example:
```
$MyPass qwerty|
```

See also [`SaltPass`](#saltpass) extension that allows to hash the password.

### `$LogedIn`
```
$LogedIn nick|
```

Contexts: H-C

Sent to users who successfully log in. Note that the message should only be sent to operators. Note that some implementations do not use this command. The spelling of this command is not a mistake.

Example:
```
$LogedIn john|
```

### `$Direction`
```
$Direction direction number|
```

Contexts: C-C

This command is used as a way to decide which party should be allowed to download. 

The `direction` is either `Upload` or `Download`, depending on whether the connection request is a [`$ConnectToMe`](#connecttome) or [`$RevConnectToMe`](#revconnecttome).

The `number` is a random number (above 0), typically between 1 and 32767. If both clients want to download, the client with the highest number gets to start downloading first. If the numbers are equal, the connection is closed. 

This command should be sent;

* After a [`$Key`](#key) command or

* After a [`$Lock`](#lock) command with `EXTENDED` information

I.e., if the [`$Lock`](#lock) is `EXTENDED`, `$Direction` MUST be sent after the [`$Lock`](#lock) command and not the [`$Key`](#key) command.

Implementation note: The highest number DC++ sends is 32767 (2^15-1, 0x7FFF) as the Neo-Modus Direct Connect client will disconnect if it receives a higher number. Clients can send a higher value, in risk of losing compatibility.

Implementation note: A potential bug, that may be fixed, in DC++ revolved around the following circumstance;

* Client A has 0 free slots

* Client B has free slots (doesn't matter how many)

* Client A and client B want a file from one another

* Client A loses the random number "battle"

Client B will not get a slot because of client A does not have any slots available. DC++'s status bar of client B will say "Connecting..." instead of saying "No slots available" that is the de facto message. A suggested patch involve "cheating"; client B will use a high random number after it has lost and will return to normal when it has won.

### `$Cancel`
```
$Cancel
```

Contexts: C-C

This command is used as way to indicate that the transfer of a file should be cancelled prematurely.

This command is sent by the downloader. When the uploader receives the message, it should stop sending data followed by a [`$Canceled`](#canceled). It is possible that some implementations continue to send some data after the `$Cancel` and [`$Canceled`](#canceled); the downloader should discard this data.

This command was only implemented in NMDC v.1 and not in subsequent version or in other clients.

Note that there is no pipe (`|`) at the end of this command!

### `$Canceled`
```
$Canceled
```

Contexts: C-C

This command is used as way to indicate that the transfer of a file was cancelled prematurely.

This command is sent by the uploader.

This command was only implemented in NMDC v.1 and not in subsequent version or in other clients.

The spelling of this command is not a mistake.

Note that there is no pipe (`|`) at the end of this command!

### `$BadPass`
```
$BadPass|
```

Contexts: H-C

Indicates that the supplied password is invalid. The client shall be immediately disconnected after this message is sent.

### `$HubIsFull`
```
$HubIsFull|
```

Contexts: H-C

Indicates that the hub has reached its maximum amount of users and will not accept additional users. 

### `$ValidateNick`
```
$ValidateNick nick|
```
 
Contexts: C-H

The request is sent during the client-hub handshake to check if the nickname is available.

The hub will either respond with [`$Hello`](#hello) on success or [`$ValidateDenide`](#validatedenide) on failure.

Example (success):
```
$ValidateNick john|

$Hello john|
```

Example (failure):
```
$ValidateNick john|

$ValidateDenide john|
```

### `$ValidateDenide`
```
$ValidateDenide nick|
```
 
Contexts: H-C

The requested nick name is already taken by or is reserved for another user. The spelling of this command is not a mistake.

Example:
```
$ValidateDenide john|
```

### `$MyNick`
```
$MyNick nick|
```
 
Contexts: C-C

The request is sent during the client-client handshake to identify connecting peers.

Example:
```
$MyNick john|
```

### `$MaxedOut`
```
$MaxedOut|
```

Contexts: C-C

Sent by a client to another when there are no more slots available upon request of files.

See the QP extension for an extended `$MaxedOut`.

### `$Failed`
```
$Failed message|
```

Contexts: C-H, C-H-C, C-C, H-C

General purpose fail command. Implementations may use this command to signify files that are not available. `$Failed` is usually sent in response to a [`$GetZBlock`](#getzblock), [`$UGetBlock`](#ugetblock) and [`$UGetZBlock`](#ugetzblock).

### `$Error`
```
$Error message|
```

Contexts: C-H, C-H-C, C-C, H-C

General purpose fail command. Implementations may use this command to signify files that are not available. `$Error` is usually sent in response to a [`$GetZBlock`](#getzblock), [`$UGetBlock`](#ugetblock) and [`$UGetZBlock`](#ugetzblock).

### `$Search`
```
$Search ip:port search_string|
$Search Hub:nick search_string|
```
 
Contexts: C-H-C
 
The former is sent by active clients and the latter for passive clients. The `ip` is the client's own IP address and the `port` is an open UDP port that accept incoming UDP traffic. `Hub` should be taken literally. The `nick` is the nickname of the searching user.

#### The search string
The string describing the file or directory the client is searching for. It is made up of a question mark (`?`) delimited string as follows:

```
size_restricted?is_max_size?size?data_type?search_pattern
```
 
`size_restricted` is `T` if the search should be restricted to files of a minimum or maximum size, otherwise `F`.

`is_max_size` is `F` if `size_restricted` is `F` or if the size restriction places a lower limit on file size, otherwise `T`.

`size` is the minimum or maximum size of the file to search for (according to `is_max_size`) if `size_restricted` is `T`, otherwise `0`.

`data_type` restricts the search to files of a particular type. It is an integer selected from:

| Type | Description
|--- |---
| 1 | For any file type
| 2 | For audio files
| 3 | For compressed files
| 4 | For document files
| 5 | For executable files
| 6 | For picture files
| 7 | For video files
| 8 | For folders
| 9 | For TTH searching

`search_pattern` is used by other users to determine if any files match. If it is a TTH search, `search_pattern` should be `TTH:hash`.

Spaces in the search pattern are replaced by a dollar sign `$`. <!-- TODO: "As with all NMDC messages, '$' and '|' are escaped with "$" and "|", with '&' being further replaced with "&"." -->

Examples:

Active search:
```
$Search 192.168.1.5:412 T?T?500000?1?Gentoo$2005
$Search Hub:SomeNick T?T?500000?1?Gentoo$2005
```

Passive search:
```
$Search 192.168.1.5:412 F?T?0?9?TTH:TO32WPD6AQE7VA7654HEAM5GKFQGIL7F2BEKFNA
$Search Hub:SomeNick F?T?0?9?TTH:TO32WPD6AQE7VA7654HEAM5GKFQGIL7F2BEKFNA
```

### `$SR`
```
$SR source_nick result free_slots/total_slots<0x05>hub_name (hubip[:port])[<0x05>target_nick]|
```

Contexts: C-H-C, C-C

Sent by a client when a match to a search is found.

If the [`$Search`](#search) was a passive one, the `$SR` is returned via the hub connection (TCP). In this case, `<0x05>target_nick` must be included on the end of the `$SR`. The hub must strip the deliminator and `<target_nick>` before sending the `$SR` to `target_nick`. If the search was active, it is sent to the IP address and port specified in the [`$Search`](#search) via UDP.

Result is one of the following:

* `filename<0x05>filesize`
* `directoryname`

File size shall be in bytes.

`<0x05>` used above for deliminators are the 5th character in the ASCII character set. The brackets should consequentially not be taken literally.

The port for the hub only needs to specified if its listening port is not the default (`411`).

On UNIX, the path delimiter `/` must be converted to `\` for compatibility. 

Implementations should send a maximum of 5 search results to passive users and 10 search results to active users.

`Free_slots` are the amount of available slots left. `Total_slots` are the total amount of slots.

For files containing TTH, the `hub_name` parameter is replaced with `TTH:hash`.

Examples:

Active result:
```
$SR User1 ponies.txt<0x05>437 3/4<0x05>Testhub (192.168.1.1:411)|
$SR User5 images 0/4<0x05>Testhub (192.168.1.1:411)|
$SR User6 pictures 0/4<0x05>Testhub (192.168.1.1)|
```

Passive result:
```
$SR User1 ponies.txt<0x05>437 3/4<0x05>Testhub (192.168.1.1:411)<0x05>User2|
$SR User5 images 0/4<0x05>Testhub (192.168.1.1:411)<0x05>User2|
$SR User6 pictures 0/4<0x05>Testhub (192.168.1.1)<0x05>User2|
```

### `$MyINFO`
```
$MyINFO $ALL nick description$ $<connection><flag>$mail$share_size$|
```
 
Contexts: C-H (C-H-C)
 
This command is part of the Client-Hub Handshake and during login, and is sent after the client receive [`$Hello`](#hello) with their own nick. Client resend this on any change. It's broadcasted to all clients. 

The `<` and `>` use in here should not be taken literally; they are there to visually distinguish connection from flag. Consequently, the flag shall immediately follow the connection.

Connection is a string for the connection:

* Default NMDC1 connections types `28.8Kbps`, `33.6Kbps`, `56Kbps`, `Satellite`, `ISDN`, `DSL`, `Cable`, `LAN(T1)`, `LAN(T3)`

* Default NMDC2 connections types `Modem`, `DSL`, `Cable`, `Satellite`, `LAN(T1)`, `LAN(T3)`

Later implementations also send other speeds. Implementations should simply display the value to the user and not create any inhibitions based on the reported speed.

#### Flag
Flag is a ASCII character (8 bit byte). 

There are multiple implementations of this byte. 

The values listed here are the bits within the flag byte. The following is the original:

| Bit | Description
|--- |---
| 1 | Normal or no status.
| 2 | Away.
| 3 | Server status. Used when the client has uptime > 2 hours, > 2 GB shared, upload > 200 MB. 
| 4 | Fireball status. Used when the client has had an upload > 100 kB/s. 


The values listed here are the bits within the flag byte. Newer implementations change the numbers to be extensions of the original and are the following:

| Bit | Description
|--- |---
| 5 | Support for TLS. For all connections when `TLS` extension is supported. For download only when `TLS1` extension is supported.
| 6 | Support for TLS upload when `TLS1` extension is supported.
| 7 | Support for IPv4 when `IP64` extension is supported.
| 8 | Support for IPv6 when `IP64` extension is supported.


The values listed here are decimal values. Other implementations interpreted this to be the following:

| Decimal | Description
|--- |---
| 1 | Normal
| 2 and 3 | Away
| 4 and 5 | Server. Used when the client has uptime > 2 hours, > 2 GB shared, upload > 200 MB. 
| 6 and 7 | Server away
| 8 and 9 | Fireball. Used when the client has had an upload > 100 kB/s. 
| 10 and 11 | Fireball away

Example verification with the first and second approach:

| Flag calculation | Result
|--- |---
| `if Flag & 0x1` | Normal status
| `if Flag & 0x2` | Away status
| `if Flag & 0x4` | Server status
| `if Flag & 0x8` | Fireball status
| `if Flag & 0x10` | TLS support for downloads
| `if Flag & 0x20` | TLS support for uploads (with `TLS1`)
| `if Flag & 0x40` | IPv4 support
| `if Flag & 0x80` | IPv6 support

Example verification with the third approach:

| Flag calculation | Result
|--- |---
| `if Flag == 1` | Normal status
| `if Flag == 2 OR Flag == 3` | Away status
| `if Flag == 4 OR Flag == 5` | Server status
| `if Flag == 6 OR Flag == 7` | Server and away status
| `if Flag == 8 OR Flag == 9` | Fireball status
| `if Flag == 10 OR Flag == 11` | Fireball and away status

#### Tag
This addition to the description field was introduced to ease concerns by hub operators that DC++ users were joining too many hubs and not allowing enough uploads. (The original DC client only allowed users to join a single hub.) The tag is now the de facto standard. 

Example:
```
<++ V:0.673,M:P,H:0/1/0,S:2>
```

* `++`: indicates the client (in this case, DC++)
* `V`: tells you the version number 
* `M`: tells if the user is in active (`A`), passive (`P`), or SOCKS5 (`5`) mode 
* `H`: tells how many hubs the user is on and what is his status on the hubs. The first number means a normal user, second means VIP/registered hubs and the last one operator hubs (separated by the forward slash `/`). 
* `S`: tells the number of slots user has opened 
* `O`: shows the value of the "Automatically open slot if speed is below xx KiB/s" setting, if non-zero 
* The brackets `<` and `>` shall be taken literally.

Note that the IPv4/IPv6 extensions add additional data to the `M`. See the IPv4/IPv6 extensions for further information.

Example:

Note that the example uses `0x31` for signaling the flag as "Normal", for ease of display.
```
$MyINFO $ALL johndoe <++ V:0.673,M:P,H:0/1/0,S:2>$ $LAN(T3)0x31$example@example.com$1234$\|
```

### `$Hello`
```
$Hello user|
```

Contexts: H-C

When a new user logs in, the hub will send this command to the new user to inform them that
they have been accepted for hub entry.

See [`NoHello`](#nohello).

### `$Version`
```
$Version version|
```
 
Contexts: C-H

Sent by clients to the hub after [`$Hello`](#hello) is received to denote the version used for the client. This command is nowadays not used to denote the client's version but was used frequently by the original Neo-Modus Direct Connect (NMDC) client. The last version of the Neo-Modus client was 1.0091 and is what is commonly used by current clients. The default system locale is used, which means the period may be a comma etc. 

Version is `1.0091` by default.

The implementations should also accept `1,0091` and `1,0098`.

### `$HubName`
```
$HubName name|
```

Contexts: H-C

The name of the hub that should be displayed by clients to users. The name is sometimes interpreted as the "topic" (current discussion topic or general theme of the hub), in cases where [`$HubTopic`](#hubtopic) does not exist. The hub could send different names to different users, as well as the ability for multiple hubs (that are inherently separated) to have the same name, so the client should not use the hub name as a unique identifier.

### `$GetNickList`
```
$GetNickList|
```
 
Contexts: C-H

Request that the hub send the nick names of all users that are connected.

### `$OpList`
```
$OpList nick$$nick2$$nick3[...]|
```

Contexts: H-C

Providing the full listing of operators. This is a subset of the users provided in [`$NickList`](#nicklist) or [`$MyINFO`](#myinfo). List is separated by `$$`. 

The following should be sent if there are no operators online:
```
$OpList|
```
 
Example:
```
$OpList john$$peter| 
```

### `$Kick`
```
$Kick victim|
```

Contexts: C-H-C

Requests that the hub kicks a user (terminates the connection to the user). The hub will validate that the issuing user actually have permission to kick the other user. The message does not specify a reason to the kick; hubs may decide instead to send a default "you have been kicked" message. Time frame (of a potential ban) does not exist in the protocol, as it is decided by the hub's configuration. It is up to the hub to decide the course of action if the user is not allowed to issue the kick, but the majority of implementations will simply ignore the message or send a message back ("you are not allowed to issue the command"). Many clients that issue the Kick command will precede the message with a message directed (either normal main chat or with [`$To`](#to) to the offended user with the reason for the kick.

### `$Close`
```
$Close victim|
```
 
Contexts: C-H-C

Requests that the hub kicks a user (terminates the connection to the user), but no message will be sent to the victim client. All other information is similar to [`$Kick`](#kick).

### `$OpForceMove`
```
$OpForceMove $Who:victim$Where:address$Msg:reason|
```

Contexts: C-H-C, H-C

A request made by privileged users to redirect a user from the hub. The message should be sent to the offending user in a main chat message or in a [`$To`](#to) message.

`victim` is nick name of the victim.

`address` is the address to redirect to, abiding to the specified rules for URIs. 

`reason` is why the redirect was issued.

Example:
```
$OpForceMove $Who:richard$Where:example.com:411$Msg:I think you'll like this hub better|
```

### `$ForceMove`
```
$ForceMove address|
```

Contexts: C-H-C, H-C

Informs the user that it should close its connection and instead connect to the address specified. Many implementations will send [`$ForceMove`](#forcemove) followed by a main chat message or a [`$To`](#to) message.

Example:
```
$ForceMove example.com:411|
$To:richard From: OpNick $<peter> You are being re-directed to example.com:411 because: I think you'll like thus hub better.|
```

### `$Quit`
```
$Quit nick|
```

Contexts: H-C

Inform users in a hub that `nick` has disconnected from the hub. If a user desire to disconnect from a hub, the client should simply terminate the connection and not send `$Quit`.

Example:
```
$Quit peter|
```

### `$Lock`
```
$Lock lock Pk=pk|
```
 
Contexts: H-C, C-C, L-H
 
This is a mechanism to request 'certification' for verification. The lock is a command that added by NMDC to keep other clients (such as DC++) from being able to use NMDC hubs. The lock require a response (given in a [`$Key`](#key)) that needs to be calculated, as per the lock's data. Hubs are not required to check the validity of the response, but must still send it.

Note this command, and its use, are used for all connections. 

This command should be the first to be sent in a client to hub connection. This command should be sent after both have used [`$MyNick`](#mynick) in a client to client connection. Both clients (in a client to client connection) should send `$Lock`.

The lock data is a sequence of random characters, excluding space (` `), dollar sign (`$`) and a pipe (`|`).

`Pk` was originally intended for use with SSL/TLS keys for secure connections, but is not used by any implementation today. Some implementations send their name and version in this field.

Implementation note: In NMDC hub;

* `Lock`'s length varied from 46 to 115 characters

* `Pk`'s length was static with 16 characters.

* `Lock`'s characters varied from ASCII code point 37 to ASCII code point 122. 

Example:

See [`$Supports`](#supports) for the use of `EXTENDED`.

```
$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk=DCPLUSPLUS0.706ABCABC|
```
```
$Lock EXTENDEDPROTOCOL_verlihub Pk=version0.9.8e-r2|
```

### `$Key`
```
$Key key|
```

Contexts: C-H, C-C, H-L

The key is given as a response for a [`$Lock`](#lock) command, as calculated by the following algorithm. 

The key has exactly as many characters as the lock. Except for the first, each key character is computed from the corresponding lock character and the one before it. If the first character has index 0 and the lock has a length of len then:

```
for (i = 1; i < len; i++)
{
   key[i] = lock[i] xor lock[i-1];
}
```

The first key character is calculated from the first lock character and the last two lock characters:

```
key[0] = lock[0] xor lock[len-1] xor lock[len-2] xor 5
```

Next, every character in the key must be nibble-swapped:

```
for (i = 0; i < len; i++)
{
   key[i] = ((key[i]\<<4) & 240) | ((key[i]>>4) & 15);
}
```

Finally, the characters with the decimal ASCII values of 0, 5, 36, 96, 124, and 126 cannot be sent to the server. Each character with this value must be substituted with the string `/%DCN000%/`, `/%DCN005%/`, `/%DCN036%/`, `/%DCN096%/`, `/%DCN124%/`, or `/%DCN126%/`, respectively. The resulting string is the key to be sent to the server.

If your programming language of choice doesn't have xor or shift operations on characters, convert them to integers. If it doesn't have a bit shift at all, then `x « y = x*(2y)` and `x » y = x/(2y)` for all integers `x` and `y` (`**` is the exponent operation or “to the power of”). Be sure to use unsigned values everywhere and do not do sign extension. Shift operations always lose the high or low bit (they are not roll operations!). The `&` (and) and `|` (or) operations are all logical, not boolean (eg. `6 & 13 = 4`, not 1).

When the hub connects to the hublist, it must undergo a similar `Lock`/`Key` negotiation. The `<key>` calculation is the same, but the special number 5 in the second step is replaced with the following value is not computed from the hub's listening port, but rather the random outgoing port that the Winsock selects. localport: 1) & 255

Note that the data sent should be in its raw form.

Example:

Note that this (and every other) example uses `011010110110010101111001` as key, but it should be interpreted as a binary value.
```
$Key 011010110110010101111001|
```

## Legacy commands

Commands in this section were defined in the original protocol and were either superseded
by extensions, or are not used by implementations.

### `$Ping`
```
$Ping sender_ip:sender_port|
```

`sender_ip` is the IP address of the remote client.

`sender_port` is the port of the remote client that is being listened to.

Not used by any implementations.

### `$GetINFO`
```
$GetINFO <other_nick> <nick>|
```
 
Contexts: C-H-C
 
Request (general) client information.

`<nick>` is this sending client's nick. 

`<other_nick>` is the nick of the user that `<nick>` wants to know about. The server must respond with exactly the [`$MyINFO`](#myinfo) command sent by `<other_nick>` to the hub. 
 
Example:
```
$GetINFO peter john|
```

Superseded by [`NoGetINFO`](#nogetinfo) extension.

### `$NickList`
```
$NickList nick$$nick2$$nick3[...]|
```

Contexts: H-C

Providing the full listing of users, including bots and operators. List is separated by `$$`.

Example:
```
$NickList john$$peter$$richard$$marie$$sarah| 
```

Superseded by [`NoHello`](#nohello) and [`NoGetINFO`](#nogetinfo) extensions.

### `$Get`
```
$Get file$offset|
```
 
Contexts: C-C

`file` is the remote location (including path) of the file.

`offset` is the byte offset to start at for resuming files.

Example:
```
$Get C:/Uploads/myfile.txt$15|
```

Superseded by [`$ADCGET`](#adcget).

### `$Send`
```
$Send|
```
 
Contexts: C-C

This is used as a way to specify that the file should be sent. The uploader should proceed to stream the amount of bytes requested previously.

Superseded by [`$ADCSND`](#adcsnd).

### `$FileLength`
```
$FileLength file_size|
```
 
Contexts: C-C

This command is used as a way to provide the size of the file requested.

Superseded by [`$ADCSND`](#adcsnd).

### `$GetListLen`
```
$GetListLen|
```
 
Contexts: C-C

Get file list size.

Superseded by [`XmlBZList`](#xmlbzlist) and [`$ADCGET`](#adcget).

### `$ListLen`
```
$ListLen file_size|
```
 
Contexts: C-C

This command is used as a way to provide the size of the file list of the client.

Superseded by [`XmlBZList`](#xmlbzlist) and [`$ADCSND`](#adcsnd).

### `$MultiConnectToMe`
```
$MultiConnectToMe remote_nick sender_ip:sender_port
```

This command is a client side command to take advantage of hub linking feature in the NeoModus Direct Connect Hub software. When a local client sends `$MultiConnectToMe` to the hub, it is forwarded on to every hub which is linked to by UDP, as in the [`$Search`](#search) hub<->hub protocol command. 

This command is used in conjunction with [`$MultiSearch`](#multisearch). 

This support was problematic, as the NeoModus Direct Connect Hub did not provide a way to indicate that it was part of a link, and further did not provide the ability to broadcast joins and parts of remote users. Some implementations would send `$MultiConnectToMe` commands even when the remote user was offline.

Example:
```
$MultiConnectToMe peter 192.168.0.138:19346
```

Not used by any implementations.

### `$MultiSearch`
```
$MultiSearch ip:port search_string|
```

This command is a client side command to take advantage of hub linking feature in the NeoModus Direct Connect Hub software. When a local client sends `$MultiSearch` to the hub, it is forwarded on to every hub which is linked to by UDP, as in the `$Search` hub<->hub protocol command. 

This command is used in conjunction with [`$MultiConnectToMe`](#multiconnecttome).

For syntax on the parameters, see [`$Search`](#search).

Not used by any implementations.

## Standard extensions

Extensions listed in this section become a de-facto standard for NMDC protocol. Although
it's possible to omit any of them, most implementations in the wild support all of them,
thus it is highly recommended to implement these extensions.

### `$Supports`
```
$Supports extension1 extension2 [...]|
$Supports extension1 extension2 [...] |
```
 
Contexts: C-H, H-C, C-C

This command is used to negotiate and notify about protocol extensions. 

If a client or hub implements an extension, the [`$Lock`](#lock) command MUST start with `EXTENDEDPROTOCOL`.

This command MUST be sent before [`$Key`](#key). 

Implementations should only send extension specific messages if the other party has signaled support for it.

There must be at least 1 (one) supported extension. 

For client extensions, the extension name should be the same as the command name.

Note that DC++ 0.XXX added a space after the last extension. I.e., the first form is the original implementation of [`$Supports`](#supports).

Example:

The following example signals support for 7 (seven) different extensions. See corresponding command/extension for description.
```
$Supports UserCommand NoGetINFO NoHello UserIP2 TTHSearch ZPipe0 GetZBlock|
```

### `NoHello`
Contexts: C-H

This indicates that the client doesn't need either [`$Hello`](#hello) or [`$NickList`](#nicklist) to be sent to it
when connecting to a hub. To populate its user list, a [`$MyINFO`](#myinfo) for each user is enough.

[`$Hello`](#hello) is still accepted for adding bots to the user list, but implementations tend to use
[`$MyINFO`](#myinfo) and/or [`$BotList`](#botlist) so [`$Hello`](#hello) is considered deprecated
for this purpose.

Clients should still send a [`$GetNickList`](#getnicklist) to indicate that it is interested in the user list.
During login, hubs must still send [`$Hello`](#hello) after [`$ValidateNick`](#validatenick) to indicate that the nick
was accepted.

Add `NoHello` to the `$Supports` to indicate support for this.

### `NoGetINFO`
This indicates that the hub doesn't need to receive a [`$GetINFO`](#getinfo) from a client to send out [`$MyINFO`](#myinfo).

This is a variation of the `QuickList` proposal that is easy to implement and does half of [`QuickList`](#quicklist)'s job.

Add `NoGetINFO` to the `$Supports` to indicate support for this.

### `$HubTopic`
```
$HubTopic topic|
```

Contexts: H-C

The hub topic, be it current discussion topic or general theme of the hub, which allow users to quickly see what the discussion and file sharing themes are. Hub pingers frequently use this message for hub related information. 

Add `HubTopic` to the `$Supports` to indicate support for this.

### `SaltPass`
```
$GetPass salt|
$MyPass hashed_pass|
```

Contexts: C-H, H-C

This feature offers passwords to be salted and hashed, which means that passwords are no longer sent in plaintext. This adds "random data" (`salt`) to the [`$GetPass`](#getpass) command.

The random data should be Base32 encoded.

The data that is sent back in the [`$MyPass`](#mypass) shall be the password followed by the random data, passed through the Tiger algorithm and then encoded with Base32. I.e., `base32( tiger_hash( password + data ) )`.

Add `SaltPass` to the `$Supports` to indicate support for this.

The algorithm here is a port from ADC's `GPA`/`PAS`.

Example
```
$GetPass salt|
$MyPass hashed_pass|
```

### `$UserIP` extension (`UserIP2`)
```
$UserIP nick1 IP1$$nick2 IP2[...]|
```
 
Contexts: H-C

This is similar to the other [`$UserIP`](#userip) command, except that there is no request. The hub will, if the client signals support for `UserIP2`, send all users upon login. 

The list consist of each user and their IP, including the connecting client. The hub should send each new client's IP when they login. 

Note that `$$` is used as delimiter.

Add `UserIP2` to the `$Supports` to indicate support for this.

| Client | Server
|--- |---
| | `$UserIP johndoe 192.168.1.2$$janedoe 192.168.1.3\|`

### `$MCTo`
```
$MCTo: target $sender message|
```

Contexts: C-H, H-C

This is a private-message to a single user that should be displayed as an ordinary chat-message.

Add `MCTo` to the `$Supports` to indicate support for this.

`target` is the client nick that should receive the message.

`sender` is the client nick that is the sender

`message` is the actual message.

Examples:
```
$MCTo john $peter Cats are cute|
$MCTo peter $john I like dogs|
```

### `$ZOn`
```
$ZOn|blob
```

Contexts: H-C

This command's intention is to compress (with ZLib) data to decrease bandwidth use.
The `blob` uncompressed is one or more commands, e.g. a [`$Search`](#search) followed by a [`$MyINFO`](#myinfo).

Compression algorithm shall be LZ77.

The end of the `blob` is an `EOF` indicated by ZLib. Following commands will have no
compression until the next `$ZOn` is received.

Add `ZPipe0` to the `$Supports` to indicate support for this.

The command adds no escaping.

### `$UserCommand`
```
$UserCommand type context details|
```

Contexts: H-C

Add `UserCommand` to the `$Supports` to indicate support for this.

`type` is a positive integer describing the kind of command:

| Value | Description
|--- |---
| 0 | Separator
| 1 | Raw
| 2 | Raw nick limited (same as raw with the exception that it should only be used once per `%[nick]`)
| 255 | Erase all previously sent commands


`context` is a integer that controls which contexts the menus will be shown. The value is derived by logical OR of the following values;

| Value | Description
|--- |---
| 1 | Hub context
| 2 | User context
| 4 | Search context
| 8 | File list

`details` differ depending on the type.

| Type | Detail information
|--- |---
| 0 and 255 | Leave this field empty
| 1 and 2 | Detail should be `title$command`.

#### Escaping
Escaping of dollar and pipe is necessary for the `<command>` in 'raw' mode. The DC++ escape sequence will be used. i.e. `&#124;` for pipe, `&#36;` for dollar and `&amp;` for the ampersand. Escaping is used for all fields before they are sent to the hub / shown to the user. As with all NMDC commands, they must be terminated by the pipe character

#### Details: Separator
```
$UserCommand 0 <context>|
```

Will add a menu separator (vertical bar) to the specified contexts (`<context>`). It is legal to add text (after the space) before the pipe, but it won't be used (yet).

#### Details: Raw
```
$UserCommand 1 <context> <title>$<raw>|
```

Will add a raw menu item with title `<title>` with command `<raw>`. This command must end with a `&#124;`, if not it should be discarded. The raw command may be used to specify multiple commands to be sent to the hub.

#### Details: Raw nick limited
```
$UserCommand 2 <context> <title>$<raw>|
```
 
Is exactly the same as Raw, except that the command should only be run once per `%[nick]`. This is to prevent the client from sending out more than one message that disconnects someone. Generally, this is only useful in the User-File context (e.g. viewing Search Results) where it is possible to select one user multiple times.

#### Details: Erase
```
$UserCommand 255 <context>|
```

Will erase all commands that the hub has sent previously. This is for hubs/scripts that allow for updates while running. The erase all is intentional, keeping it simple. Note that contexts must still be used, and that erasing will remove all commands that match any of those ORed contexts (i.e. 7 will remove commands previously sent with any context of 1 through 7) but only from that context

Examples:
```
$UserCommand 2 6 Kick$&#36;To: %[nick] From: %[mynick] &#36;<%[mynick]> You are being kicked====|&#36;Kick %[nick]&#124;|
$UserCommand 255 1|
```

### `TTHSearch`
This indicates that the client support searching for queued files by TTH. See [`$Search`](#search) for details.

Add `TTHSearch` to the `$Supports` to indicate support for this.

### `XmlBZList`

Usage: Supporting this means supporting utf-8 XML file lists with the 
following general structure:

```xml
<FileList Version="1" Generator="dc client name and version">
 <Directory Name="xxx">
  <Directory Name="yyy">
   <File Name="zzz" Size="1"/>
  </Directory>
 </Directory>
</FileList>
```

In each directory, including the root, the name of the entity must be
case-insensitive unique in that level of the hierarchy. 

Other fields may be added as necessary. DC++ for instance adds the
`TTH` attribute to each file it knows the TTH root of in base32 encoding.

The file list is available as `files.xml.bz2` (vs `MyList.DcLst`), and is
compressed using bzip2.

To retrieve unicode files from the file list, the client may also support
the above `GetZBlock` and its utf-8 derivatives. Support for `XmlBZList`
implies support for [`$UGetBlock`](#ugetblock), so files are guaranteed to be retrievable.

[`$UGetBlock`](#ugetblock) follows [`$UGetZBlock`](#ugetzblock) semantics, but without compressing 
the data. The `bytes` parameter of [`$Sending`](#sending) specifies how many bytes
will be sent.

Don't touch `Version`. Add your own, with a different name, if you feel 
compelled.

Don't trust `Generator` to determine features of the file list. It's there
mainly for debugging and informative purposes.

Add `XmlBZList` to the `$Supports` to indicate support for this.

DC++ supported the feature `XMLBZList` and the commands `$GetBlock`, `$UGetBlock` and `$UGetZBlock` in versions 0.307 to 0.695. DC++ dropped support for the commands in version 0.696, whilst not removing the feature announcement. I.e., DC++ signals in the `$Supports XMLBzList` while it does not support the actual commands.

### `TTHF`

Supporting this means supporting file identification by TTH root. This
means supporting downloads by TTH root instead of share directory and
name. The advantage is that moved files can still be found by the
downloader without requeuing the file.

The extension adds a namespace `TTH` before the ADC file root. A TTHF
filename has the following syntax:

```
TTH/<TTH root in base32, 192 binary bits>
```

i e the TTH namespace consists of TTH root values directly under the
`TTH/` root.

The naming scheme is valid in all types (i e also for getting TTH leaves)

Add `TTHF` to the `$Supports` to indicate support for this.

### `ADCGet`

Contexts: C-C

Support for `ADCGet` imply support for both  [`$ADCGET`](#adcget) and [`$ADCSND`](#adcsnd).

It supersedes [`$Get`](#get) and [`$Send`](#send), but implementations should be ready to
accept both versions.

Add `ADCGet` to the `$Supports` to indicate support for this. 

#### `$ADCGET`
```
$ADCGET type identifier start_pos bytes flag0...flagN|
```

Contexts: C-C

This is a port of the ADC approach of signifying the request. `start_pos` counts 0 as the first byte.

`bytes` may be set to `-1` to indicate that the sending client should fill it in with the number of bytes needed to complete the file from `start_pos`.

`type` is a `[a-zA-Z0-9]+` string that specifies the namespace for identifier and clients should recognize the type `file`.

`file` transfers transfer the file data in binary, starting at `start_pos` and sending `bytes` bytes. Identifying must come from the namespace of the current hash.

`flag0...flagN` is a reference to the fields in ADC's `GET` command. Fields available for `GET` can also be added here in the same way as in ADC.

#### `$ADCSND`
```
$ADCSND type identifier start_pos bytes|
```

Contexts: C-C

This is used as a way to specify that the file should be sent. The uploader should proceed to stream the amount of bytes requested previously.

This is a port of the ADC approach of signifying sending. The parameters correspond to the `ADCGET` parameters except that if `bytes` equals `-1` it must be replaced by the number of bytes needed to complete the file starting at `start_pos`.

### TLS
This feature is used to indicate support for TLS encrypted client-client connections.

Implementations shall add an `S` to the (TLS) port in a [`$ConnectToMe`](#connecttome).

Add `TLS` to the `$Supports` to indicate support for this.

Example:
```
$ConnectToMe john 192.168.0.1:412S|
```

## Extensions

### `$BotList`
```
$BotList nick$$nick2$$nick3[...]|
```

Contexts: H-C

Providing the full listing of bots. This is a subset of the users provided in [`$NickList`](#nicklist) or [`$MyINFO`](#myinfo). List is separated by `$$`.

Add `BotList` to the `$Supports` to indicate support for this.

Example:
```
$BotList marie| 
```

### `$UserIP`
```
$UserIP nick|
$UserIP nick ip|
```

Contexts: C-H, H-C

A client may request IP address information about clients. The hub will respond with a command with the same name, but with different parameter data.

Example:

| Client | Server
|--- |---
| `$UserIP johndoe\|` |
| | `$UserIP johndoe 192.168.1.2\|`

### Pinger (`BotINFO` and `HubINFO`)

#### `$BotINFO`
```
$BotINFO description|
```

Contexts: P-H
 
Bot description can be any string, usually information regarding, and address of, the hublist.

Add `BotINFO` to the `$Supports` to indicate support for this.

#### `$HubINFO`
```
$HubINFO name$address:port$description$max_users$min_share$min_slots$max_hubs$hub_type$hubowner_login|
```
 
Contexts: H-P

Hub `name`, `address` and `description` are the items which will be shown in the hublist (some hubs have multiple addresses and this helps to get primary address). Description changes often on some hubs so this helps with updating it.

`max_users`, `min_share`, `min_slots` and `max_hubs` (maximum number of open hubs) for the client helps users to find suitable hubs.
 
`hub_type` gives information about the hub software and script which gave the information.

`hubowner_login` is meant to help hubowners to edit information about their hub directly from the hublist portal It is usually an email address where the account/password information should be sent.

If the hub address is `127.0.0.1`, the hublist should remove the hub from its database.

Some hubs support a different variation of this command with 11 (or more) parameters:
```
$HubINFO name$address$description$max_users$min_share$min_slots$max_hubs$hub_type$hubowner$privacy$encoding|
```

Add `HubINFO` to the `$Supports` to indicate support for this.

### `$NickChange`
```
$NickChange old_nick new_nick|
```

Contexts: C-H

This allow a client to change the nick without logging out and logging back in.

`old_nick` is the old user nick.

`new_nick` is the new user nick.

Add `NickChange` to the `$Supports` to indicate support for this.

The client will have to update its own [`$MyINFO`](#myinfo) string and user list. 

The hub will will send [`$ClientNick`](#clientnick) to the client to validate that the change is done. To all other users, a `$Quit old_nick` will be sent and a `$MyINFO $ALL` of the user with the new nick.

If the user is an operator, [`$OpList`](#oplist) will be updated appropriately as well.

### `$ClientNick`
```
$ClientNick new_nick|
```

Contexts: H-C

This validates that the hub has acknowledged the change of nick during runtime that was initiated by [`$NickChange`](#nickchange).

`new_nick` is the new user nick.

Add `ClientNick` to the `$Supports` to indicate support for this.

### `NickRule`

#### `$NickRule`
```
$NickRule Min nick_min$$Max nick_max$$Char char_1 char_2$$Pref pref_1 pref_2|
```

Contexts: H-C

This validates that the hub has acknowledged the change of nick during runtime that was initiated by [`$NickChange`](#nickchange).

`Min` field specifies minimum nick length (`nick_min`).

`Max` field specifies maximum nick length (`nick_max`).

`Char` field specifies space separated list of decimals character codes forbidden to use in nick.

`Pref` field specifies space separated list of nick prefixes required for usage in the hub.

Not all of the above parameters must be specified, the list is based on hub configuration.

Client has a chance to automatically update its nick before sending [`$ValidateNick`](#validatenick) command. 

Add `NickRule` to the `$Supports` to indicate support for this.

#### `$BadNick`
```
$BadNick [reason]|
```

Contexts: H-C

Clients that support [`NickRule`](#nickrule) but send invalid nick anyway, will receive `$BadNick` command with error specification.

Nick is too short:
```
$BadNick Min 3|
```

Nick is too long:
```
$BadNick Max 64|
```

Bad characters found in nick:
```
$BadNick Char 60 62|
```

Bad prefix found in nick:
```
$BadNick Pref|
```

One of prefixes missing in nick:
```
$BadNick Pref [ISP1] [ISP2]|
```

Client should then automatically correct its nick and reconnect to the hub. Meaning of this extension is to avoid extra reconnects when nick usage is heavily restricted. This applies only to non registered nicks.

Add `NickRule` to the `$Supports` to indicate support for this.

### `$SearchRule`
```
$SearchRule Min min_query$$Max max_query$$Num max_req$$Int interval_active$$IntPas interval_passive$$Share min_share|
```

Contexts: H-C

This extension specifies list of search rules currently being used by hub configuration. The command is sent from hub to client right after the user is successfully logged in.

Example:
```
$SearchRule Min 3$$Max 256$$Num 1$$Int 4$$IntPas 6$$Share 10737418240|
```

`Min` specifies minimum search string length (`min_query`).

`Max` specifies maximum search command length (`max_query`).

`Num` specifies number of searches available for use during a period of time (`max_req`).

`Int` specifies the period itself in seconds (`interval_active`) for active search requests for current user profile.

`IntPas` specifies the period in seconds (`interval_passive`) for passive search requests for current user profile.

`Share` specifies minimum share size in bytes (`min_share`) required for search for current user profile.

Not all of the above parameters must be specified, the list is based on hub configuration.

Client has a chance to automatically update its search interval settings for each hub, compare its share size with required size and prepare other kind of actions before sending any search request commands.

`Int` and `IntPas` might be set to `0` which means that user is actually allowed to search without time limit, and might be set to `-1` which means that user is not allowed to use search at all due to low profile or any other kind of restrictions.

Meaning of this extension is to avoid extra search requests to the hub, which are not going to bring any search results to the client anyway.

Add `SearchRule` to the `$Supports` to indicate support for this.

### `FeaturedNetworks`
`$FeaturedNetworks` is a protocol extension of the APN MultiHubChatsystem to identify the different hubs and other entry points (IRC, Telnet) etc. It was primarily created to aid APN developers and to allow a better integration of multi hub chat systems.

Messages coming through the chat network are prefixed with an unique network node (entry point) identifier, normally three characters long. The central point of the chat network is a single hub that collects chat messages from one entry point and sends them back all other entry points.

Add `FeaturedNetworks` to the `$Supports` to indicate support for this.

Syntax

An APN MultiHubChat message normally has this format:

```
<(YYY)XXXXX> MMMMMMM|
```

Where `YYY` is the entry point prefix, `XXXXX` is the username and `MMMMMMM` is the message.

To allow the different entry point handlers to identify which messages are coming from other multi hub chat entry points, there is a command send by the hub after login called `FeaturedNetworks`:

```
$FeaturedNetworks YYY$$YYY$YYY$$|
```

`YYY` stands for one entry point to the chat network. In the biggest currently running instance of the APN MultiHubChat system, five or more different prefixes are used.

#### Implementation

If implemented, this command could be sent from one of the entry point hubs aswell to aid the client in distinguishing user set prefixes (`[BBB]`, `[psv]`, `(FUG)` etc..) from network prefixes, and can be used by bots to detect prefix abuse.

The prefixes are to be defined by the network administrator. In the biggest running instance of the network however, the following prefixes are used by several MHC plugins for the different entry points:

* `APx` - Hub x (DC, where `x` is `Â¹`,`Â³` or `Â²`).
* `APt` - Telnet Access (Telnet Chat Plugin)
* `IRC` - IRC Access (IRC plugin)
* `APs` - Shoutcast (Shoutcast Announcer Plugin)

`$FeaturedNetworks` can be implemented by virtually any hub by either using the MHC bot or by injecting it into the server ? client stream using a textfile (like a MOTD).

### `$GetZBlock`
```
$UGetBlock start bytes filename|
```

Contexts: C-C
 
`start` is the 0-based (yes, 0-based, not like get that's 1-based) starting index of the file used

`bytes` is the number of bytes to send

`filename` is the filename. 

The other client then responds `$Sending <bytes>|<compressed data>`, if the sending is ok or `$Failed <errordescription>|` if it isn't.

If everything's ok, the data is sent until the whole uncompressed length has been sent. `bytes` specifies how many uncompressed bytes will be sent, not compressed, as the sending client doesn't know how well the file will compress. [`$Sending`](#sending) is needed to be able to distinguish the failure command from file data. Only one roundtrip is done for each block though, minimizing the need for maintaining states.

Compression: Compression is done using ZLib (v 1.1.4 in DC++ 0.21's case), 
using dynamic compression level. The compression level can of course be 
changed by the implementator to reduce CPU usage, or even just store 
compression in the case of non-compressible files, which then works as 
adler32 check of the transferred data.

Support of `$GetZBlock` also implies support for [`$UGetBlock`](#ugetblock).

### `$UGetBlock`
```
$UGetBlock start bytes filename|
```

Contexts: C-C

This is the same command as [`$GetZBlock`](#getzblock) except this command is uncompressed and the filename is UTF-8 encoded.

The `filename` is encoded as UTF-8, which allows filenames to use characters that are not in the system's encoding. `$UGetBlock` must be implemented if [`XmlBZList`](#xmlbzlist) is advertised.

### `$UGetZBlock`
This is the same as [`$UGetBlock`](#ugetblock) except that the stream is compressed.

### `$Sending`
```
$Sending diff|
```

Contexts: C-C

`diff` is the difference between the end byte and start byte. If the requested bytes was `-1` then diff should be omitted.

This is sent as a response to [`$GetZBlock`](#getzblock), [`$UGetBlock`](#ugetblock) and [`$UGetZBlock`](#ugetzblock).

The start and end byte are 0-based; the first byte of a file is assumed to be the byte number 0.

### `ChatOnly`
Contexts: C-H

This indicates that the client only support chat capabilities to allow the client to bypass hub rules (that relate to file sharing). The client should be disconnected if it sends a [`$Search`](#search), [`$ConnectToMe`](#connecttome) or [`$RevConnectToMe`](#revconnecttome).

Add `ChatOnly` to the `$Supports` to indicate support for this.

### `Minislots`
This allows the other client to use a free slot for small files / file list. 

`$Supports` is needed because the Neo-Modus DC client closes the file list browser when the connection is broken, which it becomes when the client on the other side tries to download its first file and fails because it has no real slot.

Add `Minislots` to the `$Supports` to indicate support for this.

### `TTHL`

Supporting this means supporting the upload of tth leaf data. Instead
of transferring the file itself, the TTH data of all leaves is transferred
in binary. The size transferred back is the number of bytes of leaf data,
from this and the file size the receiving client can calculate which
level (tree depth) the sending client is offering. The receiver should
obviosly check that the received leaf data is correct by rebuilding the
tree and checking that it's recorded root matches.

Add `TTHL` to the `$Supports` to indicate support for this.

### `TTHS` (`$SA` and `$SP`)
```
$SA tth ip:port|
$SP tth nick|
```
Contexts: C-H-C

This extension adds support for short TTH search commands. Not to be confused with [`TTHSearch`](#tthsearch) extension.

Add `TTHS` to the `$Supports` to indicate support for this.

Examples:

Active search request:
```
$SA LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ 1.2.3.4:412|
```

Passive search request
```
$SP LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ user|
```

Difference between old and new TTH search commands:
```
$Search 1.2.3.4:5 F?T?0?9?TTH:LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ|
$SA LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ 1.2.3.4:5|
```
70 vs 54 bytes for active command.

```
$Search Hub:user F?T?0?9?TTH:LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ|
$SP LWPNACQDBZRYXW3VHJVCJ64QBZNGHOHHHZWCLNQ user|
```
70 vs 50 bytes for passive command.

Meaning of this extension is to save some server upload bandwidth by shortening down the most frequently sent command in outgoing protocol of a hub.

### `ZLIG`

Supporting this means that zlib compressed [`ADCGet`](#adcget) transfers are supported.

Add `ZLIG` to the `$Supports` to indicate support for this.

### `ACTM`
Advanced Connect To Me (`ACTM`) is a replacement for the [`$ConnectToMe`](#connecttome) and [`$RevConnectToMe`](#revconnecttome) commands.

Add `ACTM` to the `$Supports` to indicate support for this.

Implementations supporting `ACTM` must reply to incoming [`$ConnectToMe`](#connecttome) and [`$RevConnectToMe`](#revconnecttome) requests, but will themselves always send [`$CTM`](#ctm) or [`$RCTM`](#rctm).

During requests, the clients send a 4-digit hexadecimmal ID. This ID is an incremental number that is given out for each [`$CTM`](#ctm) that it sent. When a connection between two clients is established, the other party must echo back this 4-digit ID. This is done after `$Supports` but before [`$Direction`](#direction). If the 4-digit ID is not any of the unhandled IDs given out by the requesting client, it must signal `$Error Invalid ID` and disconnect.

#### `$CTM`
```
$CTM client2_nick$client1_port$id|
$CTM client1_ip$client1_port$id|
$CTM id|
```

Contexts: C-H-C, C-C

Client 1 to hub:
```
$CTM client2_nick$client1_port$id|
```
Hub forwarding to client 2:
```
$CTM client1_ip$client1_port$id|
```
Client 2 to client 1:
```
$CTM id|
```

#### `$RCTM`
```
$RCTM client2_nick|
```

Contexts: C-H-C

Client 1 to hub:
```
$RCTM client2_nick|
```
Hub forwarding to client 2:
```
$RCTM client1_nick|
```
Client 2 to hub:
```
$CTM client1_nick$client2_port$id|
```
Hub forwarding to client 1:
```
$CTM client2_ip$client2_port$id|
```

Example handshake:

|Client party |Server party
|--- |---
| | `$MyNick peter\| `
| | `$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk=DCPLUSPLUS0.668ABCABC\|`
| `$MyNick john\|` |
| `$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk DCPLUSPLUS0.668ABCABC\|` |
| | `$Supports MiniSlots XmlBZList ADCGet TTHL TTHF ACTM GetZBlock ZLIG\|`
| | `$Direction Download 17762\|`
| | `$Key ...\|`
| `$Supports MiniSlots XmlBZList ADCGet TTHL TTHF ACTM GetZBlock ZLIG\|` |
| `$CTM A91E\|` |
| `$Direction Upload 6494\|` |
| `$Key ...\|` |
| | `$Get files.xml.bz2$1\|`

### `BZList`
Signals support for BZIP2 compressed file list instead of the Huffman encoded list that NMDC pioneered. The compressed file list is available for download under the name `MyList.bz2` instead of `MyList.DcLst` and `files.xml.bz2` instead of `files.xml`.

Add `BZList` to the `$Supports` to indicate support for this.

### `OpPlus`
Characteristics of a hub. Indicates that the hub uses additional commands for operators.
For example: `$Ban`, `$TempBan`, `$UnBan`, `$GetBanList`, `$WhoIP`, `$Banned`, `$GetTopic`, `$SetTopic` and more.

### `Feed`
This feature offers additional protocol commands notice. Feature allows you to track all the actions of the individual or all users benefit from logging these actions, and notify operators of the hub acts committed by a newly created chat room.

### `IPv4`
This feature is used to indicate IPv4 support when a client is connecting from a IPv6 address. 

The hub should send a [`$ConnectToMe`](#connecttome) to the client, to indicate a download from the hub. The client will connect to the hub address and port as in a normal client to client connection, this time using the client's IPv4 address. The hub should disconnect after it has received the [`$MyNick`](#mynick) command.

The hub should later verify in connection attempts with other IPv4 clients that the IPv4 address matches.

Once the hub has received an IPv4 connection and gathered the IPv4 address, it should set the IPv4 bit in the [`$MyINFO`](#myinfo) command.

Add `IPv4` to the `$Supports` to indicate support for this.

### IPv6
This feature is used to indicate IPv6 support.

IPv6 addresses are specified in [RFC 4291](https://tools.ietf.org/html/rfc4291) form.

If the client has an IPv4 connection, it should also signal the use of IPv4. Clients should use the same TCP and UDP ports for both IPv4 and IPv6 if both are supported. The connection mode (passive, active, SOCKS5) can be different.

The hub is required to set the IPv6 bit in the [`$MyINFO`](#myinfo) command.

The connection mode in the [`$MyINFO`](#myinfo) tag changes from `M:X` where `X` is the connection mode (`A` = Active, `B` = Passive, `5` = SOCKS5) to `M:XY` where `X` is the connection mode of IPv4 and `Y` is the connection mode of IPv6. If a client does not support IPv4 or the IPv4 check failed, the first character will be `N` for not supported.

Add `IP64` to the `$Supports` to indicate support for this.

A client that support IPv4 and IPv6 will only use one form when sending messages to a hub. The hub is responsible for translating the command into the correct IPv4/IPv6 address. E.g., if a [`$Search`](#search) is sent with a IPv6 address, the hub will send the client's IPv4 address to those who only support IPv4. This minimizes the amount of traffic toward the hub. If a client sent a passive search request, then it is only sent to active users supporting the same TCP/IP protocol. This is regardless if the client is active in the other protocol. I.e., if a passive search request is sent with a IPv4 address, that search request will only be forwarded to IPv4 users and not 'converted' to an IPv6 request, regardless if the client is active in IPv6.

### NAT traversal

The purpose of this extension is to allow connections between two passive clients in NMDC protocol.

<!-- FIXME: clarify the flag -->

Client advertises the support as a flag `0x20` in [`$MyINFO`](#myinfo).

When passive client A wants to make connection with remote client B, it sends standard `$RevConnectToMe` command. When remote client B is passive too, it will respond to it with:

```
$ConnectToMe <A's nick> <B's IP>:<port>N <B's nick>|
```

where `<port>` is the outbound port to the connected hub. Character `N` is appended to this port number, `NS` for TLS connection. When client A receives it, it tries to connect to specified `IP:port` and responds to B with:

```
$ConnectToMe <B's nick> <A's IP>:<port>R|
```

where `<port>` is again the outbound port to the connected hub. Character `R` is appended, `RS` for TLS connection. When client B receives it, it tries to connect to specified `IP:port`.

### DHT
This feature is used to indicate support for Distributed Hash Tables (DHT) for client-client connections. 

This feature uses ADC commands for the DHT swarm [StrongDC++ DHT](http://strongdc.sourceforge.net/download/StrongDC_DHT.pdf).

Add `DHT0` to the `$Supports` to indicate support for this.

### Queue position
```
$MaxedOut queue_position|
```

Contexts: C-C

This feature is a support for a queue numbering system for client-client connections. See [ADC-Ext QP](http://adc.sourceforge.net/ADC-EXT.html#_qp_upload_queue_notification) for further information on the ADC equivalent.

This feature extends [`$MaxedOut`](#maxedout) by adding a number after it.

Note that there is no feature to announce in `$Supports`.

Example:
```
$MaxedOut 2|
```

### FailOver
```
$FailOver [host[,host]]|
```

Contexts: H-C

This feature is used to indicate support for providing alternative hub addresses in the event that the hub is unavailable. See [ADC-Ext FO](http://adc.sourceforge.net/ADC-EXT.html#_fo_failover_hub_addresses) for further information on the ADC equivalent.

Used a comma (`,`) to separate hub addresses.

The command can be sent at any time by the hub, overwriting or replacing the addresses of the previous command. An empty command (no hosts) clears the list of alternative addresses.

Add `FailOver` to the `$Supports` to indicate support for this.

Examples:
```
$FailOver|
$FailOver example.com:412|
$FailOver example.com,example.org:5555,adc://example.net:6666|
```

### Hub icon (`$SetIcon` and `$SetLogo`)
```
$SetIcon image_uri|
$SetLogo image_uri|
```

Contexts: H-P, H-C

This feature specifies hub icon URL to display on hublist or hub tab in some clients.

The `image_uri` is an URI linking to the image that should be used. The URI is specified with `http://`, `https://` or `www.` prefix.

The display size of icon must be relatively small. Some hublists downsize the icon to maximum of 16x16 pixels.

For security reason only `image/*` MIME types can be used.

Hubs that send this also support [`$HubINFO`](#hubinfo).

Examples:
```
$SetIcon www.example.com/images/myimage.ico|
$SetIcon http://hub.example.org/img/image.ico|
```

Hub can also send `$SetLogo` command to set hub logotype. Similar rules apply to this command, except that image display size is not limited, it's up to hublist to downsize the image to any size that fits best on hub information page.

Example:
```
$SetLogo https://hub.example.org/img/logo.png|
```

Both commands are usually sent at the same time before [`$HubINFO`](#hubinfo) command, because usually hublist pingers disconnect from the hub right after they receive the [`$HubINFO`](#hubinfo) command, that way they will not miss image links. This extension should be strengthened with some kind of support flag, but that is yet to accomplish.

## Deprecated extensions

Extensions in this section were deprecated or never became standard in clients and/or hubs.
The section serves only as a history reference. Those extensions should not be supported.

### `$Capabilities`
```
$Capabilities [unknown]|
```

Contexts: H-C

This command is used to negotiate and notify about protocol extensions, similar to the more popular `$Supports`. Its content is unknown as of date.

### `$IN`
```
$IN nick$data[$data]|
```

Contexts: C-H, H-C

This command is designed to replace the static [`$MyINFO`](#myinfo). This command consist of separate smaller parts which all have a 1-byte identifier and are separated by a dollar sign (`$`).

If a client wishes to remove a part of its `$IN` (say for example its description), it must send this parts identifier immediatly followed by the dollar sign (`$`), indicating it is empty.

The order in which parts are sent is free to choose, but tag parts should be grouped together.

Add `IN` to the `$Supports` to indicate support for this.

This command was meant to deprecate [`$OpList`](#oplist) and [`$BotList`](#botlist).

A client tag has only one identifier indicating it is concerning the tag, but all parts of this tag also have their own 1-byte identifier. In the tag, the parts are delimited with a space (` `).

The data consist of two elements: identifier and its data.

The following table lists the identifiers:

| Identifier (character code) | Description
|--- |---
| `D` (`68`) | Description
| `T` (`84`) | Tag
| `C` (`67`) | Connection
| `F` (`70`) | Status flag
| `E` (`69`) | E-mail address
| `S` (`83`) | Share size in bytes

Examples:
```
$IN john$Dmy_new_description|
$IN john$S1024|
$IN john$S1024$$Dmy_new_description|
```

The tag has the following identifiers in the data:

| Identifier (character code) | Description
|--- |---
| `c` (`99`) | Client
| `v` (`118`) | Version
| `m` (`109`) | Mode
| `h` (`104`) | Hub count, `x/y/z` (where `x` is the number of hubs as a normal user, `y` as the number of hubs as registered and `z` as the number of hubs as operator)
| `s` (`115`) | Slots
| `f` (`102`) | Free slots
| `l` (`108`) | Bandwidth limit (`L:` and `B:` in `$MyINFO`)
| `o` (`111`) | `O:` in `$MyINFO`
| `r` (`114`) | `R:` in `$MyINFO`

Tag identifiers are separated by a space (` `).

Examples:
```
$IN john$Ts3|
$IN john$Tc++ v0.666|
```

The status is a 32-bit integers where the bits are according to the following table:

| Bit | Description
|--- |---
| 1 | Default value
| 2 | User is away
| 3 | USer is server
| 4 | User is fireball
| 5 | User is OP
| 6 | Client is a bot
| 7 | Client is in DND mode
| 8 | Client support encryption
| 9 | Client supports partial search

Bit 5 and Bit 6 of the 32-bit status flag are used to indicate wether a user is an OP or wether the `$IN` string send by the hubsoft belongs to a bot. These values are read-only and should never be changed by a client. The hubsoft must disconnect for this. If a client connects and has successfully logged in with the correct password, the hubsoft will set bit 5 of the status flag and sends this part to all connected users, including the newly connected OP. The connecting client must save the status flag it received from the hub and use it when updating status such as away and fireball. However, as said, it is not allowed to set or reset bit 5 and bit 6 of the status flag.

Bit 7 of the 32-bit status flag indicates if the client is in DND-mode (Do-Not-Disturb). Unlike Away mode, this mode will prevent the client to receive any pm's. Clients are responsible themselves for setting/resetting this bit. Once this bit is set, and the hub receives a `$To:` string for a client in DND-mode, the hub must ignore the [`$To`](#to) and reply to the sender with a message that the receiver is in DND-Mode. A client having this bit set, should automatically reset this bit when sending a pm itself. Ideally, newer clients supporting `IN`, may prevent themselves from sending [`$To`](#to) strings to other clients having this bit set. The hub will always have the last the say in forwarding a PM or not. [`$To`](#to) strings generated by the hubsoft to the client are not included in this and will be send regardlessly of status ( i.e. messages from bots ).

Although the extension has a good design, it was never supported by most clients/hubs.
The extension is no longer seen in the wild.

### `$Z`
```
$Z blob|
```

Contexts: H-C

This command's intention was to compress (with ZLib) data to decrease bandwidth use.
The `blob` uncompressed is one or more commands, e.g. a [`$Search`](#search) followed by a [`$MyINFO`](#myinfo).

`ZLine` in the `$Supports` indicated support for this.

The command added an escaping sequence:

| Character | Escape
|--- |---
| ` \ ` | `\\`
| `\|` | `\P`

Because an additional escaping was needed, this command was superseded by [`$ZOn`](#zon).
that doesn't require any escaping.

### `CHUNK`
This is a protocol extension by Valknut that allows retrieval of sections of a file through a modified [`$Get`](#get) syntax. The syntax is:
```
$Get <filename>$<start-position>$<chunk-size>|
```

Superseded by [`ADCGet`](#adcget).

Add `CHUNK` to the `$Supports` to indicate support for this.

### `$GetTestZBlock`
This command is deprecated and was a test command during the development of [`$GetZBlock`](#getzblock).

Implementations should not use this command.

### `ClientID`
Extension was designed to add support for ADC CIDs to NMDC protocol, but the extension was not adopted.

It adds two additional commands: `$ClientID` and `$GetCID`.

Add `ClientID` to the `$Supports` to indicate support for this.

### `QuickList`
This extension clarifies the protocol flow, defines the protocol stages and allowed commands
in each of them.

Although the good design, extension was not adopted as-is. Some parts of the extension
might be implemented in hubs. 

The extension should not be listed in `$Supports` since some hubs may drop the connection
when seeing it.

The terms "NDC" and "NHUB" are used below to denote a client or hub not featuring `QuickList`
and "QDC" and "QHUB" for those that do. The term "DC" is used when the type is not yet
established or of no importance. EACH and ALL signals that a message is sent N times, one
message for each connected user. Also note that the terms IF, MAY, SHOULD and MUST, have
the same meaning as in the internet RFC specs.

#### Walkthrough

##### Connecting

| Description
|---
| A DC connects to QHUB and does nothing
| QHUB sends [`$Lock`](#lock) which starts with `EXTENDEDPROTOCOL`
| QHUB also sends [`$HubName`](#hubname)
| A DC must send [`$Key`](#key)
| A DC may also send `$Supports QuickList\|` to signal in is in fact a QDC
| QHUB responds with `$Supports QuickList\|`

##### Identification

| Description
|---
| A QDC may but should not send [`$Version`](#version)
| A QDC must send [`$MyINFO`](#myinfo)

##### Authentication

| Description
|---
| QHUB may send [`$GetPass`](#getpass)
| QDC responds with [`$MyPass`](#mypass)
| QHUB may send [`$BadPass`](#badpass) and disconnect
| QHUB may send [`$ValidateDenide`](#validatedenide) and disconnect


##### Acceptance

| Description
|---
| QHUB may send [`$LogedIn`](#logedin) to signal that `H:` should not be incremented
| QHUB sends all clients [`$MyINFO`](#myinfo) to the QDC
| QHUB sends [`$OpList`](#oplist) to the QDC
| QHUB may send [`$Hello`](#hello) to all clients but should send it to non QDC only
| QHUB sends [`$MyINFO`](#myinfo) to all QDC clients

#### Explanation

##### Connecting

This part has been through some changes. There was an argument of having the client start with `$Supports` and then having the hub respond to that. Having the client start with `$Supports` as a response to `EXTENDEDPROTOCOL` is in a sense much cleaner.

* It has been found that [`$HubName`](#hubname) can be sent pretty much at any time. Typically done in conjunction with [`$Lock`](#lock).

* `$Supports` are in the same format as in the client protocol; `$Supports <feat1> <feat2> <feat3>|`

##### Identification

* sending [`$MyPass`](#mypass) early has been removed from the spec.

##### Authentication

* As previously mentioned [`$GetPass`](#getpass) is only sent if the user has an account and the [`$MyPass`](#mypass) was not sent in the identification process. [`$BadPass`](#badpass) or [`$ValidateDenide`](#validatedenide) is sent when proper as usual.

##### Acceptance

From testing it has been found that [`$Hello`](#hello) and [`$MyINFO`](#myinfo) can be sent together without having to wait for a [`$GetINFO`](#getinfo).

* Let the hub decide if the account should be treated as a VIP, i.e. not increment `H:` in the tag, hence it is not mandatory for accounts. A QDC should only respond to this message for account logins only.

* [`$OpList`](#oplist) was missing.

#### Commands Sent

Connecting
* `$Lock`
* `$HubName`
* `$Supports`

Identification

Authentication
* `$GetPass`
* `$BadPass`
* `$ValidateDenide`

Acceptance
* `$LogedIn`
* `$MyINFO`
* `$MyINFO stream`

Connected
* `$To`
* `$Search`
* `$SR`
* `$ConnectToMe`
* `$RevConnectToMe`
* `$ForceMove`

#### Commands Accepted

Messages that a QHUB listens to in each state, QHUB ignores otherwise;

Connecting
* `$Key`
* `$Supports`

Identification
* `$Version`
* `$MyINFO`

Authentication
* `$MyPass`

Acceptance

Connected
* `$GetNickList`
* `$MyINFO`
* `$To`
* `$Search`
* `$SR`
* `$ConnectToMe`
* `$RevConnectToMe`
* `$Kick`
* `$OpForceMove`

Notes
* `$ValidateNick` deprecated and ignored
* `$GetNickList` only valid when connected, a QDC does not receive a `$NickList`, but a series of `$MyINFO`s directly.
* `$Hello` deprecated and ignored
* `$GetINFO` deprecated and ignored
* `$MyINFO` is always accepted as valid and denotes a new or updated client.

## Examples
### Client – Hub connection

See respective command for description of command and parameters.

| Client | Hub
|--- |---
| | `$Lock EXTENDEDPROTOCOL_verlihub Pk=version0.9.8e-r2\|`
| `$Supports UserCommand UserIP2 TTHSearch ZPipe0 GetZBlock\|` |
| `$Key 011010110110010101111001\|` |
| `$ValidateNick johndoe\|` |
| | `<VerliHub> This hub is running version 0.9.8e-r2 (Monday Jul 20 2009) of VerliHub (RunTime: 2weeks 1hours  / Current user count: 4)\|`
| | `<VerliHub> This hub is enhanced by plugman for Verlihub.\|`
| | `$Supports OpPlus NoGetINFO NoHello UserIP2 HubINFO\|`
| | `$HubName Verlihub\|`
| | `$GetPass\|`
| `$MyPass mysecurepass55555\|` |
| | `$Hello johndoe\|`
| `$Version 1,0091\|` |
| `$GetNickList\|` |
| `$MyINFO $ALL johndoe <++ V:0.673,M:P,H:0/1/0,S:2>$ $LAN(T3)0x31$example@example.com$1234$\|` |
| | `$LogedIn johndoe\|`
| | `$NickList Bot$$TestNick$$aaa$$VerliHub$$bbb$$OpChat$$\|`
| | `<MOTD> This is the MOTD message.\|`
| | `$HubTopic The topic of the hub is not set.\|`
| | `$OpList TestNick$$aaa$$bbb$$VerliHub$$OpChat$$\|`
| | `$BotList Bot$$VerliHub$$OpChat$$\|`


### Client – Client connection

Note the connecting client is the client, but that the server speaks first.

See respective command for description of command and parameters.

| Client | Server
|--- |---
| | `$MyNick bbb\|`
| `$MyNick aaa\|` |
| `$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk=DCPLUSPLUS0.706ABCABC\|` |
| | `$Lock EXTENDEDPROTOCOLABCABCABCABCABCABC Pk=DCPLUSPLUS0.777Ref=dchub://example.org:411\|`
| `$Supports MiniSlots XmlBZList ADCGet TTHL TTHF ZLIG\|` |
| `$Direction Download 31604\|` |
| `$Key 011010110110010101111001\|` |
| | `$Supports MiniSlots XmlBZList ADCGet TTHL TTHF ZLIG\|`
| | `$Direction Upload 82\|`
| | `$Key 011010110110010101111001\|`
| `$ADCGET file files.xml.bz2 0 -1 ZL1\|` |
| | `$ADCSND file files.xml.bz2 0 29725 ZL1\|`

## License

This document is licensed under the New BSD License (3-clause BSD license).

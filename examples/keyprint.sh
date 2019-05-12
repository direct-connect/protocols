#!/usr/bin/env bash
openssl x509 -noout -fingerprint -sha256 < "$1" | cut -d '=' -f 2 | tr -dc "[A-F][0-9]" | xxd -r -p | base32 | tr -d "="
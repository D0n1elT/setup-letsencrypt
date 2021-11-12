#!/bin/bash

FQDN="$1"
FQDNunderscores="$(echo $FQDN | sed 's/\./_/g')"

base="$(pwd)"

test -d "$base/private" || mkdir -p "$base/private"

if [ -f "$base/private/${FQDNunderscores}.key" ]; then
        openssl  req  -config "$base/openssl::${FQDNunderscores}.cnf" \
                      -nodes  -new \
                      -key "$base/private/${FQDNunderscores}.key" \
                  -out "$base/${FQDNunderscores}.csr"
else
    openssl  req  -config "$base/openssl::${FQDNunderscores}.cnf" \
                  -nodes  -new \
                  -keyout "$base/private/${FQDNunderscores}.key" \
                  -out "$base/${FQDNunderscores}.csr"
fi

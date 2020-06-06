#!/bin/bash

# We might not need this after all, should try to get openssl version working, similar to:
# openssl pkey -pubin -in pubkey.pem -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64

#############################################################
# PEM public key -> raw key extractor for use in CommonCrypto
#############################################################
# Motivation
# Packages containing keys the app downloads hashed on the server,
# and that hash is signed with the server's private key.
# We use the server's public key to decrypt that hash and compare
# it against a hash of the .bin data.
# This way we can ensure that the data was not tampered with.
#
# We use SecKeyCreateWithData(_:_:_:) to obtain a SecKey,
# for use in the decryption process.
#
# However it does not seem easily possible to use PEM files
# on iOS in a plug and play manner.
# It seems that SecKeyCreateWithData(_:_:_:) needs the key
# in its raw format.
#
# This script automates the obtaining of the raw key so it can be
# embedded in the code and read with SecKeyCreateWithData(_:_:_:)
#
# HOW TO USE
# Quick and dirty:
# ./pemToRawKey.sh <your pem file>
# 
# EXPECTED PEM FILE FORMAT:
#
#-----BEGIN PUBLIC KEY-----
#     <base64KeyHere>
#-----END PUBLIC KEY-----
#

FILE_NAME=$1
DER_FILE="pubkey.der"
RAW_KEY_DER="rawkey.der"

# Strip PEM header & footer
# Also base64 decode & save as .der file
sed '1d; $d' $FILE_NAME | base64 -D -o $DER_FILE
  
# Extract the bitstring and re-encode in base64
# 26 is a magic number here, might not work for all keys.
# This is an offset, and is the byte offset where the bitstring starts 
dd skip=26 if=$DER_FILE of=$RAW_KEY_DER bs=1  

echo 
echo "Embed this raw key in the code for use with SecKeyCreateWithData(_:_:_:)"
echo $(base64 $RAW_KEY_DER)
  
# To verify that the script did the right thing, do the following:  
# dumpasn1 <your pem>
# ^ This shows you the offset of the bistring & the actual bitstring
# hexdump -Cv <der file>  
# ^ compare the hexdump to see if there is a match 

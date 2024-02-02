#!/bin/bash
#Create a random password of random characters from different categories to create a complex password.

choose() { echo ${1:RANDOM%${#1}:1} $RANDOM; }

{
    choose '!@#$%^\&'
    choose '0123456789'
    choose 'abcdefghijklmnopqrstuvwxyz'
    choose 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for i in $( seq 1 $(( 4 + RANDOM % 8 )) )
    do
        choose '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    done

} | sort -R | awk '{printf "%s",$1}'
echo ""

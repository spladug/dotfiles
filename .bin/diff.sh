#!/bin/bash

case $OSTYPE in 
    linux-gnu)
        meld $2 $5
        ;;
    darwin*)
        opendiff "$2" "$5" -merge "$2"
        ;;
esac

#!/bin/bash

case $1/$2 in
    pre/*)
        case $2 in
            suspend|hibernate)
                loginctl lock-session
                sleep 1
                ;;
            esac
        ;;
esac

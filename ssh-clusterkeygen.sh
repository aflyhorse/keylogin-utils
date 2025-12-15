#!/bin/sh

if [ ! -f $HOME/.ssh/id_ed25519 ] ; then
    ssh-keygen -q -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ''
    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    chmod g-w,o-w ~/.ssh ~/.ssh/authorized_keys
fi

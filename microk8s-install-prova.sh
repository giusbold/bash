#!/bin/bash

# Funzione per gestire l'errore durante l'installazione di MicroK8s
handle_installation_error() {
    echo "Si è verificato un errore durante l'installazione di MicroK8s."
    echo "Assicurati che i requisiti siano soddisfatti e riprova."
    exit 1
}

# Funzione per gestire gli errori durante l'installazione degli addon
handle_addon_error() {
    local addon_name=$1
    echo "Si è verificato un errore durante l'abilitazione di $addon_name."
    echo "Assicurati che MicroK8s sia stato installato correttamente e riprova."
    exit 1
}

# Funzione per abilitare un addon con gestione degli errori
enable_addon() {
    local addon_name=$1
    echo "Abilitazione addon: $addon_name"
    microk8s enable $addon_name || handle_addon_error $addon_name
    echo "Addon $addon_name è stato abilitato correttamente."
}

# Blocco "try" per l'installazione di MicroK8s
{
    echo "Hello $(whoami)"

    # Mi sposto nella home
    cd

    # Verifica se MicroK8s è già installato
    if command -v microk8s &>/dev/null; then
        echo "MicroK8s è già installato."
    else
        echo "MicroK8s non è installato. Avvio l'installazione..."   

    # Installa MicroK8s in background
    (snap install microk8s --classic) || handle_installation_error

    # Imposta le autorizzazioni e l'alias per kubectl
    usermod -a -G microk8s $USER
    newgrp microk8s
    chown -f -R $USER ~/.kube
    alias kubectl='microk8s kubectl'

    echo "MicroK8s è stato installato correttamente."

    fi
    
    # Abilita l'addon DNS
    {
        enable_addon dns
    } || {
        handle_addon_error "DNS"
    }

    # Abilita l'addon Ingress
    {
        enable_addon ingress
    } || {
        handle_addon_error "Ingress"
    }

    # Abilita l'addon Dashboard
    {
        enable_addon dashboard
    } || {
        handle_addon_error "Dashboard"
    }

    # Abilita l'addon HostPath Storage
    {
        enable_addon hostpath-storage
    } || {
        handle_addon_error "HostPath Storage"
    }

} || {
    # Gestione degli errori durante l'installazione di MicroK8s
    handle_installation_error
}

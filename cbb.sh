#!/bin/bash

export PATH="$PATH:/C/Program Files/Docker/Docker/resources/bin"
export Namespace="hcce"
export ADM_EMAIL="admin@example.net"
export HUB_DOMAIN="localhost"

function cbb(){
    read -p "Press enter to continue for <$1>"
    kubectl -n $Namespace delete pod certbotbot-http
    HUB_DOMAIN=$1 envsubst < "cbb.yam" > "cbb.yaml" && kubectl apply -f cbb.yaml
    while true; do
        sleep 10
        STATUS=$(kubectl get pod 'certbotbot-http' -n $Namespace --no-headers -o custom-columns=STATUS:.status.phase 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            echo "ERROR -- certbotbot-http pod is missing"
            exit 1;
        elif [[ $STATUS == "Running" ]]; then
            echo -n "."
        elif [[ $STATUS == "Succeeded" ]]; then
            echo ":"
            kubectl -n $Namespace get secret cert-$1
            return;
        else
            echo "bad pod status: $STATUS"
            return
        fi
    done
}

cbb $HUB_DOMAIN
cbb "assets.$HUB_DOMAIN"
cbb "stream.$HUB_DOMAIN"
cbb "cors.$HUB_DOMAIN"

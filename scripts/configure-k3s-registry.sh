#!/usr/bin/env bash
# TICKET-02 : autorise k3s (containerd) à pull depuis le registre interne en
# HTTP simple (pas de TLS — acceptable pour ce POC, à revoir avant toute
# vraie mise en production, voir docs/03-scope.md).
# À exécuter directement dans un terminal : modifie /etc/rancher/k3s/ (sudo)
# et redémarre le service k3s.
set -euo pipefail

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

if ! command -v k3s >/dev/null 2>&1; then
  echo "k3s introuvable — lance d'abord scripts/install-k3s.sh (TICKET-01)." >&2
  exit 1
fi

NODE_IP=$(k3s kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' | awk '{print $1}')
if [[ -z "${NODE_IP}" ]]; then
  echo "Impossible de déterminer l'IP du nœud." >&2
  exit 1
fi
REGISTRY="${NODE_IP}:30500"
echo "Registre ciblé : ${REGISTRY}"

echo
echo "--- Droits administrateur ---"
echo "Écriture de /etc/rancher/k3s/registries.yaml + redémarrage du service k3s : besoin de sudo."
if ! sudo -v; then
  echo "Impossible d'obtenir les droits sudo — annulé." >&2
  exit 1
fi

sudo mkdir -p /etc/rancher/k3s
sudo tee /etc/rancher/k3s/registries.yaml > /dev/null <<EOF
mirrors:
  "${REGISTRY}":
    endpoint:
      - "http://${REGISTRY}"
EOF

echo
echo "--- Redémarrage de k3s pour appliquer la config ---"
sudo systemctl restart k3s

echo
echo "--- Attente que le nœud repasse Ready ---"
ready=false
for _ in $(seq 1 30); do
  if k3s kubectl get nodes 2>/dev/null | grep -q " Ready"; then
    ready=true
    break
  fi
  sleep 2
done

if [[ "${ready}" != "true" ]]; then
  echo "Le nœud n'est pas repassé Ready après 60s — vérifie 'sudo journalctl -u k3s -n 50 --no-pager'." >&2
  exit 1
fi

k3s kubectl get nodes
echo
echo "k3s est configuré pour pull en HTTP depuis ${REGISTRY}."
echo "Les manifestes de déploiement pourront référencer des images en '${REGISTRY}/<image>:<tag>'."

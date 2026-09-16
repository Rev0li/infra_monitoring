#!/usr/bin/env bash
# TICKET-01 : installe k3s (Kubernetes single-node) sur cette VM.
# À exécuter directement dans un terminal (pas via un outil non-interactif) :
# il a besoin de pouvoir te demander ton mot de passe sudo.
set -euo pipefail

echo "=== TICKET-01 : installation de k3s ==="
echo

# --- Pré-requis ---
echo "--- Pré-requis ---"
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Ce script est prévu pour Linux uniquement (OS détecté : $(uname -s))." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
echo "OS       : ${PRETTY_NAME:-inconnu}"
echo "CPU      : $(nproc) vCPU"
echo "RAM      : $(free -h | awk '/^Mem:/ {print $2 " (dont " $7 " disponible)"}')"
echo "Disque / : $(df -h / | awk 'NR==2 {print $4 " disponible"}')"
echo

if command -v k3s >/dev/null 2>&1; then
  echo "k3s est déjà installé : $(k3s --version | head -1)"
  echo "Rien à faire. (Supprime k3s avec /usr/local/bin/k3s-uninstall.sh si tu veux réinstaller.)"
  exit 0
fi

# --- Droits sudo ---
if [[ "${EUID}" -ne 0 ]]; then
  echo "--- Droits administrateur ---"
  echo "k3s s'installe comme service système (systemd) : il faut les droits sudo."
  echo "L'installateur va demander ton mot de passe plusieurs fois pendant l'install —"
  echo "c'est normal, on le met en cache une bonne fois pour toutes ici :"
  echo
  if ! sudo -v; then
    echo "Impossible d'obtenir les droits sudo — installation annulée." >&2
    exit 1
  fi
  echo
fi

# --- Installation ---
echo "--- Installation de k3s (télécharge et exécute l'installateur officiel Rancher) ---"
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -

# --- Attente que le nœud soit prêt ---
echo
echo "--- Attente que le nœud soit Ready ---"
ready=false
for _ in $(seq 1 30); do
  if k3s kubectl get nodes 2>/dev/null | grep -q " Ready"; then
    ready=true
    break
  fi
  sleep 2
done

if [[ "${ready}" != "true" ]]; then
  echo "Le nœud n'est pas passé Ready après 60s — vérifie 'sudo systemctl status k3s'." >&2
  exit 1
fi

echo
echo "--- État du cluster ---"
k3s kubectl get nodes -o wide
k3s kubectl get pods -A

echo
echo "k3s est installé et prêt."
echo "Kubeconfig lisible sans sudo : /etc/rancher/k3s/k3s.yaml"
echo "Pour utiliser 'kubectl' directement (au lieu de 'k3s kubectl') :"
echo '  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml'

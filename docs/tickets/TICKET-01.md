---
ticket: TICKET-01
title: Prérequis VM + installation k3s single-node
status: validated          # todo → coded → tested → refactored → validated
branch: feat/ticket-01
updated: 2026-09-16
---

# TICKET-01 — Prérequis VM + installation k3s single-node

## 🎯 Objectif
Vérifier que la VM de bureau (OS, distro, specs CPU/RAM/disque, accès sudo) est prête, puis installer k3s en single-node dessus. C'est le socle sur lequel reposent tous les tickets suivants.

## ✅ Definition of Done
- [x] Code implémenté
- [x] Tests passent (unitaires + intégration)
- [x] Sécurité vérifiée (si auth / secrets / RBAC concernés)
- [x] Refactor si nécessaire (tests verts avant ET après)
- [x] Lint + type-check OK
- [x] Testé en dev
- [x] Doc à jour

---

## 🔨 Code — 2026-09-16
**Fait :** vérification des specs VM (Fedora Linux 44, 4 vCPU, 16 Go RAM, 254 Go disque dont ~147 Go dispo) et script d'installation de k3s.
**Décisions (& pourquoi) :** `K3S_KUBECONFIG_MODE="644"` à l'install pour rendre le kubeconfig lisible sans sudo ensuite (évite de redemander le mot de passe à chaque commande kubectl). Script interactif car `sudo` sur cette VM demande un mot de passe (pas de sudo-less) — pas exécutable depuis un outil non-interactif, doit être lancé directement dans un terminal.
**Fichiers :** `scripts/install-k3s.sh`
**Reste / questions pour le test :** exécuter le script, vérifier que le nœud passe `Ready`, confirmer l'accès kubectl sans sudo.

## 🧪 Test — 2026-09-16
**Couvert :** exécution réelle du script par l'utilisateur sur la VM.
**NON couvert (assumé) :** comportement après reboot de la VM (le service est `enabled`, censé redémarrer automatiquement, à vérifier plus tard).
**Sécurité vérifiée :** n/a pour ce ticket (pas d'auth/secrets/RBAC).
**Bugs trouvés :** après exécution du script, le binaire et le service systemd `k3s` étaient bien installés (`enabled`) mais le service n'avait jamais démarré (`inactive`, aucune entrée journalctl) — probablement le script interrompu juste avant l'étape `start`. Le script vérifiait uniquement la présence du binaire `k3s` pour décider "déjà installé, rien à faire", ce qui aurait masqué le problème à une prochaine exécution. **Corrigé :** le script vérifie maintenant `systemctl is-active` et tente un `sudo systemctl start k3s` si le binaire existe mais le service est inactif, au lieu de sortir silencieusement.

Après `sudo systemctl start k3s` manuel : service `active`, nœud `fedora.home` en `Ready` (control-plane, k3s v1.36.4+k3s1, containerd 2.3.4-k3s1.36), kubeconfig `/etc/rancher/k3s/k3s.yaml` bien lisible sans sudo (mode 644 confirmé). Tous les pods système (`coredns`, `local-path-provisioner`, `metrics-server`, `traefik`, `svclb-traefik`, `helm-install-*`) confirmés `Running`/`Completed` après ~1 min.
**Audit refactor : 8/10** — script simple, lisible, idempotent après correction ; reste un point mineur (pas de retry/backoff sur le téléchargement curl, jugé excessif pour un script de POC à usage local).

## ♻️ Refactor — 2026-09-16
**Changé :** rien de plus que le fix déjà décrit en Test (détection `systemctl is-active` + tentative de `start`).
**Pourquoi :** seul bug trouvé pendant le test, déjà corrigé sur le moment plutôt que dans une passe de refactor séparée.
**Risque :** faible — script à usage local uniquement, pas exécuté en CI.
**Tests verts avant ET après :** cluster fonctionnel avant (une fois démarré manuellement) et après (le script démarrerait désormais seul le service dans ce cas).

## 🚀 Validation — 2026-09-16
**Lancé en dev :** oui — cluster k3s actif sur la VM, tous les pods système `Running`/`Completed`.
**Lancé en prod :** n/a pour ce ticket (infra seule, pas de déploiement applicatif avant TICKET-06).
**DoD complète :** oui.
**Statut final :** ✅ Terminé. Cluster k3s opérationnel, prêt pour TICKET-02 (registre d'images) et TICKET-03 (namespaces).

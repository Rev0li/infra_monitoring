---
ticket: TICKET-02
title: Registre d'images Docker
status: validated          # todo → coded → tested → refactored → validated
branch: feat/ticket-02
updated: 2026-09-16
---

# TICKET-02 — Registre d'images Docker

## 🎯 Objectif
Installer et valider un registre d'images Docker (Docker Registry v2) accessible à la fois depuis Jenkins (push) et depuis le cluster k3s (pull), ou confirmer/brancher un registre déjà existant côté central.

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
**Fait :** déployé un registre d'images Docker (`registry:2`) dans le cluster k3s, namespace dédié `registry`, exposé en `NodePort` sur `<IP-VM>:30500`, avec un `PersistentVolumeClaim` de 10Gi pour que les images survivent à un redémarrage du pod. Script `scripts/configure-k3s-registry.sh` pour configurer k3s (containerd) à accepter ce registre en HTTP simple.
**Décisions (& pourquoi) :** pas de registre central existant identifié côté Bitbucket → registre auto-hébergé dans le cluster (voir ADR-004, `01-tech-decisions.md`). HTTP simple (pas de TLS) pour rester simple sur un POC 5 jours — **limite de sécurité assumée et documentée** (voir `03-scope.md`), à revoir avant toute vraie mise en production. `NodePort` fixe (30500) plutôt qu'aléatoire, pour que Jenkins/les manifestes puissent le référencer de façon prévisible.
**Fichiers :** `k8s/registry/registry.yaml`, `scripts/configure-k3s-registry.sh`.
**Reste / questions pour le test :** exécuter `scripts/configure-k3s-registry.sh` (sudo, modifie `/etc/rancher/k3s/registries.yaml` + redémarre k3s) puis tester un push/pull réel une fois qu'une image de l'appli pilote existe (TICKET-04/05).

## 🧪 Test — 2026-09-16
**Couvert :** `configure-k3s-registry.sh` exécuté : `registries.yaml` correct, service k3s `active`, nœud `Ready`. Test réel avec Docker : `docker pull alpine`, `docker tag`, `docker push 192.168.1.50:30500/alpine:poc-test`.
**NON couvert (assumé) :** pull réel par un Pod k3s depuis ce registre (sera couvert par TICKET-06, premier déploiement applicatif).
**Sécurité vérifiée :** registre en HTTP simple, sans authentification — limite assumée et documentée (ADR-004, `03-scope.md`), acceptable pour un POC isolé sur une VM, à ne pas reproduire tel quel en prod réelle.
**Bugs trouvés :**
1. `docker push` a échoué (`http: server gave HTTP response to HTTPS client`) — la config `registries.yaml` ne couvre que **containerd/k3s** (ce qui pull les images dans les Pods), pas le **daemon Docker** séparé (ce qui fait `docker build`/`docker push`, utilisé par Jenkins). Il fallait en plus déclarer le registre dans `/etc/docker/daemon.json` (`insecure-registries`) et redémarrer Docker. **Corrigé :** `configure-k3s-registry.sh` fait maintenant les deux configs (containerd ET Docker) en une seule exécution.
2. Les deux scripts (`install-k3s.sh`, `configure-k3s-registry.sh`) utilisaient `sudo -v` sans forcer l'invalidation du cache sudo — si un `sudo` avait déjà été fait récemment (ex: script précédent), l'exécution suivante ne redemandait pas le mot de passe, ce qui a surpris l'utilisateur (demande explicite initiale : toujours être sollicité). **Corrigé :** ajout de `sudo -k` avant chaque `sudo -v`/`sudo` dans les deux scripts, pour forcer une demande de mot de passe à chaque exécution.

**Validation bout-en-bout complète :** `docker push 192.168.1.50:30500/alpine:poc-test` → réussi → `curl .../v2/_catalog` liste `alpine` → `kubectl run poc-test-pull --image=192.168.1.50:30500/alpine:poc-test` → Pod `Running`, image pullée en 150ms. Chemin push (Docker) → registre → pull (k3s) validé de bout en bout. Pod et images de test nettoyés après coup.

**Audit refactor : 8/10** — fonctionnel et testé de bout en bout ; limite connue et assumée : pas de TLS/auth sur le registre (POC uniquement).

## ♻️ Refactor — 2026-09-16
**Changé :** ajout de `sudo -k` dans les deux scripts d'installation (voir bug n°2 ci-dessus).
**Pourquoi :** cohérence avec la demande explicite de l'utilisateur d'être sollicité à chaque exécution, plutôt que de dépendre du cache sudo.
**Risque :** faible — un `sudo -k` de plus ne casse rien, juste un mot de passe redemandé un peu plus souvent.
**Tests verts avant ET après :** push/pull toujours fonctionnel après ce changement (revérifié).

## 🚀 Validation — 2026-09-16
**Lancé en dev :** oui — push Docker + pull k3s réels validés de bout en bout sur le cluster de la VM.
**Lancé en prod :** n/a pour ce ticket (registre partagé entre tous les environnements, pas de notion de prod spécifique ici).
**DoD complète :** oui.
**Statut final :** ✅ Terminé.

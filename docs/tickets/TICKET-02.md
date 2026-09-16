---
ticket: TICKET-02
title: Registre d'images Docker
status: coded          # todo → coded → tested → refactored → validated
branch: feat/ticket-02
updated: 2026-09-16
---

# TICKET-02 — Registre d'images Docker

## 🎯 Objectif
Installer et valider un registre d'images Docker (Docker Registry v2) accessible à la fois depuis Jenkins (push) et depuis le cluster k3s (pull), ou confirmer/brancher un registre déjà existant côté central.

## ✅ Definition of Done
- [ ] Code implémenté
- [ ] Tests passent (unitaires + intégration)
- [ ] Sécurité vérifiée (si auth / secrets / RBAC concernés)
- [ ] Refactor si nécessaire (tests verts avant ET après)
- [ ] Lint + type-check OK
- [ ] Testé en dev
- [ ] Doc à jour

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
**Bugs trouvés :** `docker push` a échoué (`http: server gave HTTP response to HTTPS client`) — la config `registries.yaml` ne couvre que **containerd/k3s** (ce qui pull les images dans les Pods), pas le **daemon Docker** séparé (ce qui fait `docker build`/`docker push`, utilisé par Jenkins). Il fallait en plus déclarer le registre dans `/etc/docker/daemon.json` (`insecure-registries`) et redémarrer Docker. **Corrigé :** `configure-k3s-registry.sh` fait maintenant les deux configs (containerd ET Docker) en une seule exécution.
**Audit refactor : X/10** — <arguments>

## ♻️ Refactor — <date>
**Changé :**
**Pourquoi :**
**Risque :**
**Tests verts avant ET après :**

## 🚀 Validation — <date>
**Lancé en dev :**
**Lancé en prod :**
**DoD complète :**
**Statut final :**

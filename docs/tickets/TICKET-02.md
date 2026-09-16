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

## 🧪 Test — <date>
**Couvert :**
**NON couvert (assumé) :**
**Sécurité vérifiée :**
**Bugs trouvés :**
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

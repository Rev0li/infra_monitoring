---
ticket: TICKET-01
title: Prérequis VM + installation k3s single-node
status: todo          # todo → coded → tested → refactored → validated
branch: feat/ticket-01
updated: 2026-09-16
---

# TICKET-01 — Prérequis VM + installation k3s single-node

## 🎯 Objectif
Vérifier que la VM de bureau (OS, distro, specs CPU/RAM/disque, accès sudo) est prête, puis installer k3s en single-node dessus. C'est le socle sur lequel reposent tous les tickets suivants.

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
**Fait :** vérification des specs VM (Fedora Linux 44, 4 vCPU, 16 Go RAM, 254 Go disque dont ~147 Go dispo) et script d'installation de k3s.
**Décisions (& pourquoi) :** `K3S_KUBECONFIG_MODE="644"` à l'install pour rendre le kubeconfig lisible sans sudo ensuite (évite de redemander le mot de passe à chaque commande kubectl). Script interactif car `sudo` sur cette VM demande un mot de passe (pas de sudo-less) — pas exécutable depuis un outil non-interactif, doit être lancé directement dans un terminal.
**Fichiers :** `scripts/install-k3s.sh`
**Reste / questions pour le test :** exécuter le script, vérifier que le nœud passe `Ready`, confirmer l'accès kubectl sans sudo.

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

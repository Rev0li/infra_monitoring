---
ticket: TICKET-04
title: Repo Bitbucket appli pilote bidon
status: todo          # todo → coded → tested → refactored → validated
branch: feat/ticket-04
updated: 2026-09-16
---

# TICKET-04 — Repo Bitbucket appli pilote bidon

## 🎯 Objectif
Créer le repo Bitbucket de l'appli bidon représentative (Spring Boot Java 21 côté API, Angular + Tailwind côté front) avec des Dockerfiles fonctionnels pour les deux.

## ✅ Definition of Done
- [ ] Code implémenté
- [ ] Tests passent (unitaires + intégration)
- [ ] Sécurité vérifiée (si auth / secrets / RBAC concernés)
- [ ] Refactor si nécessaire (tests verts avant ET après)
- [ ] Lint + type-check OK
- [ ] Testé en dev
- [ ] Doc à jour

---

## 🔨 Code — <date>
**Fait :** en attente.
**Décisions (& pourquoi) :** repo séparé de `infra_monitoring` (mono-repo `backend/` + `frontend/`), sur le Bitbucket d'entreprise de l'utilisateur — pas d'accès direct depuis cette session, l'utilisateur doit créer le repo et fournir l'URL.
**Fichiers :** à venir, dans un dossier local séparé (proposé : `/home/rev0li/work/appli-pilote`).
**Reste / questions pour le test :** **⏸ Bloqué le 2026-09-16** — l'utilisateur crée le repo Bitbucket depuis son poste de bureau (accès entreprise, pas disponible en dehors du bureau) et donnera l'URL plus tard. En attendant, le code applicatif (Spring Boot + Angular + Dockerfiles) peut être préparé localement sans dépendre du repo, pour être poussé dès que l'URL est fournie.

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

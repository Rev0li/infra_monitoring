---
ticket: TICKET-11
title: Loki + Promtail pour logs centralisés
status: todo          # todo → coded → tested → refactored → validated
branch: feat/ticket-11
updated: 2026-09-16
---

# TICKET-11 — Loki + Promtail pour logs centralisés

## 🎯 Objectif
Déployer Loki (agrégation) et Promtail (collecte) dans le cluster k3s pour centraliser les logs de l'appli pilote sur les 4 namespaces — réponse directe au problème actuel de « 0 log serveur ».

**Référence technique :** [`docs/guides/k8s-prometheus-grafana.md`](../guides/k8s-prometheus-grafana.md), étape 3 (Helm `loki-stack`) et section LogQL de la cheat-sheet.

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
**Fait :**
**Décisions (& pourquoi) :**
**Fichiers :**
**Reste / questions pour le test :**

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

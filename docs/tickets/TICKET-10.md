---
ticket: TICKET-10
title: Prometheus + métriques par namespace
status: todo          # todo → coded → tested → refactored → validated
branch: feat/ticket-10
updated: 2026-09-16
---

# TICKET-10 — Prometheus + métriques par namespace

## 🎯 Objectif
Déployer Prometheus dans le cluster k3s et configurer le scraping des métriques exposées par l'appli pilote dans chacun des 4 namespaces.

**Référence technique :** [`docs/guides/k8s-prometheus-grafana.md`](../guides/k8s-prometheus-grafana.md), étapes 2, 4 et 6 (Helm `kube-prometheus-stack`, Spring Boot Actuator, `ServiceMonitor`).

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

---
ticket: TICKET-03
title: Namespaces K8s dev/int/uat/prod
status: validated          # todo → coded → tested → refactored → validated
branch: feat/ticket-03
updated: 2026-09-16
---

# TICKET-03 — Namespaces K8s dev/int/uat/prod

## 🎯 Objectif
Créer les 4 namespaces Kubernetes (dev, int, uat, prod) sur le cluster k3s, avec des ResourceQuotas de base pour une isolation logique entre environnements.

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
**Fait :** manifestes K8s déclaratifs pour les 4 namespaces (`dev`, `int`, `uat`, `prod`), chacun avec un `ResourceQuota` de base. Label `environment: <nom>` sur chaque namespace pour faciliter le filtrage (Grafana, sélecteurs `ServiceMonitor`, etc. — voir `docs/guides/k8s-prometheus-grafana.md`).
**Décisions (& pourquoi) :** quotas identiques sur les 4 environnements pour le POC (`requests.cpu: 500m`, `requests.memory: 512Mi`, `limits.cpu: 1`, `limits.memory: 1Gi`, `pods: 10`) — simplification assumée, à différencier plus tard si `prod` a besoin de plus de marge. Manifestes déclaratifs versionnés (`kubectl apply -f`) plutôt que des commandes impératives (`kubectl create namespace`), pour rester reproductible et réutilisable par le pipeline Jenkins.
**Fichiers :** `k8s/namespaces/dev.yaml`, `int.yaml`, `uat.yaml`, `prod.yaml`.
**Reste / questions pour le test :** vérifier que les 4 namespaces et leurs quotas sont bien actifs sur le cluster.

## 🧪 Test — 2026-09-16
**Couvert :** `kubectl apply -f k8s/namespaces/` exécuté sur le cluster réel (voir TICKET-01) ; `kubectl get namespaces` et `kubectl get resourcequota -A` confirment les 4 namespaces `Active` avec leurs quotas à 0/limite (rien de déployé dedans pour l'instant, normal).
**NON couvert (assumé) :** comportement une fois des pods réels déployés dedans (à vérifier en pratique à partir de TICKET-06). Pas de `NetworkPolicy` pour l'instant — l'isolation reste logique (namespaces + quotas), pas réseau (cohérent avec ADR-002 dans `01-tech-decisions.md`).
**Sécurité vérifiée :** pas de RBAC spécifique par namespace pour ce POC (assumé, un seul utilisateur/kubeconfig admin) — limite explicite à noter si le projet évolue vers plusieurs opérateurs.
**Bugs trouvés :** aucun — `apply` direct sans accroc.
**Audit refactor : 9/10** — manifestes simples, un fichier par environnement (facile à faire évoluer indépendamment), rien à changer pour ce périmètre.

## ♻️ Refactor — 2026-09-16
**Changé :** rien, pas nécessaire.
**Pourquoi :** manifestes déjà minimaux et corrects du premier coup.
**Risque :** n/a.
**Tests verts avant ET après :** n/a (pas de changement).

## 🚀 Validation — 2026-09-16
**Lancé en dev :** oui — 4 namespaces `Active` sur le cluster k3s de la VM, quotas appliqués.
**Lancé en prod :** le namespace `prod` existe et est configuré, mais rien n'y est déployé pour l'instant (normal, arrive avec TICKET-09).
**DoD complète :** oui.
**Statut final :** ✅ Terminé.

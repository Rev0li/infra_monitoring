# 02 — Architecture (de départ)

> ⚠️ **Architecture de départ, susceptible d'évoluer.** Ce document est un point
> de départ, pas un contrat. Quand l'archi change en cours de route, mettre ce
> fichier à jour et noter le changement.

## Vue d'ensemble

```
Dev (VS Code + Copilot)
   │  git push (branche liée à un ticket Jira)
   ▼
Bitbucket (repo + webhook)  ⇄  Jira (lien ticket ↔ commit)
   │  déclenche
   ▼
Jenkins (pipeline déclaratif : build → test → docker build → push)
   │
   ▼
Registre d'images (Docker Registry v2, dans k3s)
   │  kubectl/helm apply
   ▼
Cluster k3s (sur la VM de bureau)
   ├── namespace dev   ── déploiement automatique à chaque push
   ├── namespace int   ── déploiement automatique après tests OK
   ├── namespace uat   ── déploiement après gate de validation manuelle
   └── namespace prod  ── déploiement après gate + ticket Jira validé
        │
        ├── App pilote (Spring Boot API + Angular/Tailwind) — dans chaque namespace
        └── Promtail (collecte logs) — dans chaque namespace

Prometheus (scrape les métriques de chaque namespace) ──▶ Grafana
Loki (agrège les logs remontés par Promtail)          ──▶ Grafana
```

## Composants
| Composant | Rôle | Techno |
|---|---|---|
| Bitbucket | Dépôt Git + déclenchement webhook | Bitbucket (centralisé, existant) |
| Jenkins | Orchestration CI/CD (build/test/dockerize/deploy) | Jenkins (centralisé) + `Jenkinsfile` déclaratif versionné dans le repo |
| Registre d'images | Stockage des images construites | Docker Registry v2 (hébergé dans k3s) |
| k3s | Exécution des 4 environnements | Kubernetes (k3s), 1 namespace par environnement |
| Appli pilote | Backend + frontend déployés | Spring Boot (Java 21) + Angular + Tailwind |
| Prometheus | Collecte de métriques | Prometheus (dans k3s) |
| Loki + Promtail | Collecte + agrégation de logs | Loki / Promtail (dans k3s) |
| Grafana | Visualisation métriques + logs | Grafana (dans k3s) |
| Jira | Suivi des tickets, lien commits/déploiements | Jira (centralisé, existant) |

## Flux principaux

1. **Livraison dev → int** : le dev pousse sur une branche liée à un ticket Jira → PR sur Bitbucket → Jenkins build/test → déploiement auto en namespace `dev` → après merge validé, déploiement auto en namespace `int`.
2. **Promotion int → uat → prod** : une fois les tests d'intégration validés en `int`, gate de validation manuelle Jenkins pour promouvoir en `uat`, puis nouveau gate (+ vérification ticket Jira) pour promouvoir en `prod`. Chaque étape est tracée (log de build Jenkins + statut du ticket Jira mis à jour).
3. **Observabilité** : à chaque déploiement, l'appli pilote expose des métriques (Prometheus) et des logs (Promtail → Loki), visibles en temps réel dans Grafana, par environnement. C'est la réponse directe au problème actuel de « 0 log serveur ».

## Données & secrets
Pas de données sensibles réelles dans le POC (appli bidon en premier). Les secrets (identifiants du registre, kubeconfig, credentials Jenkins) sont stockés dans le **Jenkins Credentials Store**, jamais en clair dans le `Jenkinsfile` ni dans les manifests K8s — utilisation de **K8s Secrets** montés en variables d'environnement ou volumes.

Point de vigilance pour la suite (hors scope du POC, à anticiper vu la sensibilité du contexte) : une gestion de secrets plus robuste (ex. Vault) sera probablement nécessaire avant tout passage en production réelle.

## Points d'évolution anticipés
- Isolation **physique** des environnements (surtout `prod`) si les exigences du secteur l'imposent.
- Gestion de secrets plus poussée (Vault ou équivalent).
- Cluster K8s multi-nœuds ou managé en cas de passage en production réelle.
- Ajout de tests de sécurité automatisés (SAST/DAST) dans le pipeline Jenkins.

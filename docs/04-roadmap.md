# 04 — Roadmap & ticketing

Dérivé de la vision, des décisions techniques et de l'architecture. Chaque ticket
a un fichier dans `docs/tickets/<ID>.md` (géré par le skill ticket-handoff).

> Vu le délai serré (5 jours pour la démo), la roadmap est découpée **par jour**
> plutôt que par sprint classique.

## Jour 1 — Fondations infra
| Ticket | Titre | Dépend de | Statut |
|---|---|---|---|
| TICKET-01 | Vérifier prérequis VM (OS, specs, sudo) et installer k3s single-node | — | validated |
| TICKET-02 | Installer/valider le registre d'images Docker | TICKET-01 | todo |
| TICKET-03 | Créer les 4 namespaces K8s (dev/int/uat/prod) avec quotas de base | TICKET-01 | todo |

## Jour 2 — Appli pilote + pipeline CI
| Ticket | Titre | Dépend de | Statut |
|---|---|---|---|
| TICKET-04 | Créer le repo Bitbucket de l'appli bidon (Spring Boot + Angular/Tailwind) avec Dockerfiles | — | todo |
| TICKET-05 | Écrire le Jenkinsfile déclaratif (build, test, docker build, push) déclenché par webhook Bitbucket | TICKET-02, TICKET-04 | todo |
| TICKET-06 | Déployer automatiquement en namespace `dev` à chaque push | TICKET-03, TICKET-05 | todo |

## Jour 3 — Promotion des environnements
| Ticket | Titre | Dépend de | Statut |
|---|---|---|---|
| TICKET-07 | Promotion automatique `dev` → `int` après tests OK | TICKET-06 | todo |
| TICKET-08 | Gate de validation manuelle pour la promotion `int` → `uat` | TICKET-07 | todo |
| TICKET-09 | Gate de validation pour la promotion `uat` → `prod`, avec traçabilité Jira | TICKET-08 | todo |

## Jour 4 — Observabilité
| Ticket | Titre | Dépend de | Statut |
|---|---|---|---|
| TICKET-10 | Déployer Prometheus et exposer les métriques de l'appli pilote par namespace | TICKET-09 | todo |
| TICKET-11 | Déployer Loki + Promtail pour centraliser les logs de chaque namespace | TICKET-09 | todo |
| TICKET-12 | Construire les dashboards Grafana (métriques + logs) par environnement | TICKET-10, TICKET-11 | todo |

## Jour 5 — Intégration Jira + démo + doc finale
| Ticket | Titre | Dépend de | Statut |
|---|---|---|---|
| TICKET-13 | Lier commits Bitbucket et builds Jenkins aux tickets Jira | TICKET-09 | todo |
| TICKET-14 | Valider le parcours complet dev→int→uat→prod de bout en bout | TICKET-12, TICKET-13 | todo |
| TICKET-15 | Finaliser la documentation (`docs/`) et préparer la démo | TICKET-14 | todo |

## Principe de découpage
- 1 ticket = une unité **livrable et testable** (pas un epic).
- Le statut de référence vit dans chaque `docs/tickets/<ID>.md` ; ce tableau est
  une vue d'ensemble, à resynchroniser ponctuellement
  (`grep -l 'status: ...' docs/tickets/*.md`).

## Jalons
- **MVP (fin jour 3) :** l'appli bidon transite automatiquement de `dev` à `prod` via Jenkins, avec au moins un gate de validation manuelle — TICKET-01 à TICKET-09.
- **Démo finale (fin jour 5) :** MVP + observabilité complète (logs + métriques dans Grafana) + lien Jira + documentation à jour — tous les tickets.

# 03 — Scope, non-goals & risques

Le rempart anti scope-creep. Si une demande tombe dans les non-goals, on dit non
(ou on l'ajoute consciemment à la roadmap).

## Dans le scope (v1 — POC 5 jours)
- Un pipeline Jenkins déclaratif complet (build, test, docker build/push, deploy) déclenché depuis Bitbucket.
- 4 environnements K8s (dev, int, uat, prod) sous forme de namespaces sur un cluster k3s unique.
- Déploiement d'une appli bidon (Spring Boot + Angular/Tailwind) de bout en bout à travers les 4 environnements.
- Logs centralisés (Loki/Promtail) et métriques (Prometheus) visibles dans Grafana.
- Lien basique Jira ↔ Bitbucket ↔ Jenkins (statut de ticket/build).
- Documentation complète de chaque brique et décision (`docs/`) — exigence **primordiale**, à deux publics : documentation dev (`docs/`) et support de présentation à la hiérarchie (non technique, distinct de la doc dev).

## Non-goals (hors scope, assumé)
- Migration complète d'une vraie appli en production réelle — **pour l'instant**. Une vraie appli R&D pourra être branchée une fois le pipeline validé sur l'appli bidon, si le temps le permet.
- Haute disponibilité / cluster multi-nœuds — **jamais** dans le cadre de ce POC 5 jours ; à réévaluer si passage en prod réelle.
- Gestion de secrets avancée (Vault, rotation automatique) — **pour l'instant**, hors scope.
- Tests de sécurité automatisés (SAST/DAST) dans le pipeline — **pour l'instant**, hors scope, à ajouter dans une itération suivante.
- Remplacement immédiat et complet de XLDeploy en production — le POC sert de **preuve**, pas de bascule définitive.

## Risques
| Risque | Impact | Probabilité | Mitigation |
|---|---|---|---|
| Délai de 5 jours très serré pour un néophyte K8s | Fort (POC incomplet) | Élevée | Prioriser un chemin dev→prod minimal fonctionnel avant d'enrichir observabilité/gates |
| Ressources VM insuffisantes (CPU/RAM) pour k3s + Jenkins agent + Prometheus/Grafana/Loki | Moyen (lenteur/plantage) | Moyenne | Vérifier les specs de la VM dès le jour 1, alléger la stack si besoin |
| Registre d'images non tranché | Moyen (bloque build→deploy) | Moyenne | Trancher tôt (jour 1) — registre local minimal (Docker Registry v2) si rien côté central |
| Secteur d'activité sensible : exigences de sécurité/traçabilité non formalisées | Fort à terme (si le POC devient base de prod) | Moyenne | Documenter explicitement les limites du POC (isolation logique seulement, pas de gestion de secrets avancée) |

## Questions ouvertes
- [x] Distro Linux exacte de la VM → **Fedora Linux 44 (Workstation)**, confirmé le 2026-09-16 depuis l'environnement de travail (`/etc/os-release`). À revalider si ce n'est pas la même machine que la VM cible finale du POC.
- [x] Specs de la VM → **4 vCPU, 16 Go RAM (~10 Go dispo), 254 Go disque (~147 Go dispo)**, constaté le 2026-09-16. Confortable pour k3s + Jenkins agent + Prometheus/Grafana/Loki en usage POC.
- [x] Un registre d'images Docker existe-t-il déjà côté central, ou faut-il en héberger un dans k3s ? → **Aucun registre central identifié, on héberge un `registry:2` dans k3s** (décidé le 2026-09-16, voir TICKET-02 et ADR-004).
- [ ] Base de données de l'appli pilote (moteur, ou aucune pour la v0 bidon ?).
- [ ] Jenkins central : un agent peut-il builder/déployer depuis/vers la VM, ou faut-il enregistrer la VM comme agent Jenkins ?
- [ ] **Bloquant TICKET-04 (2026-09-16) :** le Bitbucket d'entreprise n'est accessible que depuis le poste de bureau — création du repo de l'appli pilote reportée au prochain passage au bureau. Le code (backend/frontend/Dockerfiles) peut être préparé en local en attendant.
- [ ] Quelles contraintes de sécurité/conformité sont déjà connues pour le secteur d'activité, même non formalisées ?
- [ ] L'accès `sudo` sur cette VM nécessite un mot de passe (pas de sudo sans mot de passe) — à confirmer que l'utilisateur dispose bien de ce mot de passe pour les installations (k3s, Docker, etc.).

## Hypothèses
- La VM tourne sous **Fedora Linux 44**, avec accès sudo complet (mot de passe requis, pas de sudo-less).
- L'instance Jenkins centrale peut déclencher un job sur la VM (agent Jenkins) ou depuis la VM elle-même.
- Aucune donnée réelle/sensible n'est manipulée dans le POC (appli bidon en premier).
- PostgreSQL comme moteur de BDD par défaut, si l'appli pilote en nécessite un.

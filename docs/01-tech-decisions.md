# 01 — Décisions techniques

Format ADR-lite : une entrée par décision structurante. On ne re-débat pas une
décision écrite ici sans ajouter une nouvelle entrée qui la remplace.

## Stack (résumé)
| Couche | Choix | Version |
|---|---|---|
| Langage(s) | Java, TypeScript | Java 21 |
| Framework(s) | Spring Boot (backend), Angular + Tailwind CSS (frontend) | Angular 21 |
| Base de données | À confirmer — hypothèse PostgreSQL conteneurisé | — |
| Infra / déploiement | k3s (Kubernetes léger) sur VM Linux, images OCI/Docker | k3s dernière stable |
| CI / tests | Jenkins (pipeline déclaratif) + Bitbucket (repo + webhooks) | existant (central) |

## Contraintes
- VM de bureau **unique**, droits complets (sudo avec mot de passe), OS **Fedora Linux 44** (4 vCPU / 16 Go RAM / ~147 Go disque dispo).
- Jira, Bitbucket et Jenkins sont **déjà centralisés et accessibles** : on ne les réinstalle pas, on s'y branche (webhooks, credentials, API).
- Délai **très serré : 5 jours** pour une démo fonctionnelle.
- Secteur d'activité sensible (contexte interne, non détaillé dans ce dépôt public) : même non formalisé, la traçabilité et la gestion des logs doivent être prises au sérieux dès le POC.
- Utilisateur néophyte K8s/CI-CD : privilégier la simplicité et la lisibilité à la sophistication.

---

## ADR-001 — Cluster Kubernetes : k3s en single-node sur la VM
- **Contexte :** aucun cluster K8s existant, délai de 5 jours, utilisateur néophyte K8s, une seule VM avec droits complets.
- **Décision :** installer **k3s** (distribution Kubernetes légère) en single-node directement sur la VM.
- **Pourquoi :** installation en une commande, faible empreinte ressources, API Kubernetes standard (donc manifests et connaissances acquises restent valables sur un vrai cluster plus tard), suffisant pour démontrer 4 environnements sous forme de namespaces.
- **Alternatives écartées :** cluster managé cloud (EKS/AKS/GKE) — hors délai/budget/droits pour un POC de 5 jours ; kind — plus orienté tests éphémères que démo persistante ; minikube — plus lourd que k3s pour ce besoin.
- **Conséquences :** un seul nœud = pas de haute disponibilité réelle (assumé pour un POC). Une migration vers un cluster multi-nœuds plus tard nécessitera de revalider stockage et ingress.

## ADR-002 — Séparation des environnements par namespace K8s
- **Contexte :** 4 phases demandées (dev, int, uat, prod) sur un unique cluster k3s.
- **Décision :** un **namespace K8s par environnement** (dev, int, uat, prod) sur le même cluster, avec ResourceQuotas de base pour l'isolation logique.
- **Pourquoi :** pas besoin de 4 VMs/clusters séparés pour un POC ; permet de démontrer la promotion d'un environnement à l'autre en changeant simplement de namespace/tag d'image.
- **Alternatives écartées :** 4 clusters séparés (trop lourd pour une VM unique et 5 jours) ; pas de séparation du tout (ne répond pas au besoin explicite dev→int→uat→prod).
- **Conséquences :** l'isolation reste **logique**, pas physique — limite explicite du POC à documenter si le besoin réel en prod (contexte à forte exigence de sécurité) exige une isolation physique.

## ADR-003 — Logs centralisés : Grafana Loki + Promtail, en complément de Prometheus
- **Contexte :** le problème principal actuel est « 0 log serveur » exploitable. Prometheus/Grafana sont déjà prévus dans la stack cible, mais Prometheus ne couvre que les métriques, pas les logs.
- **Décision :** ajouter **Loki** (agrégation de logs) + **Promtail** (collecte) à la stack, visualisés dans Grafana aux côtés des métriques Prometheus.
- **Pourquoi :** intégration native avec Grafana déjà prévu, plus léger qu'une stack ELK, répond directement à la douleur « 0 log » identifiée.
- **Alternatives écartées :** ELK/OpenSearch (trop lourd/long à mettre en place en 5 jours) ; se contenter de `kubectl logs` (ne résout pas la traçabilité/historisation attendue).
- **Conséquences :** une brique supplémentaire à installer et documenter, mais directement alignée sur le besoin exprimé par l'utilisateur.

## ADR-004 — Registre d'images conteneurs
- **Contexte :** le pipeline Jenkins doit publier des images Docker construites depuis Bitbucket vers k3s ; aucun registre existant n'a été mentionné.
- **Décision :** déployer un registre local léger (Docker Registry v2) dans le cluster k3s, à défaut d'un registre déjà fourni côté central (à vérifier — voir questions ouvertes).
- **Pourquoi :** nécessaire au flux CI/CD (build → push → deploy) ; pas d'info confirmée sur un registre déjà existant.
- **Alternatives écartées :** registre public (Docker Hub) — à éviter pour du code interne, a fortiori dans un secteur sensible.
- **Conséquences :** point à trancher en tout début de POC (jour 1) — voir `03-scope.md`.

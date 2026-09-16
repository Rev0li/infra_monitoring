# infra_monitoring

POC d'infrastructure de développement (branche R&D) : chaîne CI/CD dev → int → uat → prod portée par Jenkins + Bitbucket + Kubernetes (k3s), avec observabilité Prometheus/Grafana/Loki. Objectif : remplacer le déploiement actuel XLDeploy/Jenkins, qui n'offre aucun log serveur exploitable.

## Documentation

- [`docs/00-vision.md`](docs/00-vision.md) — le problème, la vision, pour qui, la valeur
- [`docs/01-tech-decisions.md`](docs/01-tech-decisions.md) — stack et décisions techniques (ADR-lite)
- [`docs/02-architecture.md`](docs/02-architecture.md) — architecture de départ
- [`docs/03-scope.md`](docs/03-scope.md) — scope, non-goals, risques, questions ouvertes
- [`docs/04-roadmap.md`](docs/04-roadmap.md) — roadmap (5 jours) et liste des tickets
- [`docs/tickets/`](docs/tickets/) — un fichier par ticket (statut, avancement)
- [`docs/guides/`](docs/guides/) — guides pratiques (ex: [K8s, Prometheus, Grafana & Loki](docs/guides/k8s-prometheus-grafana.md))

À lire dans cet ordre pour prendre en main le projet : vision → décisions techniques → architecture → scope → roadmap.

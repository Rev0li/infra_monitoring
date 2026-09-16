# CLAUDE.md — POC Infra CI/CD (dev → int → uat → prod)

Instructions pour toute session Claude Code travaillant dans ce dépôt.

## Contexte du projet
POC porté depuis la branche R&D pour remplacer le déploiement actuel — XLDeploy + Jenkins, **0 log serveur exploitable** — par une chaîne CI/CD tracée : Bitbucket → Jenkins → k3s (namespaces dev/int/uat/prod) → observabilité Prometheus/Grafana/Loki. Objectif : une **démonstration technique fonctionnelle**, pas un dossier théorique. Délai cible : 5 jours.

Ce dépôt est **public** — ne jamais y écrire de détails identifiant précisément l'organisation, son secteur d'activité, ou des informations internes sensibles. Rester générique sur ces points (voir `docs/03-scope.md`).

## Règle n°1 : tout documenter (primordial, non négociable)
Deux publics distincts à servir à chaque étape :
1. **Documentation dev** (`docs/`) : pour comprendre/reproduire/faire évoluer la chaîne.
2. **Support de présentation à la hiérarchie** : à préparer à part (voir `docs/tickets/TICKET-15.md`), compréhensible par un public non technique — le problème, ce qui a été construit, la valeur. Ce n'est pas juste "la doc dev en plus court".

Ne jamais attendre la fin d'un ticket pour documenter — mettre à jour la doc concernée au fil de l'eau.

## Où sont les choses
- `docs/00-vision.md` → `04-roadmap.md` : vision, décisions techniques (ADR-lite), architecture de départ, scope/risques/questions ouvertes, roadmap.
- `docs/tickets/TICKET-01.md` → `TICKET-15.md` : ticketing, un fichier par ticket. Le statut de référence vit dans le frontmatter de chaque fichier (`status: todo|coded|tested|refactored|validated`), pas dans `04-roadmap.md` (vue d'ensemble seulement, à resynchroniser).
- `docs/guides/` : guides techniques pratiques (ex. `k8s-prometheus-grafana.md`, référence pour TICKET-10/11/12).
- `README.md` : point d'entrée / sommaire.

## Avant de commencer une session
1. `git log --oneline -5` pour voir ce qui a changé depuis la dernière session.
2. Lire `docs/03-scope.md` (questions ouvertes / risques — peuvent avoir été tranchés entretemps).
3. `grep -l 'status:' docs/tickets/*.md` pour voir où en est chaque ticket, plutôt que de supposer.
4. Reprendre selon `docs/04-roadmap.md`, jour par jour.

## Conventions
- Une branche par ticket (`feat/ticket-XX`, voir le frontmatter du fichier ticket).
- Commits explicites (`docs:`, `feat:`, `fix:` + résumé court).
- Scripts qui ont besoin de sudo (`scripts/*.sh`) : toujours `sudo -k` juste avant `sudo -v`/tout premier `sudo`, pour forcer une demande de mot de passe explicite à chaque exécution plutôt que de dépendre silencieusement du cache sudo (demande explicite de l'utilisateur, voir TICKET-02).
- Registre d'images interne (`192.168.1.50:30500`) : HTTP simple, sans TLS/auth — k3s (containerd) ET le daemon Docker doivent chacun être configurés séparément pour l'accepter (`registries.yaml` pour l'un, `daemon.json` pour l'autre). Voir `scripts/configure-k3s-registry.sh`.
- Avant tout `git push --force` ou réécriture d'historique : confirmer explicitement avec l'utilisateur, même si une règle générale l'autorise déjà — le risque (repo public) le justifie.

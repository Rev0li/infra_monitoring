# 00 — Vision

## Le problème
Le déploiement actuel repose sur XLDeploy + Jenkins, sans **aucun log serveur exploitable** : impossible de tracer ce qui se passe réellement à chaque déploiement. Il n'y a pas non plus de séparation formalisée et outillée entre des environnements dev, int, uat et prod avec une promotion contrôlée entre eux — les déploiements se font de façon artisanale ("old school").

## La vision
Une chaîne CI/CD reproductible portée par Jenkins + Bitbucket + Kubernetes, avec quatre environnements distincts (dev → int → uat → prod), une observabilité de bout en bout (métriques + logs centralisés visibles dans Grafana), et un lien de traçabilité avec Jira à chaque étape de promotion. Le tout doit être documenté de façon à ce qu'un néophyte K8s/CI-CD puisse comprendre, reproduire et faire évoluer la chaîne.

## Pour qui
L'équipe R&D qui livre aujourd'hui via XLDeploy, et par extension les équipes qui opèrent des applications dans un contexte à exigences de sécurité et de traçabilité élevées — même si ces exigences ne sont pas encore formalisées à ce stade du POC.

## Valeur
- De la visibilité (logs + métriques) là où il n'y en a **aucune** aujourd'hui.
- Des promotions d'environnement reproductibles et tracées, plutôt que des déploiements manuels opaques.
- Une base concrète et démontrable pour justifier une sortie progressive de XLDeploy.

## Principes directeurs
- **Démonstration fonctionnelle réelle > dossier théorique** : le pipeline doit tourner pour de vrai, pas juste être décrit.
- **Stack légère**, adaptée à une VM unique et à un délai de 5 jours (pas de cluster managé lourd).
- **Tout documenter**, avec un langage vulgarisé — le public de référence est néophyte K8s/CI-CD.
- **Réutiliser l'existant central** (Jira/Bitbucket/Jenkins déjà managés) plutôt que le réinventer.
- **Progressivité** : valider le pipeline sur une appli bidon avant de brancher une vraie appli R&D.

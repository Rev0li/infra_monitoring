---
ticket: TICKET-04
title: Repo Bitbucket appli pilote bidon
status: tested          # todo → coded → tested → refactored → validated
branch: feat/ticket-04
updated: 2026-09-16
---

# TICKET-04 — Repo Bitbucket appli pilote bidon

## 🎯 Objectif
Créer le repo Bitbucket de l'appli bidon représentative (Spring Boot Java 21 côté API, Angular + Tailwind côté front) avec des Dockerfiles fonctionnels pour les deux.

## ✅ Definition of Done
- [ ] Code implémenté
- [ ] Tests passent (unitaires + intégration)
- [ ] Sécurité vérifiée (si auth / secrets / RBAC concernés)
- [ ] Refactor si nécessaire (tests verts avant ET après)
- [ ] Lint + type-check OK
- [ ] Testé en dev
- [ ] Doc à jour

---

## 🔨 Code — 2026-09-17
**Fait :** code applicatif écrit et validé en local, dans `/home/rev0li/work/appli-pilote` (repo git initialisé, pas encore de remote).
- `backend/` : Spring Boot 3.4.1 (Java 21), `spring-boot-starter-web` + `spring-boot-starter-actuator` + `micrometer-registry-prometheus`. Endpoint `GET /api/hello` (JSON), Actuator exposé sur `/actuator/health` et `/actuator/prometheus` (cohérent avec `docs/guides/k8s-prometheus-grafana.md` et ADR-001). 1 test d'intégration (`@SpringBootTest`).
- `frontend/` : Angular 22 (`ng new` non-interactif) + Tailwind CSS v4 (`@tailwindcss/postcss`), un composant qui appelle `GET /api/hello` du backend et affiche le message. 2 tests unitaires (mock HTTP via `HttpTestingController`).
- Un `Dockerfile` multi-stage par appli : backend (`maven:3.9-eclipse-temurin-21` → `eclipse-temurin:21-jre-alpine`), frontend (`node:22-alpine` → `nginx:alpine`).
**Décisions (& pourquoi) :** repo séparé de `infra_monitoring` (mono-repo `backend/` + `frontend/`), sur le Bitbucket d'entreprise de l'utilisateur — pas d'accès direct depuis cette session. Build via Docker multi-stage plutôt que Maven/Node installés sur la VM : ni Maven ni JDK 21 n'y étaient présents (seulement JDK 25), et ça reproduit exactement ce que fera Jenkins (pas de dépendance d'outillage supplémentaire sur l'agent).
**Fichiers :** tout `/home/rev0li/work/appli-pilote/` (`backend/`, `frontend/`, `README.md`, `.gitignore` par appli).
**Reste / questions pour le test :** **⏸ Toujours bloqué sur le repo Bitbucket** — l'utilisateur le crée depuis son poste de bureau (accès entreprise indisponible ailleurs) et donnera l'URL au prochain passage. Le code est prêt à être poussé dès que l'URL arrive (voir mémoire projet).

## 🧪 Test — 2026-09-17
**Couvert :** build + test + run réels pour les deux applis (pas juste "ça devrait marcher") :
- Backend : `docker build` → succès, 1 test passé (`Tests run: 1, Failures: 0`) ; conteneur lancé → `curl /api/hello` (200, JSON correct), `curl /actuator/health` (`{"status":"UP"}`), `curl /actuator/prometheus` (métriques exposées).
- Frontend : `ng test --watch=false` → 2 tests passés ; `docker build` → succès ; conteneur lancé → `curl /` sert le HTML/CSS Tailwind généré (classes utilitaires bien présentes dans le CSS servi).
**NON couvert (assumé) :** l'appel HTTP réel du frontend vers le backend n'a pas été vérifié dans un vrai navigateur (JS côté client) — seulement couvert par les tests unitaires avec mock HTTP. À vérifier visuellement une fois les deux services déployés ensemble (TICKET-06).
**Sécurité vérifiée :** `@CrossOrigin(origins = "*")` sur le backend — **limite POC assumée et documentée dans le code**, à restreindre à l'origine réelle du frontend avant toute vraie mise en production.
**Bugs trouvés :** `npm install` du projet Angular généré a planté (`Cannot read properties of null (reading 'edgesOut')`) — bug connu de l'algorithme de résolution des peer dependencies de npm sur la combinaison `vitest`/`jsdom`/`canvas`. **Contourné** avec `npm install --legacy-peer-deps` (à réutiliser si le projet est recloné/réinstallé).
**Audit refactor : 8/10** — code minimal et propre pour une appli "bidon" ; l'URL du backend en dur côté frontend (`http://localhost:8080`) est une simplification POC à externaliser (config par environnement) avant TICKET-06/07.

## ♻️ Refactor — <date>
**Changé :**
**Pourquoi :**
**Risque :**
**Tests verts avant ET après :**

## 🚀 Validation — <date>
**Lancé en dev :** oui, en local via Docker (voir Test ci-dessus). Pas encore déployé sur k3s (viendra avec TICKET-06).
**Lancé en prod :** n/a à ce stade.
**DoD complète :** non — bloqué sur "Doc à jour" côté repo Bitbucket (le repo lui-même n'existe pas encore) et sur le déploiement réel k3s.
**Statut final :** ⏸ En pause, bloqué sur l'accès Bitbucket entreprise. Code prêt à pousser.

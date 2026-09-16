# Guide Développeur : K8s, Prometheus, Grafana & Loki (adapté au POC infra)

Guide pratique pour appréhender l'écosystème Cloud-Native utilisé dans ce POC (**Kubernetes / k3s**, **Prometheus**, **Grafana**, **Loki**). Contrairement aux tutoriels génériques, celui-ci colle aux décisions déjà actées dans [`01-tech-decisions.md`](../01-tech-decisions.md) (ADR-001 à ADR-003) et à la stack applicative réelle du POC (Spring Boot + Angular). C'est la référence technique des tickets [TICKET-10](../tickets/TICKET-10.md), [TICKET-11](../tickets/TICKET-11.md) et [TICKET-12](../tickets/TICKET-12.md).

---

## Table des matières
1. [Concepts Clés de Kubernetes (K8s)](#1-concepts-clés-de-kubernetes-k8s)
2. [Pourquoi K8s dans une Infra Dev ?](#2-pourquoi-k8s-dans-une-infra-dev)
3. [Écosystème d'Observabilité : Prometheus, Grafana & Loki](#3-écosystème-dobservabilité--prometheus-grafana--loki)
4. [Atelier Pratique : Mini-Projet Step-by-Step](#4-atelier-pratique--mini-projet-step-by-step)
5. [Anti-Sèche des Commandes Utiles (Cheat Sheet)](#5-anti-sèche-des-commandes-utiles-cheat-sheet)

---

## 1. Concepts Clés de Kubernetes (K8s)

Kubernetes est un **orchestrateur de conteneurs**. Il permet de gérer le déploiement, la mise à l'échelle et le maintien en condition opérationnelle de conteneurs (ex: Docker).

### Vocabulaire Essentiel

* **Pod** : La plus petite unité exécutable dans K8s. Un Pod regroupe un ou plusieurs conteneurs partageant le même réseau et stockage.
* **Deployment** : Déclare l'état souhaité d'une application (ex: "Je veux 2 instances du Pod *API Spring Boot*"). Il gère les mises à jour sans interruption (*Rolling Updates*).
* **Service** : Abstraction réseau permettant d'exposer un groupe de Pods sous un nom DNS stable et d'effectuer de la répartition de charge (*Load Balancing*).
* **ConfigMap / Secret** : Utilisés pour séparer le code de sa configuration. Les *ConfigMaps* gèrent les variables en clair, tandis que les *Secrets* gèrent les données sensibles (chiffrées en base64 — pas un vrai chiffrement, à garder en tête).
* **Namespace** : Isolation logique au sein d'un même cluster. Dans ce POC : **un namespace par environnement** (`dev`, `int`, `uat`, `prod` — ADR-002), plus un namespace `monitoring` dédié à Prometheus/Grafana/Loki (transverse, il observe les 4 autres).

---

## 2. Pourquoi K8s dans une Infra Dev ?

1. **Parité des environnements** : fin du fameux *"Ça marche sur ma machine !"*. Le même Deployment tourne en `dev`, `int`, `uat` et `prod`, seule l'image (tag) et la config changent.
2. **Autonomie (Self-Service)** : les besoins d'infra se déclarent en YAML, versionnés dans le repo aux côtés du code.
3. **Auto-guérison (Self-Healing)** : si un conteneur crash (erreur de code, *Out Of Memory*), Kubernetes le redémarre automatiquement.

> **Dans ce POC**, le cluster est un **k3s en single-node installé directement sur la VM de bureau** (ADR-001) — pas un cluster managé cloud ni un Minikube/Kind éphémère de poste perso. Minikube/Kind restent de bons outils pour s'entraîner sur un laptop personnel, mais ce n'est **pas** ce qu'on utilise ici : voir [TICKET-01](../tickets/TICKET-01.md).

---

## 3. Écosystème d'Observabilité : Prometheus, Grafana & Loki

Le problème de départ de ce POC est un déploiement actuel avec **zéro log serveur exploitable** (voir [`00-vision.md`](../00-vision.md)). Prometheus/Grafana seuls ne suffisent pas à le résoudre : ils couvrent les **métriques**, pas les **logs**. D'où l'ajout de **Loki + Promtail** (ADR-003).

```
[ Application (Spring Boot / Angular) ]
        │                    │
        │ expose /actuator/prometheus   │ écrit des logs (stdout/stderr du conteneur)
        ▼                    ▼
  [ Prometheus ]        [ Promtail ] (agent de collecte, un par nœud)
  (scrape 15s)                │
        │                     ▼
        │                 [ Loki ] (agrégation des logs)
        ▼                     │
  [       Grafana (dashboards metrics + logs)       ]
```

* **Prometheus** : moteur de collecte de métriques en mode *Pull* (il vient interroger l'application sur une URL, ex. `/actuator/prometheus`).
* **Loki + Promtail** : équivalent "logs" de Prometheus — Promtail lit les logs de chaque Pod (comme `kubectl logs`, mais en continu et persistant) et les pousse dans Loki, indexés par labels (namespace, app, pod…). C'est la brique qui répond directement au "0 log serveur" actuel.
* **Grafana** : interface unique qui interroge à la fois Prometheus (métriques, langage **PromQL**) et Loki (logs, langage **LogQL**), avec un croisement possible (ex: voir les logs au moment d'un pic CPU).

---

## 4. Atelier Pratique : Mini-Projet Step-by-Step

### Étape 1 : Le cluster (déjà couvert par TICKET-01)
Le cluster k3s single-node est installé sur la VM (voir TICKET-01). Toutes les commandes ci-dessous s'exécutent avec `kubectl` configuré sur ce cluster (`export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` en général sur k3s).

### Étape 2 : Déployer Prometheus + Grafana via Helm
```bash
# Ajouter le dépôt Helm officiel
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Namespace transverse dédié au monitoring (distinct des namespaces dev/int/uat/prod)
kubectl create namespace monitoring

# Installer le stack complet (Prometheus + Grafana + Alertmanager + CRD ServiceMonitor)
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

### Étape 3 : Déployer Loki + Promtail via Helm
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Loki (agrégation) + Promtail (collecte sur chaque nœud) dans le même namespace monitoring
helm install loki grafana/loki-stack -n monitoring --set grafana.enabled=false
```
`grafana.enabled=false` car on réutilise le Grafana déjà déployé à l'étape 2 (on y ajoute juste Loki comme source de données, étape 6).

### Étape 4 : Instrumenter le backend (Spring Boot)
Dans le `pom.xml` de l'appli pilote :
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Dans `application.properties` :
```properties
management.endpoints.web.exposure.include=health,info,prometheus
management.metrics.tags.application=${spring.application.name}
```

Spring Boot expose alors automatiquement les métriques sur `/actuator/prometheus` — pas besoin de code applicatif supplémentaire (contrairement à un `prom-client` en Node.js). Le front Angular, lui, n'expose pas de métriques Prometheus : son observabilité passe par les **logs** (Loki), via les logs du conteneur nginx qui le sert.

### Étape 5 : Déclarer l'application sur K8s (`app.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appli-pilote-api
  labels:
    app: appli-pilote-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: appli-pilote-api
  template:
    metadata:
      labels:
        app: appli-pilote-api
    spec:
      containers:
      - name: appli-pilote-api
        image: <registre>/appli-pilote-api:<tag>
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: appli-pilote-api
  labels:
    app: appli-pilote-api
spec:
  selector:
    app: appli-pilote-api
  ports:
  - port: 8080
    targetPort: 8080
```
Ce manifeste est déployé **dans chacun des 4 namespaces** (dev/int/uat/prod) par le pipeline Jenkins (TICKET-06 à TICKET-09) — seul le tag d'image et éventuellement la config changent d'un environnement à l'autre.

### Étape 6 : Connecter Prometheus avec un `ServiceMonitor`
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: appli-pilote-api-monitor
  namespace: monitoring
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: appli-pilote-api
  namespaceSelector:
    any: true          # scrape dans dev/int/uat/prod, pas seulement monitoring
  endpoints:
  - port: http
    path: /actuator/prometheus
    interval: 15s
```

### Étape 7 : Accéder à Grafana et ajouter Loki comme source de données
```bash
# Récupérer le mot de passe 'admin' généré automatiquement
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Exposer Grafana localement
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```
Dans Grafana → *Connections* → *Data sources* → *Add data source* → **Loki**, avec l'URL `http://loki.monitoring.svc.cluster.local:3100`. Prometheus y est déjà préconfiguré par le chart `kube-prometheus-stack`.

---

## 5. Anti-Sèche des Commandes Utiles (Cheat Sheet)

### Gestion des Pods & Déploiements
* `kubectl get pods -n <namespace>` : lister les Pods d'un namespace (ex: `-n dev`, `-n prod`).
* `kubectl logs -f <pod-name> -n <namespace>` : logs d'un Pod en temps réel (utile en dépannage ponctuel — Loki sert pour l'historique/la recherche).
* `kubectl exec -it <pod-name> -n <namespace> -- /bin/sh` : ouvrir un terminal dans un conteneur.
* `kubectl apply -f <fichier.yaml>` : appliquer une configuration YAML.
* `kubectl delete -f <fichier.yaml>` : supprimer les ressources définies dans le fichier.

### Débogage & Inspections
* `kubectl describe pod <pod-name> -n <namespace>` : événements et état détaillé d'un Pod.
* `kubectl port-forward svc/<service-name> 8080:80 -n <namespace>` : rediriger un port local vers un service K8s.

### Requêtes PromQL de base (métriques, Grafana)
* `up{job="appli-pilote-api"}` : l'application est-elle en ligne ? (1 = UP, 0 = DOWN).
* `rate(http_server_requests_seconds_count[5m])` : taux de requêtes/s sur 5 minutes (métrique standard Spring Boot Actuator).
* `container_memory_usage_bytes{namespace="prod"}` : RAM utilisée par conteneur, filtrée sur `prod`.

### Requêtes LogQL de base (logs, Grafana)
* `{namespace="dev"}` : tous les logs du namespace `dev`.
* `{app="appli-pilote-api", namespace="prod"} |= "ERROR"` : erreurs de l'appli pilote en `prod` — exactement ce qui manquait avec XLDeploy.
* `{namespace="uat"} |= "Exception"` : recherche de stacktraces en `uat`.

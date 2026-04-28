# Rapport de Stage : Développement de l'Application "Ordex"

**Nom de l'étudiant :** [Votre Nom]
**Période de stage :** [Dates du stage]
**Entreprise d'accueil :** [Nom de l'entreprise]
**Tuteur de stage :** [Nom du tuteur]

---

## Remerciements

Avant tout développement sur cette expérience professionnelle, je tiens à remercier [Nom de l'entreprise ou des personnes], pour m’avoir accueilli(e) en tant que stagiaire et pour leur accompagnement tout au long de ce projet enrichissant.

---

## 1. Introduction

Dans le cadre de ma formation, j'ai eu l'opportunité de réaliser un stage au sein de [Nom de l'Entreprise]. Ma mission principale a consisté à concevoir, développer et moderniser une application de gestion commerciale complète nommée **Ordex**.

Le but de cette application est de fournir aux entreprises et indépendants un outil intuitif, performant et visuellement irréprochable pour gérer leurs ventes, leurs clients, leurs services ainsi que d'analyser leurs performances financières à l'aide de tableaux de bord ergonomiques.

Ce rapport détaille la présentation du projet, l'analyse des besoins, ainsi que les choix technologiques et architecturaux réalisés au cours du développement.

---

## 2. Présentation du Projet : "Ordex"

**Ordex** est une application mobile cross-platform visant à digitaliser et centraliser la gestion d'une activité commerciale professionnelle.

L'application a été pensée avec une approche « Mobile-First » en apportant un soin tout particulier à l'UI/UX (Interface et Expérience Utilisateur), avec des thèmes personnalisables et des animations fluides offrant un ressenti haut de gamme (« Premium »).

### 2.1. Fonctionnalités Principales

Les besoins ont été traduits en plusieurs modules fonctionnels :

- **Module d'Authentification (`auth`) :** Flux de connexion sécurisé pour les utilisateurs.
- **Gestion des Clients (`clients` & `client_dashboard`) :** Création, modification et suivi du répertoire de clients avec une vue détaillée par client.
- **Gestion des Services (`services`) :** Catalogue des prestations et services offerts par l'entreprise.
- **Gestion des Ventes et Commandes (`sales`) :** Interface de facturation et de création de commandes (avec gestion des devises locales, ex: DH).
- **Tableau de Bord Analytique (`dashboard`) :** Visualisation des données clés de l'entreprise (Chiffre d'affaires, statistiques) grâce à des graphiques dynamiques et des indicateurs de performance.

---

## 3. Choix Technologiques

Pour répondre aux exigences de performances, de rapidité de développement et de modernité, plusieurs technologies de pointe ont été sélectionnées :

### 3.1. Framework Frontend : Flutter et Dart
Le framework **Flutter** de Google a été choisi pour concevoir l'application. Il permet de compiler le projet nativement sur de multiples plateformes (Android, iOS) à partir d'une seule base de code en **Dart** (SDK version `3.11.0` et supérieure).
*Avantage :* Permet de créer des interfaces utilisateur riches, personnalisées, et animées tout en offrant d'excellentes performances.

### 3.2. Backend as a Service (BaaS) : Supabase
L'application repose sur **Supabase** (`supabase_flutter`), une alternative open-source complète à Firebase, intégrant une base de données relationnelle PostgreSQL, un système d'authentification et un stockage de fichiers.
*Avantage :* Gestion robuste de la base de données relationnelle, de l'authentification et des politiques de sécurité "Row Level Security" (RLS).

### 3.3. Gestion de l'Etat de l'Application : Riverpod
Pour gérer l'état global et les injections de dépendances de manière fiable, la librairie **Riverpod** (`flutter_riverpod`, `riverpod_annotation`) a été utilisée en conjonction avec la génération de code pour une syntaxe plus robuste.

### 3.4. Interface et Expérience Utilisateur (UI/UX)
Une grande importance a été accordée au rendu visuel :
- **Animations (`flutter_animate`, `animations`) :** Ajout de micro-animations fluides, notamment lors des changements de thèmes ("circular reveal") et pour les interactions au sein de l'application.
- **Typographie (`google_fonts`) :** Utilisation de polices modernes fournies par Google Fonts pour une esthétique soignée.
- **Data Visualization (`fl_chart`) :** Permettant le rendu de graphiques interactifs formidables (histogrammes, courbes, diagrammes circulaires) dans le tableau de bord des statistiques d'entreprise.
- **Localisation et Formatage (`intl`) :** Utilisé pour formater les devises (ex : en Dirhams "DH") et les dates.

---

## 4. Architecture Logicielle

Afin de garantir la maintenabilité, l'évolutivité et la séparation claire des responsabilités, l'application **Ordex** s'appuie sur une architecture orientée par fonctionnalités (*Feature-driven architecture*).

La structure du répertoire racine de l'application `lib/` est divisée de la manière suivante :

- **`core/`** : Contient tous les éléments centraux et réutilisables à travers l'application.
  - `models/` : Les modèles de données (ex : `order.dart`).
  - `services/` : Les services permettant de faire l'interface avec l'extérieur (ex : `supabase_service.dart`).
  - `theme/` : La définition du design system de l'application (couleurs, typographie).
  - `widgets/` : Composants UI génériques.
  - `providers.dart` : Déclarations de base pour la gestion de l'état.

- **`features/`** : Chaque dossier représente un module fonctionnel indépendant englobant sa propre logique métier, sa gestion d'état locale et ses interfaces graphiques (écrans).
  - `auth/` : Gestion de l'identité et du profil utilisateur.
  - `clients/` & `client_dashboard/` : Parcours utilisateur pour l'administration du portefeuille client.
  - `sales/` : Écrans de commandes et gestion des ventes (ex: `orders_screen.dart`).
  - `services/` : Gestion du catalogue des prestations.
  - `dashboard/` : Le point d'entrée pour l'analytics globale.

Cette structuration permet de travailler sur un module sans risquer de créer des régressions sur le reste de l'application. 

---

## 5. Bilan du Projet et Compétences Acquises

Ce stage fut particulièrement formateur. D'un point de vue technique, la mise en œuvre de **Flutter** avec un système de gestion d'état avancé comme **Riverpod** m'a permis d'appréhender des paradigmes modernes de la programmation réactive et déclarative. 
L'intégration du backend via **Supabase** a enrichi mes compétences concernant l'interaction entre les bases de données relationnelles (PostgreSQL) et l'authentification avec un client mobile. 

L'accent fortement mis sur l'aspect esthétique avec des bibliothèques telles que `fl_chart` et les animations (`flutter_animate`) m'a sensibilisé sur l'importance de l'UI/UX dans l'adoption d'un produit B2B par les utilisateurs finaux.

## 6. Conclusion

L'application **Ordex** offre aujourd'hui une expérience solide et élégante pour la gestion commerciale. Ce stage m'a non seulement permis de faire valoir mes apprentissages académiques, mais il a également cultivé ma passion pour le développement mobile et les méthodologies de travail en entreprise. Je quitte ce stage avec de nouvelles compétences concrètes, prêt à relever de nouveaux défis technologiques.

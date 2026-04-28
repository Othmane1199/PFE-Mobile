# -*- coding: utf-8 -*-
import os

markdown_content = """# Rapport de Stage : Conception et Développement de l'Application "Ordex1"

**Nom de l'étudiant :** [Votre Nom]
**Période de stage :** [Dates du stage]
**Entreprise d'accueil :** [Nom de l'entreprise]
**Tuteur de stage :** [Nom du tuteur]

## Remerciements

Je tiens tout d'abord à exprimer ma profonde gratitude envers [Nom de l'entreprise] et particulièrement à mon tuteur de stage, [Nom du tuteur], pour m'avoir intégré au sein de l'équipe de développement et pour m'avoir guidé tout au long de cette expérience professionnelle enrichissante. Je remercie également l'ensemble de l'équipe technique pour leur accueil chaleureux, leur disponibilité constante et leurs précieux conseils qui ont grandement contribué à la réussite de ce projet. Enfin, j'adresse mes remerciements à mes professeurs pour la qualité de l'enseignement reçu, qui m'a fourni les bases théoriques et pratiques indispensables à la réalisation de ce stage.

## 1. Introduction Générale

Dans le cadre de ma formation académique, j'ai eu l'opportunité d'effectuer un stage pratique au sein de [Nom de l'entreprise]. L'objectif principal de ce stage était de participer activement de A à Z à la conception, au développement et à la mise en production d'une application de gestion mobile avancée nommée **Ordex1**.

Le monde de l'entreprise moderne nécessite des outils de plus en plus performants pour gérer les relations clients (CRM), le suivi des ventes et l'analyse des performances. Le projet Ordex s'inscrit dans cette dynamique de digitalisation en offrant une solution unifiée, multiplateforme et hautement interactive. L'application permet non seulement la gestion des clients et des ventes, mais intègre également un tableau de bord analytique poussé pour faciliter la prise de décision.

Ce rapport détaille les différentes phases du projet, de l'étude préalable à l'implémentation technique, en mettant en exergue les choix technologiques pointus qui ont été opérés.

## 2. Présentation du Projet : Ordex1

**Ordex1** est une application mobile et bureau (cross-platform) dont l'ambition est de centraliser la gestion de l'activité commerciale d'une PME ou d'un travailleur indépendant.

### 2.1. Contexte et Objectifs

La gestion fragmentée des données (utilisation de fichiers Excel multiples, facturation séparée, suivi client archaïque) entraîne des pertes de productivité importantes. Ordex a pour vocation :
- **Centraliser** la base de données clients et l'historique de leurs interactions.
- **Automatiser** le suivi des ventes et la présentation du catalogue de services.
- **Visualiser** les performances de l'entreprise en temps réel via des graphiques interactifs.

### 2.2. Fonctionnalités Principales Développées

L'application est découpée en plusieurs modules fonctionnels clés correspondant aux besoins métiers :
- **Module d'Authentification (Auth) :** Gestion sécurisée des connexions, inscriptions et récupération de mots de passe.
- **Dashboard (Tableau de Bord) :** Écran principal offrant une vue d'ensemble métrique (Chiffre d'Affaires, nombre de clients, évolution des ventes).
- **Gestion des Clients (Clients & Client Dashboard) :** Répertoire digitalisé permettant d'ajouter, éditer et consulter les fiches clients détaillées.
- **Gestion des Services (Services) :** Module d'administration du catalogue de prestations offertes par l'entreprise.
- **Gestion des Ventes (Sales) :** Interface de saisie des commandes, de facturation et de suivi des paiements.

## 3. Étude Technologique et Architecture

Pour garantir la pérennité, la vitesse et l'esthétique du projet, un stack technique moderne a été rigoureusement sélectionné.

### 3.1. Flutter et le langage Dart

**Flutter**, développé par Google, est le framework principal utilisé pour la partie frontend. Son principal atout réside dans le fait de compiler nativement vers Android, iOS, Web et Desktop à partir d'une base de code unique écrite en **Dart** (version 3.11.0). 
Les avantages retenus pour le projet Ordex :
- **Performances natives :** Flutter dessine ses propres composants (Widgets) à 60/120 images par seconde.
- **Hot Reload :** Accélération considérable de la phase de développement.
- **Richesse de l'écosystème :** Accès à des packages de haute qualité pour les animations et graphiques.

### 3.2. Supabase : L'alternative Backend as a Service (BaaS)

Le projet s'appuie sur **Supabase** via le package `supabase_flutter`. Supabase repose sur PostgreSQL, une base de données relationnelle robuste. Ce choix a permis d'implémenter rapidement :
- **Authentification :** Gestion complète des sessions utilisateurs par token JWT.
- **Base de Données et RLS :** Utilisation du Row Level Security.
- **Temps Réel :** Possibilité d'écouter les changements de la base.

### 3.3. Gestion de l'état avec Riverpod

La complexité des données transitant dans l'application a nécessité l'utilisation de **Riverpod** (`flutter_riverpod`, `riverpod_annotation`). Il s'agit d'une solution de State Management garantissant la sécurité (compile-time safety).

### 3.4. Interfaces et Expérience Utilisateur (UI/UX)

L'application devait se démarquer par son aspect "Premium" :
- **fl_chart :** Intégration de graphiques de haute qualité (courbes d'évolution du CA).
- **flutter_animate et animations :** Implémentation de micro-interactions.
- **google_fonts :** Typographie moderne.
- **intl :** Formatage professionnel des devises et des dates.

## 4. Implémentation et Réalisation Architecturale

Le projet a adopté la **Clean Architecture** (Feature-First). 

### 4.1. Structure du projet

- **`lib/core/` :** Le cœur applicatif. Contient l'implémentation des services API (`supabase_config.dart`, `services/`), les modèles (`models/`), composants génériques (`widgets/`) et design (`theme/`).
- **`lib/features/` :** Isolé par domaine métier (`auth`, `clients`, `dashboard`, `sales`, `services`). Chaque entité est autonome.

### 4.2. Défis techniques rencontrés

1. **Synchronisation asynchrone des données :** Gérer correctement les exceptions réseau avec Riverpod `AsyncValue`.
2. **Construction du Dashboard interactif :** Traiter et agréger les données brutes des Ventes pour `fl_chart`.

## 5. Bilan et Compétences Acquises

Ce stage de développement mobile a été un véritable accélérateur de compétences. 
Sur le plan technique :
- Maîtrise avancée du framework Flutter et du langage Dart.
- Amélioration significative en algorithmie asynchrone via Riverpod.
- Compréhension des bases de données relationnelles avec Supabase.

Sur le plan professionnel et humain :
- Apprentissage des méthodologies agiles.
- Autonomie dans la recherche de solutions face à des problématiques backend complexes (RLS).
- Sensibilisation à l'importance de l'UI/UX dans les produits B2B.

## Conclusion Générale

Le projet Ordex1 a abouti à une application stable, performante et esthétiquement aboutie. Elle répond aux exigences initiales en centralisant intelligemment l'activité commerciale d'une entreprise. Ce stage restera une expérience charnière, me projetant concrètement dans mon futur métier d'ingénieur. Les compétences acquises me préparent solidement aux défis technologiques de demain.
"""

html_content = f"""<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
<head><meta charset='utf-8'><title>Rapport de Stage</title></head><body>
{markdown_content.replace('## ', '<h2>').replace('# ', '<h1>').replace('### ', '<h3>').replace('**', '<b>').replace('**', '</b>').replace('\n\n', '<br><br>')}
</body></html>"""

with open('Rapport_de_Stage_Ordex.doc', 'w', encoding='utf-8') as f:
    f.write(html_content)

print("Document generé avec succès : Rapport_de_Stage_Ordex.doc")

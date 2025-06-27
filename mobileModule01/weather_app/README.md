 🌦️ Weather App — Module 01 - EX00

## 🎯 Objectif de l'exercice

Créer la **structure de base** d'une application météo responsive avec Flutter.  
Elle comprend :

- Une barre supérieure (AppBar) avec un champ de recherche et un bouton de géolocalisation.
- Une barre de navigation inférieure avec 3 onglets :
  - "Currently" (Actuellement)
  - "Today" (Aujourd’hui)
  - "Weekly" (Semaine)
- Chaque onglet affiche un simple texte pour le moment.
- L’utilisateur peut **changer d’onglet en cliquant** ou **en faisant un glissement (swipe)**.

---

## 🧱 Widgets principaux utilisés

| Widget        | Rôle                                                                 |
|---------------|----------------------------------------------------------------------|
| `AppBar`      | Barre supérieure contenant le champ de recherche et les boutons      |
| `TextField`   | Champ de recherche pour entrer une ville                             |
| `IconButton`  | Boutons pour rechercher ou utiliser la géolocalisation               |
| `BottomAppBar`| Barre inférieure accueillant les onglets                             |
| `TabBar`      | Affiche les onglets avec icônes et textes                            |
| `TabBarView`  | Contenu affiché pour chaque onglet sélectionné                       |
| `TabController`| Synchronise l’onglet actif avec son contenu et gère les interactions |

---

## 🤖 Pourquoi `TabController` est important

Le `TabController` assure la **synchronisation entre les onglets** (visibles dans la `TabBar`) et leur **contenu respectif** (affiché via `TabBarView`).

### Ce qu’il permet :
- Gérer les **changements d’onglets via clic** ou **swipe horizontal**.
- Maintenir une **expérience utilisateur fluide** et cohérente.
- Sans lui, les onglets et leur contenu pourraient **ne pas rester coordonnés**.

---

## 🛠️ Lancer le projet

Exécutez `flutter run -d chrome` dans le repo pour lancer le projet dans le terminal.

Exécutez `flutter clean` pour supprimer tous les fichiers générés automatiquement par Flutter lors des précédentes compilations.
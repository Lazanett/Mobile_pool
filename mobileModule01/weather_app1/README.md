# 🌦️ CIUP - Weather App (Exercice Flutter)

Ce projet est une application Flutter simple de météo, développée dans le cadre du module mobile de la CIUP. Elle permet de rechercher la météo actuelle, du jour et de la semaine d'une ville donnée, avec une interface réactive et épurée.

---

## 📌 Résumé de l'exercice

**Sujet :**  
Créer une interface utilisateur Flutter composée de :
- Une `AppBar` contenant un champ de recherche et deux boutons (recherche manuelle & géolocalisation)
- Une `TabBar` pour naviguer entre trois vues météo
- Un affichage responsive qui s’adapte aux petites tailles d’écran
- Masquer dynamiquement certains éléments si l’écran est trop petit

---

## 🧠 Logique de l'application

- L’utilisateur peut taper un nom de ville dans le champ `TextField`
- Deux boutons sont proposés :
  - 🔍 Recherche par texte
  - 📍 Recherche par géolocalisation (simulation via texte)
- Une `TabBar` permet de naviguer entre :
  - **Currently** : météo actuelle
  - **Today** : météo du jour
  - **Weekly** : météo sur plusieurs jours
- Le contenu affiché change dynamiquement selon l’entrée utilisateur

---

## ⚙️ Points techniques importants

### ✅ Composants principaux

- `AppBar` personnalisée avec champ de recherche et boutons
- `TabController` & `TabBarView` pour gérer les onglets

## 🛠️ Lancer le projet

Exécutez `flutter run -d chrome` dans le repo pour lancer le projet dans le terminal.

Exécutez `flutter clean` pour supprimer tous les fichiers générés automatiquement par Flutter lors des précédentes compilations.
# 🔁 Module00 - EX01 : Texte interactif avec Flutter

## 🎯 Objectif de l'exercice

Dans cet exercice, l’objectif est de reprendre la base du projet précédent (**ex00**) et d’y ajouter une **interaction dynamique** :  
➡️ Faire en sorte que le texte affiché change lorsqu’on clique sur le bouton.

---

## 📚 Sujet

- Créer un nouveau projet `ex01` à partir du code de l'exercice précédent.
- À l’ouverture de l’application, un texte est affiché.
- Lorsqu'on clique sur le bouton, le texte doit **changer pour afficher** `Hello World!`.
- Si on clique à nouveau, le texte doit **revenir** à l'affichage initial (`Module00 ex01`).
- Le texte doit **alterner** à chaque clic sur le bouton.
- L'application doit être **responsive**.

---

## 💡 Concepts clés

| Élément Flutter       | Rôle                                                                 |
|------------------------|----------------------------------------------------------------------|
| `StatefulWidget`       | Widget avec un état modifiable (changement de texte ici).            |
| `setState()`           | Déclenche une reconstruction du widget lorsque l’état change.        |
| `Text`                 | Affiche dynamiquement le texte stocké dans la variable `displayText`.|
| `ElevatedButton`       | Bouton cliquable pour déclencher l’action.                           |

---

## 🛠️ Lancer le projet

Exécutez `flutter run -d chrome` dans le repo pour lancer le projet dans le terminal.

Exécutez `flutter clean` pour supprimer tous les fichiers générés automatiquement par Flutter lors des précédentes compilations.
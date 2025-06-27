# 🧮 Module00 - EX02 : Interface de Calculatrice (UI uniquement)

## 🎯 Objectif de l'exercice

Dans cet exercice, vous devez construire l'**interface graphique** d'une calculatrice fonctionnelle à l'aide de Flutter.  
Aucune logique de calcul n'est encore requise à ce stade.

---

## 📚 Sujet

Créer un projet Flutter `ex02` contenant :

- Une `AppBar` en haut avec le titre **Calculator**.
- Deux `TextField` :
  - Un pour afficher l’expression mathématique (ex: `12 + 8`).
  - Un pour afficher le résultat (ex: `20`).
- Une **grille de boutons** pour :
  - Les chiffres de `0` à `9`.
  - Le point `.` pour les décimales.
  - Les opérateurs `+`, `-`, `*`, `/`.
  - Le bouton `=`, qui affichera le résultat (logique ajoutée dans un exercice futur).
  - Le bouton `C` (effacer le dernier caractère).
  - Le bouton `AC` (réinitialiser expression et résultat).
- Chaque **appui de bouton** doit afficher son texte dans la **console de debug** (`debugPrint`).
- L’interface doit être **responsive** : s’adapter à toutes les tailles d’écran (mobile, tablette...).

---

## 💡 Concepts Flutter utilisés

| Élément Flutter              | Utilisation                                                                 |
|------------------------------|------------------------------------------------------------------------------|
| `AppBar`                     | Titre de l’application.                                                     |
| `TextField` (en lecture seule) | Affiche l’expression et le résultat.                                         |
| `GridView.builder`           | Affichage dynamique des boutons sur plusieurs lignes et colonnes.           |
| `MediaQuery`                 | Pour adapter dynamiquement la taille des éléments à l’écran.                |
| `ElevatedButton` + `CircleBorder` | Affichage stylisé des boutons de calculatrice.                              |
| `debugPrint()`               | Affichage du texte du bouton dans la console au clic.                       |

---

## 🛠️ Lancer le projet

Exécutez `flutter run -d chrome` dans le repo pour lancer le projet dans le terminal.

Exécutez `flutter clean` pour supprimer tous les fichiers générés automatiquement par Flutter lors des précédentes compilations.

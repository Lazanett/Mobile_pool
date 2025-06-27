# 🧠 Module00 - EX03 : calculator_app (Calculatrice Fonctionnelle)

## 🎯 Objectif de l'exercice

Dans cet exercice, vous devez rendre **fonctionnelle** l'interface de calculatrice réalisée précédemment.  
Vous allez utiliser la bibliothèque `math_expressions` pour gérer le calcul d'expressions mathématiques.

---

## 📚 Sujet

Créez un projet Flutter nommé `calculator_app` et ajoutez la **logique de calcul** derrière l’interface :

- Réutilisez le code de `ex02` (interface de la calculatrice).
- Utilisez la bibliothèque `math_expressions` pour évaluer les expressions saisies.
- Les `TextFields` doivent afficher dynamiquement :
  - L'expression mathématique.
  - Le résultat correspondant.

---

## ✅ Fonctionnalités à implémenter

| Fonction                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| ➕ ➖ ✖️ ➗                     | Gérer les quatre opérations de base (addition, soustraction, multiplication, division). |
| Calcul d'expressions         | Permettre des expressions multiples (ex: `1 + 2 * 3 - 5 / 2`).              |
| Nombres négatifs             | Possibilité de commencer une expression par un `-`.                        |
| Nombres décimaux             | Support du `.` pour écrire des nombres à virgule.                          |
| Correction (`C`)             | Supprimer le dernier caractère de l'expression.                            |
| Réinitialisation (`AC`)      | Vider l'expression et le résultat.                                         |
| Résultat (`=`)               | Calculer et afficher le résultat.                                          |
| Gestion des erreurs          | Afficher `Error` en cas d'expression invalide (ex: division par 0, etc.).  |
| Debug Console                | Afficher chaque bouton pressé dans la console (`debugPrint`).              |

---

## 🔧 Technologies et librairies

- **Flutter**
- 📦 [`math_expressions`](https://pub.dev/packages/math_expressions) – pour le parsing et l’évaluation des expressions.

---

## 💡 Concepts Flutter utilisés

| Élément Flutter         | Utilisation                                                                 |
|--------------------------|----------------------------------------------------------------------------|
| `StatefulWidget`         | Suivre les changements de l'expression et du résultat.                    |
| `GridView.builder`       | Affichage dynamique des boutons.                                          |
| `Text`                   | Affichage de l'expression et du résultat.                                 |
| `debugPrint()`           | Suivi des actions utilisateur en console.                                 |
| `setState()`             | Rafraîchir l'affichage après modification de l'état.                      |


---

## 🛠️ Lancer le projet

Exécutez `flutter run -d chrome` dans le repo pour lancer le projet dans le terminal.

Exécutez `flutter clean` pour supprimer tous les fichiers générés automatiquement par Flutter lors des précédentes compilations.

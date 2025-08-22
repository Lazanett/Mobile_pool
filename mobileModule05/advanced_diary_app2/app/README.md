# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Firebase is a mobile and web development platform offered by Google that provides tools for managing user authentication, storing data in real time, hosting applications, and much more. It allows you to quickly build applications without having to manage the entire server-side infrastructure.


-------------------------------------------------------------
|                  database organisation                    |
-------------------------------------------------------------
|   NOTES         |    FEELINGS   |  COLLECTIONS  |   USERS |
-------------------------------------------------------------
|     Id          |    Happiness  |   emailUser   |  email: |
| email: string   |    Sadness    |  nameCollec   |         |
| date:timestamp  |     Anger     |               |         |  
| title: string   |     Fear      |               |         |
| feeling: string |    Surprise   |               |         |
| content: string |    Disgust    |               |         |
|    nameCollec   |     Love      |               |         |
|                 |    Anxiety    |               |         |
|                 |     Calm      |               |         |
-------------------------------------------------------------


* Ainsi, pour récupérer tous les documents d’une collection :

SELECT * FROM documents WHERE nameCollection = "NomDeLaCollection";

* Et pour retrouver les collections d’un utilisateur :

SELECT * FROM collections WHERE emailUser = "user@example.com";

L'email doit etre unique, meme si le compte google et le compt github sont gerer par le meme email. ==>  link accound 
===> "EMAIL UNIQUE"
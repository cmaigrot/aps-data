# aps-data

Base de données pour l'application APS

## Pré-requis
Script adapté et testé pour postgreSQL 9.0 et supérieur

## Schéma
Toutes les tables préfixées par **facebook_** sont spécifiques aux données recueillies via la Graph API de facebook.
Toutes les tables préfixées par **twitter_** sont spécifiques aux données recueillies via l'API Twitter
Les autres tables sont utilisées pour la gestion de l'application aps-www ou communes aux informations de Twitter et Facebook.

### Vue générale

![Vue générale](https://github.com/rmonin/aps-data/blob/master/img/scheme-genral.png)

La base de données peut se schématiser vulgairement par l'ébauche ci-dessus.

La table user est en quelque sorte le point central de l'application car elle représente les profils suivis par les médecins.

À ces profils sont attachés un ou plusieurs comptes Facebook ainsi qu'un ou plusieurs comptes Twitter.

Une partie de la base est également destiniée au fonctionnement de l'application web (voir plus bas).

Enfin, une partie est dite *commune* car elle représente les tables qui sont à la fois utilisé coté Twitter et facebook (on peut considérer de la table user en fait partie)

Cette partie commune sert essentiellement à la manipulation des indices des messages disponnible dans notre application.

### Coté Facebook

![Coté Facebook](https://github.com/rmonin/aps-data/blob/master/img/scheme-facebook.png)

### Coté Twitter

### Commun & coté aps-www

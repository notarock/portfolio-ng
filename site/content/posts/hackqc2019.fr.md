---
title: HackQC 2019
author: Roch D'Amour
date: '2019-03-23'
categories:
  - Cedille
  - Blog
tags:
  - Compétition
---

# HackQC 2019
-----

Le hackathon HackQC est une compétition ou nous devons réaliser un projet en 48h en utilisant les données ouvertes de plusieurs organisations québécoises telles que
la ville de Montréal, de Québec, SAAQ et etc. Cette année, nous avons créer une équipe composées de plusieurs membres de Cédille et d'App|ETS pour participer à cette compétition
qui aura lieu à Québec. Ce que nous ne savions pas, c'est que nous allons remporter la première place!

![Photo des gagnants de HackQC](/images/HackQC-gagnant.JPG "Gagnants du HackQC 2019")

<sub> Photo prise par: Ralph Samson <sup>

Si le projet que nous avons réalisé vous intéresse, j'ai intégré la présentation de notre projet dans cet article. La voici: 

-----
# Tragile (Trajet facile)

Il existe beaucoup d'applications et de services pour le trafic routier et le transport en commun,
délaissant toujours une partie non négligeable et grandissante de citoyens dans une ville : les piétons et les cyclistes.
Le risque d'accident pour eux est pourtant très élevé. De plus, chaque personne est unique,
par conséquent chaque utilisateur a ses propres particularités qui influencent sa façon de se déplacer.
Nous avons voulu tenir compte des particularités de chacun, que la personne soit malvoyante, avec un enfant en bas âge, daltonien,
agoraphobe ou à mobilité réduite (personne en fauteuil roulant, poussette, voyageur avec valise, béquille, etc.).
Cela favorise l’accessibilité et la sécurité lors des déplacements de tous.

## Ce que le logiciel réalise

Tragile fournit à l'utilisateur différents itinéraires pour atteindre sa destination.
Chaque chemin est accompagné d'une note de sûreté.
Cette note est calculée à partir d'un ensemble de jeux de données, tels que la présence de feux piétonniers 
(sonores ou non) et l'archive des collisions automobiles d'une intersection.
Cela nous permet de calculer une note qui reflète les particularités de l'utilisateur.

## Améliorations futures

- Plateforme web pour les villes afin qu'elles puissent visualiser les intersections à risque. 
- Promouvoir l'accessibilité universelle en tenant compte de plus de critères pour les utilisateurs
- Considérer plus de modes de transport, tel que le transport en commun

## Comment nous l'avons implémenté

Pour commencer, nous avons composé notre logiciel en deux parties: 
- Serveur web, contenant les informations permettant de calculer l'indice d'accessibilité pour plusieurs chemins possibles entre le départ 
et la destination suivant les contraintes définies par l'usager.
- Application mobile, portail intuitif permettant de sélectionner un chemin et configurer son profil d'accessibilité

## Problèmes rencontrés

Lors de la conception et l'implémentation de notre logiciel, nous avons eu plusieurs soucis:

- La normalisation des données de différentes villes vers un format uniforme et réutilisable
- L'utilisation de nouvelles technologies pour l'application mobile.
- S'entendre sur le format de données qui sera partagé entre le client et le serveur.
- Trouver un algorithme afin de calculer l'indice de sûreté en tenant compte des contraintes émises par l'usager

## Code source

### [Backend](https://github.com/ClubCedille/hackqc2019) et [Frontend](https://github.com/eyjafjoll/HackQC19-UI)

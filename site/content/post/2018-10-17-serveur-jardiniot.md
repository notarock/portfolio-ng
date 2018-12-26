---
title: Serveur web pour JardinIoT
author: Club Cedille
date: '2018-10-17'
categories:
  - Cedille
  - Projet
tags:
  - Python
  - Internet des objets
  - Web
slug: web-jardiniot
---

## Pour commencer, parlons un peu de JardinIoT...

Le projet JardinIoT est un jardin autonome. Ce jardin est composé de "buckets" autonomes dans lesquels les
plantes sont semées. Un bucket comporte plusieurs sondes mesurant , entre autres, la température et l'humidité. Le
bucket, à l'aide du serveur, ajuste l'humidité de la terre, la température et la lumière que reçoit
la plante en se basant sur les données reçues par les sondes ainsi que sur différents facteurs, tels l'heure du jour et la date.

## Ce que nous avons fait

Après une séance de _brainstorming_, nous avons relevé plusieurs fonctionnalités à ajouter à ce serveur pour une première itération.
Ces fonctionnalités sont les suivantes:

- Afficher les informations d'un ou plusieurs "buckets".
- Se connecter à un "bucket" par MQTT afin d'enregistrer les valeurs des capteurs.
- Envoyer des commandes de contrôles tels que "activer fan" à un "bucket".

## Le résultat

Après plusieurs ateliers de groupes, nous avons terminé une première itération du serveur web.
Pour faire cette API, nous avons utilisé le framework _Flask_ en python. Ce framework simple permet de créer
une API web en à peine quelques lignes. Étant simple à apprendre, Python nous a permis de faire avancer le projet rapidement.

Avec cette itération, nous avons assez de fonctionnalité pour passer à la prochaine étape: visionner les données en temps réel
avec un panneau d'administration web qui permet aussi d'envoyer une commande à un bucket.

## [Code disponible ici](https://github.com/ClubCedille/jardiniot)

![portfolio](/static/images/portfolio.png)


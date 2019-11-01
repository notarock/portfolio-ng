---
title: Jouer avec les webhooks de Dockerhub 
author: Roch D'Amour
date: '2019-10-31'
categories:
- Blog
- Project
tags:
- Devops
- Golang
---

# Jouer avec les webhooks de Dockerhub
---

Maintenir un site web nécessite un peu d'entretien. Que ce soit pour la
rédaction du meilleur article au monde, ou simplement pour la mise en ligne de
cedit article, il y a une certaine quantité de temps à investir (impliquant
l'utilisation d'un _blog framework_ et non d'un cms.).

Heureusement, j'ai mis en place un peu de CI/CD et mon site web se _build_
automatiquement  lorsqu'il y a de l'activité sur github. Lorsque l'image est
mise à jour sur Dockerhub, il  ne reste plus qu'une étape. Je veux ajouter ces
modifications à  mon site web en production, je faisais alors ces étapes:


- `ssh user@server.com`
- `cd <somewhere>` 
- `git pull && docker-compose up -d`

C'est une tâche manuelle, choses que je hais. Honnêtement, j'ai mieux à faire
(comme jouer avec des configurations d'Emacs/Nixos). Je me suis donc dit que ce
serait le moment parfait d'apprendre Golang et de construire un outil qui met
automatiquement à jour mon site web lorsqu'une nouvelle image est disponible
sur dockerhub.

# Ce que l'outil doit accomplir
---

<center>
![ ](/images/golang-gopher.png "Banière Docker-Gopher")
</center>

Premièrement, c'est important de savoir dans quoi on s'embarque. Pour cet outil,
il y a seulement deux requis:

- L'outil doit mettre à jour le conteneur en fonction sur le serveur à distance

Fonctionnement _évènementielle_ pour ne pas questionner le registre de
  l'image à tout les deux minutes

Retirer la vieille image et le vieux conteneur une fois que le nouveau est en marche

- Être sécuritaire

Ne pas permettre à n'importe qui de simuler un message et ainsi, faire
fonctionner n'importe quelle image docker sur ma machine.


Plutôt simple, non? 

# Comment ça fonctionne
--- 

L'outils fonctionne comme un serveur web. Puisque les [Webhooks
Dockerhub](https://docs.docker.com/docker-hub/webhooks/) sont des messages HTTP POST
contenant une structure en JSON qui permet d'identifier la source de
l'évènement. Nous avons seulement besoin d'un point d'entrée pour l'application,
rien de plus.

Lorsqu'un webhook est intercepté, le programme vérifie que l'auteur du
repo de l'image est bien le propriétaire du serveur. Cela est vérifié en
observant la présence de la variable d'environnement `OWNER` dans la première
partie du `Repository.Name` envoyé dans le webhook.

Par la suite, le programme va effectuer les commandes qui auraient normalement
été faites par l'administrateur(moi) pour mettre à jour l'image. 

- `docker stop <Repository.Name>`
- `docker rm <Repository.Name>`
- `docker-compose pull <Repository.Name>`
- `docker-compose up -d <Repository.Name>`

Et voilà, en moins de 30 secondes, le site web est mis à jour sur le serveur.
Effectivement il y a un certain _downtime_ avec cette méthode, mais mon blog
n'est pas un service critique. 

_Ça fait en masse la job._

# Intéraction avec Docker depuis un conteneur
---

Ce petit serveur web doit rouler dans un conteneur, pour des raisons de portabilité.
Il est donc difficile d'avoir l'accès au processus Docker sur la machine hôte...

En fait, non. Ce n’est pas difficile. Regarde ce `docker-compose.yml`:

```
  gopdater:
    build:
      context: .
    container_name: gopdater
    environment: 
      - OWNER=__owner__
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./docker-compose.yml:/app/gopdater/docker-compose.yml
    ports:
      - 8080:8080
    restart: always
```

Plus particulièrement:
```
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Puisque sous Linux, tout est représenté par un fichier, il suffit seulement
d'utiliser un volume pour donner l'accès à notre socket Docker à l'intérieur du
conteneur. Il est donc possible de gérer Docker depuis un conteneur avec cette
méthode.

--- 
## Code source

### [Dockerhub-webhook-handler](https://github.com/notarock/dockerhub-webhook-handler)

---
title: Mise en ligne de Traefik
author: Roch D'Amour
date: '2018-12-30'
categories:
  - Blog
tags:
  - Devops
slug: mise-en-ligne-traefik
---

# Un changement nécessaire

Avant, j'utilisais Apache pour servir mon site web. C'était fait en PHP, alors je n'avais pas vraiment le choix
de faire avec. De plus, ma soeur avait besoin d'un site web, alors je l'ui ait configuré une installation
de Wordpress pour qu'elle puisse construire et s'occuper de son propre site web de manière indépendante.

Par contre, il y a quelques mois, j'ai fait face à un problème: comment faire pour servir un api nodejs
avec Apache? Et bien, ça me prenait Nginx! Par contre, Apache et Nginx ne peuvent pas rouler en même temps
sur la même machine.

C'était pour un cours à l'école: je voulais mettre mon application en ligne pour démontrer qu'elle fonctionne.
Sur le moment, j'ai fait ça rapidement:

- Installe nginx.
- Ferme apache2.
- Ouvre nginx.
- Démontre que mon projet fonctionne en classe.
- Ferme nginx.
- Ouvre apache.

Ça _fonctionne_, mais est-ce que c'est optimal? _Pas vraiment..._

J'ai donc décidé de migrer vers Nginx pour commencer. En faisant quelques recherches, j'ai découvert Traefik!
Un _reverse proxy / load balancer_ qui est facile à l'usage, dynamique, automatique, rapide, _full-featured_ et surtout, open source.
Cet outil est simplement magique!

![traefik](/images/traefik.png)

## Installation

Je vais être honnête et dire que mon premier serveur n'est pas propre. C'était la première fois que j'avais une machine virtuelle
accessible sur internet, et j'ai fait beaucoup de configurations croches pour que ça fonctionne. _Live and learn_.

J'ai donc créé une nouvelle machine virtuelle sur Digital Ocean afin de recommencer à neuf. Rien de mieux qu'un bon gros ménage!
Une petite recherche m'emmène sur un tutoriel : [installation de Traefik par Docker](https://www.howtoforge.com/tutorial/ubuntu-docker-traefik-proxy/)

Après avoir suivi le tutoriel, j'avais une installation fonctionnelle de traefik sur ma nouvelle machine virtuelle!

## Utilisation

La meilleure fonctionnalité de Traefik est la découverte des conteneurs et la mise en ligne automatique.
Mon premier cas d'utilisation de cette nouvelle machine fut la mise en ligne de ce site web.

`Hugo` peut très facilement rouler dans un conteneur. Lorsque le conteneur est en marche, le site web est disponible
à partir de 172.x.x.x:1313 sur la machine hôte. Avec traefik, je dois seulement m'assurer de partir le conteneur
dans le bon `network` et il va s'occuper de rendre accessible ce site web publiquement, et ce, sur
le bon URL.

Prenons par exemple `rochdamour.ca` comme nom de domaine. Lorsque traefik est configuré correctement,
il rendra disponibles les conteneurs actifs à l'adresse `<nom de container>.rochdamour.ca`. Ce qui veut dire
que pour publier `portfolio.rochdamour.ca`, j'ai dû faire:

```
docker build -t portfolio-ng .

docker run -d -p 1313:1313 --network="proxy" --name portfolio portfolio-ng
```

L'utilisation de `--name portfolio` est très importante: c'est ce qui va donner un nom
à notre conteneur actif. Traefik utilise ensuite ce nom pour rediriger les requêtes HTTP
`portfolio.rochdamour.ca` vers son conteneur respectif.

Voilà, c'est fait. Pour mettre en ligne un nouveau conteneur, il s'agit de le lancer avec un nom significatif.
Il sera ensuite accessible automatiquement!

## Graphiques et statistiques

Traefik permet aussi de visionner des statistiques de performance. Très cool, mais je ne crois pas m'en
servir puisque mon serveur est très petit et obtient peu de trafique.

![stats](/images/traefik-stats.png)

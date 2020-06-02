---
title: Gitlab Bot User
author: Roch D'Amour
date: '2020-06-01'
categories:
- Devops
- Gitops
---

## Context

Chez Civalgo, nous organisons souvent des hackathon dans lesquels nous pouvons explorer de nouvelles technologies,
proposer des idées, des améliorations à nos méthodes de travail, etc. Nous avons 24h pour
trouver quelque chose à montrer à l'équipe et les meilleures idées seront
intégrés. Le 11 mai dernier, nous avions réalisé un hackathon et cet article est le résultat de mes "24h" de _hacking_. je l'ai trouvé
assez intéressant et pensais que cela pourrait devenir utile à quelqu'un d'autre, donc j'ai
demandé si je pouvais le publier sur mon site Web.

# Automatisez les trucs ennuyeux...

![I am once again asking for your pull request review](/images/gitlab-bot/pls-review.png)

## Le problème

Certains jours, la gestion des merge-request et des rebases peut devenir une corvée.
Cela se produit presqu'à toutes les 2 semaines, lorsque nous nous concentrons
sur la fusion de tout le code produits depuis la version précédente, en vue
du déploiement d'une nouvelle version.

Voilà ce qui se produit généralement:
- Il y a 4 merge-request prêtes à fusionner.
- Quelqu'un passe en revue l'une des 4 merge-request et approuve les modifications.
- La merge-request a recu le nombre d'approbations nécessaire pour la fusion.
- L'utilisateur peut l'intégrer dans la branche master s'il a les droits, ou
  attendre qu'un responsable du repo fusionne le MR lorsqu'il voit qu'il est
  prêt à être intégré.

Les 3 autres merge-requests doivent être rebasées après l'intégration de l'autre MR.
Lors du rebase, ces merge-requests perdent leurs approbations et doivent être
réexaminées de nouveau.

Ce n'est pas vraiment un problème puisque gitlab vous permet de "Merge lorsque le pipeline passe" lorsque le MR ont 2 approbations.
Cela peut être un problème si nous essayons de rebaser et de merger plus d'une
merge-request à la fois, car l'un des deux MR devrait être rebasé, approuvé et fusionné à nouveau.

C'est le genre de problème qui est toujours gérable avec de petites équipes,
mais peut facilement devenir hors de contrôle avec de plus grandes équipes, des pipelines plus longs, etc ...

## Solution

En utilisant un compte de service gitlab et [cet outil](https://github.com/smarkets/marge-bot), il est possible d'automatiser
ce flow sur la base du principe "Not so rocket-science". Si tout le pipeline passe et
le nombre d'approbations requis est respecté, la merge-request *devrait*
éventuellement être intégré à master.

À l'aide d'un compte contrôlé par un bot, nous pouvons lui assigner une
merge-request une fois qu'elle est "prête" et il s'en occupera..

Prêt signifie:

- Peut être fusionné sans conflits
- Pipeline passe avec succès, le code est fonctionnel.
- Le nombre d'approbations requis est respecté, le code est de bonne qualité.
- Si la branche doit être rebasée, elle sera automatiquement rebasée si possible.
- S'il y a des conflits de fusion avec la branche cible, la merge-request sera
  assignée à l'auteur pour qu'il corrige le problème.
- Si un autre rebase est nécessaire après le succès des pipelines, il sera rebasé
à nouveau (et le pipeline se lancera à nouveau) jusqu'à ce qu'il soit dans un état propre (en supposant qu'il n'y a pas de conflits).

## Comment je fais pour configurer ça?

C'est assez simple en fait...

- Créez un nouveau compte utilisateur et ajoutez-le à **votre organisation**
- Accordez au bot l'accès administrateur ou mainteneurs sur les repos où vous voulez que le bot soit utilisé.
- Créez une combinaison de clés SSH et ajoutez-la sur le compte du bot.
(La clé privée doit être gardée privée bien sûr, uniquement utilisable par le bot lui-même)
- Générer une clé API à utiliser sur le compte du bot.
(Gardez également cette clé autant privé que possible).

### Déployer tout ça

Pour déployer le tout, j'ai utilisé notre environnement de staging, car il est supposé qu'il
sera **toujours** opérationnel. J'ai créé un secret kubernetes et un
déploiement. Ce n'est peut-être pas la façon la plus optimale de procéder, mais _it
works_.

bot-secret.yaml
``` 
apiVersion: v1
kind: Secret
metadata:
  name: bot-credentials
type: Opaque
data:
  MARGE_SSH_KEY: "<Your super secret SSH KEY here>"
  MARGE_AUTH_TOKEN: "<Your super secret AUTH TOKEN here>"
```


bot-deployment.yaml
``` 
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: gitlab-civalbot
spec:
  replicas: 1
  template:
    metadata:
      labels:
        purpose: automation
        name: gitlab-bot
    spec:
      restartPolicy: Always
      containers:
      - name: merge-bot
        imagePullPolicy: Always
        image: smarkets/marge-bot
        resources:
          requests:
            cpu: "50m"
            memory: "100M"
          limits:
            cpu: "100m"
            memory: "200M"
        env:
          - name: MARGE_GITLAB_URL
            value: "https://gitlab.com"
          - name: MARGE_SSH_KEY 
            valueFrom:
              secretKeyRef:
                name: bot-credentials
                key: MARGE_SSH_KEY
          - name: MARGE_AUTH_TOKEN 
            valueFrom:
              secretKeyRef:
                name: bot-credentials
                key: MARGE_AUTH_TOKEN

```

## Bot en action

### Merge réussie

![Terminal logs 1](/images/gitlab-bot/logs-1.png)

![Gitlab merge-request activity - Rebased](/images/gitlab-bot/gitlab-logs.png)

### Pas de pipeline mais les règles de repo indiquent qu'il doit avoir un succès de pipeline

![Terminal logs 2](/images/gitlab-bot/logs-2.png)

### Changements dans master, le bot a rebasé et attend le succès du pipeline.

![Terminal logs 3](/images/gitlab-bot/logs-3.png)

![Gitlab merge-request activity - Merged](/images/gitlab-bot/magic.png)

## Améliorations futures possibles

Avoir un compte bot peut ouvrir la voie à de nombreuses améliorations à nos méthodes de travail.
par exemple, nous pourrions utiliser [DangerBot](https://github.com/danger/danger) pour faire
une révisions automatisées et appliquer des règles de merge-request. Le bot Danger peut également être utilisé pour
résumé des informations utiles sur la merge-request,
qui pourrait autrement être ignoré lors de la revue de code.

Le bot peut exécuter une tâche dans CI et mettre à jour automatiquement une liste d'avertissements
disponible dans la section de commentaires des merge-requests. Quand il y a de
nouveaux changements, Ci se réexécute et met à jour le commentaire. Les commentaires peuvent inclure:
️️
- ⚠ Ce MR ne comprend pas de section «AVANT».
- ⚠ Ce MR ne comprend pas de section «APRÈS».
- 📉 Ce MR ne modifie aucun fichier de test.
- 🎉 Supprime plus de code qu'il n'en ajoute (*nice* 😎)
- 😥 Plus de 500 lignes (ou tout nombre que nous configurons) ont changé.
- 📦 Ajout / Suppression de n packages.
- Inclure un résumé des nouveaux modules npm

![Dangerjs, a summary tool](/images/gitlab-bot/danger.png)

## Sources

- [Marge-bot for GitLab keeps master always green](https://smarketshq.com/marge-bot-for-gitlab-keeps-master-always-green-6070e9d248df)
- [Danger bot](https://docs.gitlab.com/ee/development/dangerbot.html)
- [Danger JS](https://danger.systems/js/)
- [Danger + GitLab](https://danger.systems/js/usage/gitlab.html)

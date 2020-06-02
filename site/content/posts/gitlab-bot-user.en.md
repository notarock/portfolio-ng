---
title: Gitlab Bot User
author: Roch D'Amour
date: '2020-06-01'
categories:
- Devops
- Gitops
---

## Context

At Civalgo, we often organize hackathon in which we can explore new technology,
feature ideas, workflow improvements, or anything like this. You have 24h to
find something to show the team and the best ideas are kept. On may 11, we had
a hackathon and this article is the result of my "24h" of hacking. I found it
pretty interesting and thought it might become useful to someone else, so I
asked if I could publish it on my website and did just that.

# Automate the boring stuff...

![I am once again asking for your pull request review](/images/gitlab-bot/pls-review.png)

## The Problem

On some days, managing merge request and rebases can become a chore.
This happens almost once every 2 weeks when we are focusing on merging pending merge requests before a new release. 

This is what would typically happen:
- 4 merge request are ready to merge.
- Someone reviews one of the 4 merge requests and approve the changes.
- Merge request has met the approvals count requirement.
- The user can merge it if he has the rights to or wait for a repo maintainer to merge the MR when he sees it is ready for merge.

The other 3 merge requests needs to be rebased after the other MR was merged.
Upon rebasing, these merge requests loses their approvals and need to be reviewed again. 

This is not really a problem since gitlab lets you "merge when pipeline passes" when the MR has 2 approvals.
It can be a problem if we are trying to rebase and merge more than one merge-request at a time,
since one of the two MR would need to be rebased, approved, and merged again.

This is the kind of problem that are still manageable with small teams,
but can get easily out of hands with bigger teams, longer pipelines, etc...

## Solution

Using a gitlab service account and [this tool](https://github.com/smarkets/marge-bot), it is possible to automate
merges based on the "Not so rocket science" principle. If all pipeline passes and
the required approvals count is met, the merge-request *should* get merged eventually.

Using a bot-controlled account, we can assign a merge request to be merged once it is "ready".

Ready means:

- Can be mergedV
- Pipeline passed, code is functional.
- Required approvals count is met, the code is of good quality.
- If the branch need to be rebased, it will be rebased automatically if possible.
- If there are merge conflicts with the target branch, the merge-request will be assigned to the author.
- If another rebase is required after the pipelines passed, it will be rebased
again (And pipeline will launch again) until it's in a clean state (Assuming there is no conflicts).

## How do I set this up?

It's pretty simple actually...

- Create a new user account and add it to **Your Organization Name**
- Grant admin or maintainers access on repos where we want the bot to be used.
- Create an SSH key combination and add it on the bot account 
(Private key should be kept private of course, only usable by the bot itself)
- Generate an API key to use on the account 
(Also keep this as private as possible).

### Deploying this

To deploy this, I used our staging environment because it is assumed it will
**always** be up and running. I have created a kubernetes secret and a
deployment. This might not be the most optimal way to go about this, but _it
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



## Bot in action

### Successful merge

![Terminal logs 1](/images/gitlab-bot/logs-1.png)

![Gitlab merge-request activity - Rebased](/images/gitlab-bot/gitlab-logs.png)

### No pipeline but repo rules states it has to pass

![Terminal logs 2](/images/gitlab-bot/logs-2.png)

### Commited to master. Bot rebased and wait for pipeline to merge.

![Terminal logs 3](/images/gitlab-bot/logs-3.png)

![Gitlab merge-request activity - Merged](/images/gitlab-bot/magic.png)

## Possible future improvements

Having a bot account can pave the way for many improvements to our workflow. For
example, we could use [DangerBot](https://github.com/danger/danger) to make
automated reviews and enforce merge-requests rules. Danger can also be used to
summary useful information on merge-request
that could be otherwise overlooked while reviewing.

The bot can run a task in CI and automatically update a list of warnings
available inside the merge requests comment section. When updated,
the Ci reruns and update the comment. Comments can include:
️️
- ⚠ This MR does not include a `BEFORE` section.
- ⚠ This MR does not include a `AFTER` section.
- 📉 This MR does not modify any test files.
- 🎉 Removes more code than it adds (*nice* 😎)
- 😥 More than 500 (or any numbers we configure) lines changed.
- 📦 Added/Removed n packages.
- Include a summary of new npm modules

![Dangerjs, a summary tool](/images/gitlab-bot/danger.png)

## Sources

- [Marge-bot for GitLab keeps master always green](https://smarketshq.com/marge-bot-for-gitlab-keeps-master-always-green-6070e9d248df)
- [Danger bot](https://docs.gitlab.com/ee/development/dangerbot.html)
- [Danger JS](https://danger.systems/js/)
- [Danger + GitLab](https://danger.systems/js/usage/gitlab.html)

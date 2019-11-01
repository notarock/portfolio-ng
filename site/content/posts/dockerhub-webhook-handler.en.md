---
title: Playing with Dockerhub's Webhooks
author: Roch D'Amour
date: '2019-10-31'
categories:
- Blog
- Project
tags:
- Devops
- Golang
---

# Playing with Dockerhub's Webhooks
---

Maintaining a website requires a little maintenance. Whether it be
writing the best article in the world, or simply to put on line
this article, there is a certain time investment needed (implying
the use of a _blog framework_ and not a cms.).

Fortunately, I set up some CI / CD and my website is built
automatically when there is activity on github. When the image is
updated on Dockerhub, there is only one step left. I want to publish these
changes to my website online, and to do so I'd have to follow these steps:

- `ssh user@server.com`
- `cd <somewhere>` 
- `git pull && docker-compose up -d`

This is a manual task, something that I hate a lot. Honestly, I have better things to do
(like playing with Emacs / Nixos configurations). I told myself that
it would be the perfect time to learn Golang and build a tool that
automatically update my website when a new image is available
on dockerhub.


#  What the tool needs to accomplish
---

<center>
![ ](/images/golang-gopher.png "Gopher banner")
</center>

First, it's important to know what you're trying to accomplish when working on a
new tool. For this project, there are only two requirements:

- The tool must update the running container on the remote server

Must be an event-driven to prevent polling the docker registry
  every two minutes.

Remove the old image and old container once the updated container is running.

- Be secure.

Do not allow anyone to simulate a webhook and thus, run any docker image on my machine.

Rather simple actualy.

# How it works
--- 

The tool works like a web server. Since the [Dockerhub
 webhooks](https://docs.docker.com/docker-hub/webhooks/) are HTTP POST messages
 containing a structure in JSON that identifies the source of the event. We only
 need one entry point for the application, nothing more.

When a webhook is intercepted, the program make sure that the author of the
image repository is the owner of the server. This is verified by
looking for the `OWNER` environment variable in the first
part of `Repository.Name` sent in the webhook.

Subsequently, the program will perform the commands that would normally
been made by the administrator (me) to update the image and container.

- `docker stop <Repository.Name>`
- `docker rm <Repository.Name>`
- `docker-compose pull <Repository.Name>`
- `docker-compose up -d <Repository.Name>`

And now, in less than 30 seconds, the website is updated on the server.
Actually there is a certain _downtime_ with this method, but my blog
is not a critical service.

# Interaction with Docker from a container
---

This small web server must run in a container, for portability reasons.
It is therefore difficult to have access to the Docker process on the host machine ...

Actually no. It's not difficult. Look at this `docker-compose.yml`:
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

Especially this part:
```
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Since under Linux, everything is represented by a file, we only need to include
our Docker socket into de container. This can be done using the volume
functionnality. By doing so, it is therefore possible to manage Docker from a container.

--- 
## Source code

### [Dockerhub-webhook-handler](https://github.com/notarock/dockerhub-webhook-handler)

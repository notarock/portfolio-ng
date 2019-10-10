---
title: Deploying Traefik
author: Roch D'Amour
date: '2018-12-30'
categories:
  - Blog
tags:
  - Devops
---

# A necessary change

Before, I used Apache to serve my website. It was done in PHP, so I did not really have a choice
but to deal with it. In addition, my sister needed a website, so I set up a
Wordpress installation so she could build and manage her own website independently.

A few months ago, I faced a problem: how do I serve a nodejs api with Apache?
Well, I had to use Nginx... On the other hand, Apache and Nginx can not be use both at the same time.

It was for a school project: I wanted to put my application online to show that it works.
I just wanted it to work, so I did the thing:

- Install Nginx.
- Apache2 Disable.
- Start Nginx.
- Demonstrates that my project works in class.
- Disable nginx.
- Restart Apache.

It works, but is it optimal? _Not really..._

So I decided to migrate to Nginx to start. But! While doing some research, I discovered Traefik!
A _reverse proxy / load balancer_ which is easy to use, dynamic, automatic, fast, _full-featured_ and above all, open source.
This tool is just magic!

![traefik](/images/traefik.png)

## Installation

I will be honest and say that my first server was never _clean_. It was the first time I had a virtual machine
accessible on the internet, and I made many configurations for it to work. _Live and learn_.

So I created a new virtual machine on Digital Ocean to start anew.
A little research took me to that tutorial: 
[Traefik installation by Docker](https://www.howtoforge.com/tutorial/ubuntu-docker-traefik-proxy/)

After following the tutorial, I had a functional installation of traefik on my new virtual machine!

## Usage

The best feature of Traefik is automatic service discovery.
My first use case of this new machine was to deploy this website.

`Hugo` websites can be containerized fairly easily. When the container is running, the website is available
from 172.x.x.x:1313 on the host machine. With traefik, I only have to make sure to leave the container
in the selected docker `network` and it will take care of making it accessible for the outside world, and this, on
the desired URL.

Take, for example, `rochdamour.ca` as a domain name. When traefik is configured correctly,
it will make active containers available at the address `<container name> .rochdamour.ca`. Which means
that to publish `blog.rochdamour.ca`, I had to do:

```
docker build -t blog .

docker run -d -p 1313:1313 --network="proxy" --name portfolio portfolio-ng
```

The use of `--name portfolio` is very important: that's what will give a name
to our active container. Traefik then uses this name to redirect HTTP requests
`portfolio.rochdamour.ca` to its respective container.

There it is. To put a new container online, you only have to start it with a meaningful name.
It will then be accessible automatically!

## Graphs and statistics

Traefik also allows you to view performance statistics. Very cool, but I do not think
it will be that usefull since my server is very small and gets little traffic.

![stats](/images/traefik-stats.png)

## Update as of 2019

I now use docker-compose to manage my container names. No more `docker build -t <name>`!

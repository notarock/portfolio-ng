---
author: Roch D'Amour
date: '2019-03-23'
categories:
  - Cedille
  - Blog
tags:
  - Compétition
slug: HackQC 2019
---

# HackQC 2019
-----

The hackathon is a competition where we must realize a project in 48h using the open data of several Quebec organizations such as
City of Montreal, Quebec City, SAAQ, etc. This year, we have created a team composed of several members of Cédille and App | ETS to attend this competition
which took place in Quebec City. What we didn't knew was that we were about to win the first place!

![Photo des gagnants de HackQC](/images/HackQC-gagnant.JPG "Gagnants du HackQC 2019")

<sub> Picture by: Ralph Samson <sup>

If the project that we realized interests you, I integrated the presentation of our project in this article. There it is:

-----
# Tragile (Easy Traveling)

There are many applications and services out there for road traffic and public transit, but they are all
leaving a significant and growing part of citizens in a city: pedestrians and cyclists.
The risk of an accident for them is however very high. In addition, each person is unique,
therefore each user has his own peculiarities that influence his way of traveling.
We wanted to take into account the peculiarities of everyone, however it be the person is visually impaired, with an infant, colorblind,
agoraphobic or mobility impaired (wheelchair, stroller, traveler with suitcase, crutch, etc.).
This promotes accessibility and security when everyone travels using the safest path.

## What our software do

Tragile provides the user with different routes to reach his destination, and every path is accompanied by a safety index.
This score is calculated from a set of datasets, such as the presence of pedestrian lights
(sound or not) and the archive of automobile collisions of an intersection.
This allows us to calculate a safety index that reflects the particularities of the user.

## Future improvements

- Offer a web platform for cities so that they can visualize intersections at risk.
- Promote universal accessibility by taking into account more criteria for users.
- Consider more modes of transportation, such as public transit.

## How we implemented it

To begin, we composed our software in two parts:
- Web server, containing the information to calculate the accessibility index for several possible paths between the departure
and the destination according to the constraints defined by the user.
- Mobile app, intuitive portal to select a path and configure its accessibility profile

## Problems encountered

During the design and implementation of our software, we had several problems:

- The normalization of different cities's data to consistent and reusable format.
- Selected technologies for the mobile application.
- Agreeing on the data format that will be shared between the client and the server.
- Creating an algorithm to calculate the security index while taking in account the constraints issued by the user.

## Source code

### [Backend](https://github.com/ClubCedille/hackqc2019) & [Frontend](https://github.com/eyjafjoll/HackQC19-UI)

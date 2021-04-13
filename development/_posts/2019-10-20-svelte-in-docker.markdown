---
layout: post
title:  "Developing Svelte in Docker"
date:   2019-10-20 12:39:00
author: Justin
image:
  path: /assets/img/development/svelte-in-docker/header.png
---

TLDR: I fixed the Svelte JS template to use Docker and offer live reloading. Check it out [here](https://github.com/ScienceVikings/svelte-template).

So I wanted to try out this slick new JS framework called [Svelte](https://svelte.dev/).

Everything about it looks totally awesome, except the weird `if/else` [syntax](https://svelte.dev/examples#else-if-blocks). I figured everything else looked so good, I could handle that one quirk.

I'm a [Docker](https://www.docker.com/) man now, and run everything almost exclusively in containers so, I figured I'd just get this baby going in a container and give it a fair shake.

I thought doing so would be rather easy. Just hop into a `node` container with a shared volume and use their template with `npx degit` to create the code and run things. To my suprise, the docker work was tedious and the live reloading wasn't working.

Any normal person would've given up there, but I wasn't going to be defeated so easily.

First, Svelte only loaded up for localhost. This doesn't fly in container land because you need to map ports and the container needs bind to the outside world. So I added `--host 0.0.0.0` to the `package.json` file where the Svelte cli did work and that solved the connection problem.

Now for live reloading. Through tireless research, I figured out by searching through bugs in their GitHub page that I could use [`chokidar`](https://github.com/paulmillr/chokidar) as a Live Reload tool.

There is some odd debate about using `chokidar` as the main reload library because of it's size and such, but it looks like it should be mainstream soon. Hopefully that will render this part obsolete in the near future. Problem solved!

This is all great, but looking back, I had to change a bunch of weird things in their template, then add a `Dockerfile` and `docker-compose.yaml` which I'd need for every new project. So, I forked their template and updated it so that it would be easier for everyone else wanting to just get in there and try some Svelte. I also have a single Docker command that will initialize a project for you. Here is the [repo](https://github.com/ScienceVikings/svelte-template).

Once they decide on a live reload tool and merge it in, I'll offer a pull request with Docker things. Until then, just follow the instructions on the SVL template fork and you should be good to go.

Good luck and stay svelte!
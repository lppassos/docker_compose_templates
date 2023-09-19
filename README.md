# Docker Compose personal repository

Collection of my personal docker-compose configurations for different
technologies.

These repositories are setup for personal development use, with little
security or scalability concerns.

They are to be used in very basic development scenarios with very little load
just to get familiarized wiuth the various components involved in this type
of deployments.

They can also be used for experimentation on techniques when performance is
not a concern.

# Dependencies

Make sure you have installed a docker environment.

## Windows

I personally use [Rancher Desktop](https://rancherdesktop.io/), with a docker-cli backend.

In order to limit the memory assigned to your containers I'd recomend limiting
the WSL memory.

Edit `~\.wslconfig` to have the following:

```
[wsl2]
memory=8GB
```

In this example I gave it 8GB, but you should adjust this appropriately to your
host machine. Check what is the normal memory usage of your development environment
and limit wsl2 so that it doesn't use that memory.


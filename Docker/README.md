# Docker
Docker is a great tool to create containers and use those containers for specific things. I created a very basic container that had all the tools I needed for development. 

Also, data persistence for the container would be useful. My initial goal was to use Pyenv to create a machine that could change its Python version easily. However, it became tricky to implement - so I simply created two containers, one with Python 3.5 and one with Python 2.7.

To build these containers you can simply run: `docker build -t <name> . ` where `<name>` is what you want to call the container. You can run this in the [Python2](/Docker/Python2) folder or the [Python 3](/Docker/Python3) folder.

Once that has finished you simply need to run `docker run -it <name>` where `<name>` is the name you specified when you built the container.

These containers have the following:
* python2/3
* C++
* Git
* Java

# Resources
* [Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#cmd)
* [Getting Started with Docker](https://docs.docker.com/get-started/part2/#run-the-app)
FROM ubuntu:18.04

RUN mkdir ~/Code

RUN apt-get update && apt-get install -y \
    python2 \
    g++ \
    git \
    default-jdk \
    build-essential \
    curl \
    && git config --global user.email "myemail@gmail.com" \
    && git config --global user.name "Angus" \
    && rm -rf /var/lib/apt/lists/*
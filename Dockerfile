FROM maven:3.6.3-openjdk-8
RUN apt-get update -y && apt-get install -y build-essential

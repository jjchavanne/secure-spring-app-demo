FROM maven:3.8.5-jdk-11 as build

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID ubuntu \
    && useradd --uid $USER_UID --gid $USER_GID -m ubuntu \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /app
COPY app /app
RUN mvn clean package

FROM tomcat:10-jdk11-openjdk-slim

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID ubuntu \
    && useradd --uid $USER_UID --gid $USER_GID -m ubuntu \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu

USER ubuntu
COPY flag /flag
EXPOSE 8080
COPY --from=build /app/target/helloworld.war $CATALINA_HOME/webapps

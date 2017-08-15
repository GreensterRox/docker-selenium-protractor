FROM centos:7
MAINTAINER Adrian Green

USER root

# Install Node
ENV NODEJS_VERSION=v6.10.3
ENV PATH=/apps/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin

RUN yum -y install make gcc gcc-c++ && yum -y clean all
RUN mkdir /apps && cd /apps && curl -s -L -O https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.xz && tar xf node-${NODEJS_VERSION}-linux-x64.tar.xz && mv node-${NODEJS_VERSION}-linux-x64 node


# Install Java
ENV JDK_VERSION 1.8.0
RUN yum -y install tar java-$JDK_VERSION-openjdk && rm -rf /var/cache/yum
RUN yum -y groupinstall "X Window System" "Desktop" "Fonts" "General Purpose Desktop"

# Install Firefox
RUN yum -y install wget
WORKDIR /opt
RUN yum -y install firefox libXfont Xorg
RUN wget https://ftp.mozilla.org/pub/firefox/releases/45.1.1esr/linux-x86_64/en-GB/firefox-45.1.1esr.tar.bz2
RUN tar xvfvj firefox-45.1.1esr.tar.bz2 -C /opt
RUN ln -sf /opt/firefox/firefox /usr/bin/firefox
RUN chmod 755 /usr/bin/firefox
RUN yum -y install Xvfb
ENV DISPLAY :99

# User
RUN useradd -ms /bin/bash myuser
USER myuser

# Add application source
WORKDIR /
ADD . /sl_acceptance_tests
WORKDIR /sl_acceptance_tests

# Apply user permissions
USER root
RUN mkdir /sl_acceptance_tests/jenkins/report
RUN chown -R myuser /sl_acceptance_tests
USER myuser

# Install npm modules
RUN npm install

# Make protractor available on CLI
USER root
RUN ln -sf /sl_acceptance_tests/node_modules/.bin/protractor /apps/node/bin/protractor
RUN  ln -sf /sl_acceptance_tests/node_modules/.bin/webdriver-manager /apps/node/bin/webdriver-manager
USER myuser

# Install Selenium and Chrome driver
RUN webdriver-manager update --standalone

ENV NODE_ENV=local

# Entry command
CMD ["/sl_acceptance_tests/docker-run.sh", "start"]

#USER root

# Example commands
#docker build -t sl-tests .
#docker run -d --rm --name sl-tests sl-tests:latest

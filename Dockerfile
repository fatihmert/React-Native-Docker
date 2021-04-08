FROM openjdk:8

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" 
ENV ANDROID_HOME="/usr/local/android-sdk" 
ENV NVM_DIR /usr/local/nvm

# from versions.env file
ARG ANDROID_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION
ARG GRADLE_VERSION
ARG MAVEN_VERSION
ARG NODE_VERSION
ARG NPM_VERSION

RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g npm@$NPM_VERSION

# check version
RUN node -v && npm -v

RUN apt-get update && apt-get -y install unzip

WORKDIR ${ANDROID_HOME}

# get android sdk manager
RUN curl -sL -o android.zip ${SDK_URL} && unzip android.zip && rm android.zip
# https://stackoverflow.com/a/45782695/1555993
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# android sdk manager installing
RUN $ANDROID_HOME/tools/bin/sdkmanager --update
# https://stackoverflow.com/a/59907256/1555993
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# gradle
RUN curl -sL -o gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}.zip &&\
 mkdir /opt/gradle && unzip -d /opt/gradle gradle.zip && rm gradle.zip

# mamven
RUN curl -sL -o maven.zip https://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip && \
    mkdir /opt/maven && unzip -d /opt/maven maven.zip && rm maven.zip

# update paths
RUN export PATH=$PATH:$ANDROID_HOME/emulator\
    && export PATH=$PATH:$ANDROID_HOME/tools\
    && export PATH=$PATH:$ANDROID_HOME/tools/bin\
    && export PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin\
    && export PATH=$PATH:/opt/maven/apache-maven-${MAVEN_VERSION}/bin\
    && echo PATH=$PATH:$ANDROID_HOME/platform-tools>>/etc/bash.bashrc

# starting js server fix
# https://stackoverflow.com/a/58559707/1555993
RUN echo "#!/bin/sh \n\
    echo "fs.inotify.max_user_watches before update" \n\
    cat /etc/sysctl.conf\n\
    echo "\n______________________________________________updating inotify ____________________________________\n" \n\
    echo fs.inotify.max_user_watches=10000 | tee -a /etc/sysctl.conf && sysctl -p \n\
    echo "updated value is" \n\
    cat /etc/sysctl.conf | grep fs.inotify \n\
" >> /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh
RUN sh /usr/local/bin/entrypoint.sh
RUN rm /usr/local/bin/entrypoint.sh

WORKDIR /app

RUN npm install -g yarn && yarn global add react-native-cli create-react-native-app

VOLUME ["/app","/root/.gradle"]


# export react native metro server and adb listening port
EXPOSE 8081 5037

CMD bash
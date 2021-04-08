# React Native Docker

React Native Docker Image, dynamic versioning you can changing `versions.env`. 

> Supported real device testing only MacOS, Linux. Not tested on **Windows**. Correctly working emulator.

Used NodeJS correctly versioning NVM in docker image. When you projects switching, you can use nvm in container.

## Android

It does not require action. Please look `How to Use` section.

## iOS

```
cd ios
pod install
```

Start Metro Bundler `react-native start` or `npm run start` or `yarn run start`

Lastly open `/ios/project.xcworkspace`, and run.

## Build Image

```
docker-compose --env-file ./versions.env up --build
```

## Only Start

```
docker-compose --env-file ./versions.env up
```

## How to Use

If you want created new project from scratch you can use in container `react-native init` command.

Otherwise, you should these files copy to your into the project root.

1. Install your project dependencies

```
yarn install
```

2. When dependencies completed install, run this command only once.

```
sh permission.sh
```

_If you get any error, never mind these that_

3. Run Metro Bundler

```
react-native start
```

4. Run (new terminal)

```
react-native run android
```

**Above steps should writing in container include yarn**

You can entering `docker exec` command to docker container. 

If you want run command not entered container;

```
docker exec -it <container_id> /bin/bash -c "<command>"
docker exec -it f79d /bin/bash -c "react-native start"
```

# Todo

 - [ ] React Dev Tools Forwarding
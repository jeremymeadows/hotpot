#!/bin/sh

USER=root
REMOTE_HOST=vps.jeremymeadows.dev
IDENTITY_KEY=~/.ssh/vps
APP_ROOT=/srv/sites/hotpot

name=hotpot-server
version=0.0.1

docker build . -t $name:$version
docker image tag $name:$version $name:latest
mkdir docker
docker image save $name:$version -o docker/${name}-$version.tar

scp -i $IDENTITY_KEY build/web/* docker-compose.yaml $USER@$REMOTE_HOST:$APP_ROOT
scp -i $IDENTITY_KEY .env.prod $USER@$REMOTE_HOST:$APP_ROOT/.env
ssh -i $IDENTITY_KEY $USER@$REMOTE_HOST "docker image load" < docker/${name}-$version.tar
ssh -i $IDENTITY_KEY $USER@$REMOTE_HOST << END
cd $APP_ROOT

docker image tag $name:$version $name:latest

docker compose down
docker compose up -d
END

echo "Deployed $name:$version to $REMOTE_HOST."

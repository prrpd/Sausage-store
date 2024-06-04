#!/bin/sh
set -xe
if [ $(docker --context remote ps -qf name=backend-blue) ]; then
    NEW_ENV="backend-green"
    CUR_ENV="backend-blue"
elif [ $(docker --context remote ps -qf name=backend-green) ]; then
    NEW_ENV="backend-blue"
    CUR_ENV="backend-green"
else
    NEW_ENV="backend-blue"
    CUR_ENV=""
fi
pwd
cat deploy.env 
echo "Starting "$NEW_ENV" container"
docker --context remote compose --env-file deploy.env up $NEW_ENV -d --pull "always" --force-recreate

echo "Waiting..."
sleep 35s

CONT=$(docker --context remote ps -f name=$NEW_ENV -q)
test=$(docker --context remote inspect --format='{{.State.Health.Status}}' $CONT)

if [ $test = "healthy" ]; then
    if [ -n "$CUR_ENV" ]; then
        echo "Stopping "$CUR_ENV" container"
        docker --context remote compose down $CUR_ENV
    fi
else
    echo "Container $CONT is not healthy, removing $NEW_ENV service"
    docker --context remote compose down $NEW_ENV 
fi
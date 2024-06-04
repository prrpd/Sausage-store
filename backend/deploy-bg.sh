#!/bin/sh
if CONT=$(docker ps -qf name=backend-blue); then
    NEW_ENV="backend-green"
    CUR_ENV="backend-blue"
elif CONT=$(docker ps -qf name=backend-green); then
    NEW_ENV="backend-blue"
    CUR_ENV="backend-green"
else
    NEW_ENV="backend-blue"
    CUR_ENV=""
fi

echo "Starting "$NEW_ENV" container"
docker --context remote compose --env-file deploy.env up $NEW_ENV -d --pull "always" --force-recreate

echo "Waiting..."
sleep 35s

test=$(docker inspect --context remote --format='{{.State.Health.Status}}' $CONT)
if [ $test = "healthy" ]; then
    if [ -n "$CUR_ENV" ]; then
        echo "Stopping "$CUR_ENV" container"
        docker --context remote compose down $CUR_ENV
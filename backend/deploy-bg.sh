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

echo "Starting "$NEW_ENV" container"
docker --context remote compose --env-file deploy.env up $NEW_ENV -d --pull "always" --force-recreate

echo "Waiting..."
sleep 10s

CONT=$(docker --context remote ps -f name=$NEW_ENV -q)
max_attempts=10
interval=3  # Time in seconds between attempts
attempt=0

while (( attempt < max_attempts )); do
    attempt=$(( attempt + 1 ))
    echo "Attempt $attempt:"

    TEST=$(docker --context remote inspect --format='{{.State.Health.Status}}' $CONT)

    if [ $TEST = "healthy" ]; then
        if [ -n "$CUR_ENV" ]; then
            echo "Stopping "$CUR_ENV" container"
            docker --context remote compose down $CUR_ENV
        fi
        exit 0
    fi
    sleep $interval
done

echo "Test did not pass successully after $max_attempts attempts."
echo "Container $CONT is not healthy, removing $NEW_ENV service"
docker --context remote compose down $NEW_ENV
exit 1



#!/bin/bash

ATTEMPTS_COUNTER=0

URL=$1
MAX_ATTEMPTS=${2:-10}

until $(curl --output /dev/null --silent --head --fail ${URL}); do
  if [ ${ATTEMPTS_COUNTER} -eq ${MAX_ATTEMPTS} ];then
    echo "Max attempts reached"
    exit 1
  fi

  printf '.'
  ATTEMPTS_COUNTER=$((${ATTEMPTS_COUNTER}+1))
  sleep 5
done

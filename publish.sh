#!/usr/bin/env bash
docker login
docker build --rm -f Dockerfile -t zondax/circleci .
docker push zondax/circleci

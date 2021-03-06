#!/bin/sh

registry_json=$(yc container registry get --name sysctl-tuner --format json || yc container registry create --name sysctl-tuner --format json)
registry_id=$(echo $registry_json | jq -r ".id")
IMAGE=cr.yandex/${registry_id}/tuner:latest
docker build -t ${IMAGE} .
yc container registry configure-docker
docker push ${IMAGE}
sed "s|%IMAGE%|${IMAGE}|" sysctl-tuner-operator.tpl > sysctl-tuner-operator.yaml
kubectl create ns sysctl-tuner
kubectl -n sysctl-tuner apply -f sysctl-tuner-operator.yaml

#!/usr/bin/env bash

kind create cluster --name=issue-1017
kubectx kind-issue-1017
kubectl create ns crossplane-system
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane --version 1.5.0 --wait

kubectl apply -f ./provider.yaml
kubectl wait "provider.pkg.crossplane.io/crossplane-aws" --for=condition=healthy --timeout=180s

AWS_PROFILE=default && echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)" > creds.conf
kubectl create secret generic aws-creds -n crossplane-system --from-file=creds=./creds.conf
rm creds.conf

kubectl apply -f ./providerconfig.yaml

## get latest crds in sync with kind-cluster
kubectl apply -f provider-aws/packages/crds/

#### localstack
localstack start

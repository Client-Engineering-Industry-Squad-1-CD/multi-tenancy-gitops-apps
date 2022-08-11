#!/usr/bin/env bash

# Set variables
if [[ -z ${DB_PASSWORD} ]]; then
  echo "Please provide environment variable DB_PASSWORD"
  exit 1
fi
if [[ -z ${DB_USER} ]]; then
  echo "Please provide environment variable DB_USER"
  exit 1
fi
if [[ -z ${SECRET_NAMESPACE} ]]; then
  echo "Please provide environment variable SECRET_NAMESPACE"
  exit 1
fi
DB_NAME=${DB_NAME:-PRODUCTS}
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic products-db-secret --type=Opaque \
--from-literal=DB_USER=${DB_USER} \
--from-literal=DB_PASSWORD=${DB_PASSWORD} \
--from-literal=DB_NAME=${DB_NAME} \
--dry-run=client -o yaml > DELETE_ME.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${SECRET_NAMESPACE} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < DELETE_ME.yaml > products-db-sealed-secret.yaml

# NOTE, do not check DELETE_ME.yaml into git!
rm DELETE_ME.yaml
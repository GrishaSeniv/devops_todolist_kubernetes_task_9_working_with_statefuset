#!/bin/bash
brew install kind

kind create cluster --name todoapp-cluster --config cluster.yml
kind delete cluster --name todoapp-cluster

kubectl apply -f .infrastructure/mysql-namespace.yml
kubectl apply -f .infrastructure/mysql-headless-service.yml
kubectl apply -f .infrastructure/mysql-secret.yml
kubectl apply -f .infrastructure/mysql-configMap.yml
kubectl apply -f .infrastructure/mysql-statefulSet.yml

kubectl get pods -n mysql -o wide
#!/bin/bash
brew install kind

kind create cluster --name todoapp-cluster --config cluster.yml

kubectl apply -f .infrastructure/mysql-namespace.yml
kubectl apply -f .infrastructure/mysql-headless-service.yml
kubectl apply -f .infrastructure/mysql-secret.yml
kubectl apply -f .infrastructure/mysql-configMap.yml
kubectl apply -f .infrastructure/mysql-statefulSet.yml

kubectl apply -f .infrastructure/namespace.yml
kubectl apply -f .infrastructure/pv.yml
kubectl apply -f .infrastructure/pvc.yml
kubectl apply -f .infrastructure/clusterIp.yml
kubectl apply -f .infrastructure/configMap.yml
kubectl apply -f .infrastructure/secret.yml
kubectl apply -f .infrastructure/hpa.yml
kubectl apply -f .infrastructure/deployment.yml
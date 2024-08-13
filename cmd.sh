#!/bin/bash
set -x

#Create Minio
oc new-project minio
oc apply -f ./01_minio
oc expose service minio --name minio-ui --port=ui
oc expose service minio --name minio --port=api

#Loki Stack / Logging

oc delete secret logging-loki-minio --ignore-not-found -n openshift-logging
oc create secret generic logging-loki-minio  --from-literal=bucketnames="loki" \
    --from-literal=endpoint="http://minio.minio:9000" \
    --from-literal=access_key_id="minioadmin" \
    --from-literal=access_key_secret="minioadmin" \
    -n openshift-logging
oc apply -n openshift-pipelines -f ./02_logging


#Create Pipelines
oc project pipelines
oc apply -f ./03_pipeline
oc apply -f ./04_pipelinerun


#
#
##Setup Results
#openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=tekton-results-api-service.openshift-pipelines.svc.cluster.local" -addext "subjectAltName = DNS:tekton-results-api-service.openshift-pipelines.svc.cluster.local"
#oc create secret tls -n openshift-pipelines tekton-results-tls --cert=cert.pem --key=key.pem
#oc create secret generic tekton-results-postgres --namespace=openshift-pipelines --from-literal=POSTGRES_USER=result --from-literal=POSTGRES_PASSWORD=$(openssl rand -base64 20)
#
#
#oc apply -n openshift-pipelines -f ./results
#oc create route -n openshift-pipelines passthrough tekton-results-api-service --service=tekton-results-api-service --port=8080
#
##Invoke APIs
#export RESULTS_API=$(oc get route tekton-results-api-service -n openshift-pipelines --no-headers -o custom-columns=":spec.host"):443
#export AUTH_TOKEN=$(oc create token pipeline)
#opc results list --addr https://${RESULTS_API} crc-results --authtoken $AUTH_TOKEN
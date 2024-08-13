# Guide to Install on CRC Cluster


## Reference Document
https://docs.openshift.com/pipelines/1.12/records/using-tekton-results-for-openshift-pipelines-observability.html#preparing-to-install_using-tekton-results-for-openshift-pipelines-observability

- Install Operators
  - Openshift Pipelines
  - Openshift Logging
  - Loki Stack

- Install minIO
- Install Result API
- Run Result APIs

Commands

``` 
  export RESULTS_HOST=$(oc get route tekton-results-api-service -n openshift-pipelines --no-headers -o custom-columns=":spec.host") 
  export RESULTS_API=$RESULTS_HOST:443

  openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=${RESULTS_HOST}" -addext "subjectAltName = DNS:${RESULTS_HOST}"

  oc create secret tls -n openshift-pipelines tekton-results-tls --cert=cert.pem --key=key.pem
  oc create secret generic tekton-results-postgres --namespace=openshift-pipelines --from-literal=POSTGRES_USER=result --from-literal=POSTGRES_PASSWORD=$(openssl rand -base64 20)


```
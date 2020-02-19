# Setup tmate-server K8s service

## Dependencies

### `gcloud`

Please follow https://cloud.google.com/sdk/install to install `gcloud`.

### `kubectl`

Please following instructions from https://kubernetes.io/docs/tasks/tools/install-kubectl to install `kubectl`

```bash
# MacOS
brew install kubectl

# Ubuntu
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

## Deploy a GKE cluster

```bash
# create a single node cluster
gcloud container clusters create --num-nodes=1 --zone=asia-northeast1 gp-releng-cluster-single-node-apj
```

## Access the GKE cluster

Getting K8s cluster configuration from GKE:

```bash
# update your kubectl config
gcloud container clusters get-credentials gp-releng-cluster-single-node-apj

# query the cluster information
kubectl cluster-info

# get GKE node information
kubectl get nodes
```

## tmate ssh server container image

The existing tmate server image can be found at: https://hub.docker.com/r/tmate/tmate-ssh-server. 
This image has to run with `SYS_ADMIN` capability to create nested namespaces to secure sessions. Hence the container will be run as privileged.

The current image depends on `SSH_KEY_PATH`, and assuming the keys are generated outside the container. This design allows the pods to be restarted, but still keep the same tmate ssh key used in `.tmate.conf` on the client side.

Please note that, we have to use the `tmate/tmate-ssh-server:latest` tag, since the `2.3.0` tag
looking for SSH keys from a different location.

## Create tmate-ssh-server service on GKE

Creating the service:
```bash
# ensure kubectl version is 1.17.3
kubectl version

# deploy the tmate-ssh-server service
make service
```

Now, let's understand what we have deployed:
```bash
# get k8s resources
$ kubectl get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/tmate-6c48c8b6b4-8fkls   1/1     Running   0          46s
pod/tmate-6c48c8b6b4-tnn4h   1/1     Running   0          46s

NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
service/kubernetes   ClusterIP      10.15.240.1     <none>          443/TCP          3h47m
service/tmate        LoadBalancer   10.15.253.219   35.223.204.31   2222:31442/TCP   34m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/tmate   2/2     2            2           46s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/tmate-6c48c8b6b4   2         2         2       46s

# get k8s secrets
$ kubectl get secrets tmate-keys
NAME         TYPE     DATA   AGE
tmate-keys   Opaque   3      3m55s
```

Under the hood, we deployed following resources to the K8s cluster:
- `deployment.apps/tmate`: a deployment composed of a single replica set
- `service/tmate`: which is a load balancer to map the external IP to internal applications `tmate`
- `replicaset.apps/tmate-...`: a replica set for tmate applications. We used 2 replicas to ensure HA of tmate service (only protected for deployment change, not node failure etc.)
- `pod/tmate-...`: the 2 pods that's actually running the `tmate-ssh-server`
- `secret/tmate-keys`: the secrets we created storing tmate ssh keys and `tmate.conf` for client

## Create .tmate.conf for people to login

We stored the `tmate.conf` as secret to the k8s service, so that we can just get the corresponding
`tmate.conf` from the deployed service directly.

```bash
# create ~/.tmate.conf using existing k8s tmate deployment
make config
```

## Other make targets

```bash
# create tmate keys under /tmp/tmate/keys
# these keys are used to create k8s secrets
# you have to use `make secret` to upload this keys
# once you update the new keys, you need to update 
# the `.tmate.conf` using `make config`
make keys

# upload local keys to remote as new secret for tmate server
make secret

# only change the deployments of tmate server
# don't touch the external service
make deploy
```

## Create HELM chart for the new tmate service

TBD

```bash
```

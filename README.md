# Immortals

**A demo on OTP stateful app deployment on k8 using Distributed Elixir**

**We are going to make stateful processes, that survive pod crashes and continue to live with old memory. Being Immortals..**

## Overview
---

- When a pod gets killed, its state is also destroyed
- We can leverage erlang distribution to handle state-handoff during pod crashes.
- Thus we can scale and deploy stateful apps in k8s.
- Deployment - Mix Releases + Docker + k8s

## Demo
---

### Prerequisite
- [docker](https://www.docker.com/)
- [minikubes](https://minikube.sigs.k8s.io/docs/start/)

### Start Minikubes

```
 minikube start --driver=docker 
 ```

### Create immortal deployment

```
git clone https://github.com/madclaws/immortals

cd immortals

# building docker image of immortals OTP app
docker build --tag immortals . 

# creating a k8 deployment with immortals image
kubectl create -f deployment.yml --validate=false
```  

#### Pods status

```
NAME                         READY   STATUS    RESTARTS   AGE
immortals-6fc5d7f687-m7pc8   1/1     Running   0          7s
immortals-6fc5d7f687-x9dsw   1/1     Running   0          7s
```

### Starting a new life
---
- Get a shell to the first pod

      kubectl exec -it immortals-6fc5d7f687-m7pc8 sh

- Remotely connect to first pod
       
       /app # bin/immortals remote

- Start a new life

       # Each life is a Genserver (in-memory), holding age as its state 
       iex(immortals@172.17.0.5)1> Immortals.start_life "Adam"
       {:ok, #PID<0.974.0>}

- Check the Age of a life

       # Age here is seconds passed
       iex(immortals@172.17.0.5)5> Immortals.get_age "Adam"
       381

### A Distributed life
----
- Get a shell to the second pod like first one in another window.
- Connect to the second pod.
- Try Getting age of Adam

        iex(immortals@172.17.0.4)1> Immortals.get_age "Adam"
        567
        
        # We can easily access the age of a process spawned in another pod


### Being Immortal
---  

- Delete the first pod

      # We are deleting the pod, where Adam lives...

      kubectl delete pod immortals-6fc5d7f687-m7pc8  

      # So basically Adam process will be terminated and state also should have gone...

- Check the logs of second (alive) pod
      
      
      kubectl logs immortals-6fc5d7f687-x9dsw -f 

      # check the end of log

      17:46:36.524 [warn]  Starting Life => [name: "Adam"]

      17:46:36.527 [info]  New life spawned to universe => Adam

      17:46:37.528 [warn]  Getting Age of Adam %{"Adam" => 1285}

      17:46:37.528 [info]  Adam's current age is 1285

      # We can see Adam is saved by Gods from the destroying pod 1
      # Basically Adam process is restarted and continue with old state.

### Call from the new world
---
- As soon as one pod is deleted, k8 automatically starts a new one, so we again have 2 pods.
- Get a shell to the new pod started by k8.
- Connect to the new pod remotely.
- Check Adam's age.

**Yes we can see Adam Never dies, he is an IMMORTAL**
# Openstack-k8s: Openstack Kubernetes deployment

This is an Openstack deployment based on Neutron (without any SDN solution) using kubernetes and docker containers. 

Features:
- Fast Openstack release upgrade: version is parameterized in Dockerfiles getting the code directly from upstream.
- Configuration files are externalized to the k8s ETCD. No containers based on config-files. Just get it from Etcd !!
- Kubernetes cluster is distributed automatically between all the hosts (using rancher to deploy it).
- Openstack Service definition is developed in k8s to be scaled (only the first time launched should create the db scheme and tables in keystone), so you can modify the replica parameter to scale up.

Openstack Services ready:
- Keystone
- Glance
- Neutron
- Horizon
- Cinder
- Mysql (Community - Galera cluster)
- Rabbitmq (Community - Rabbitmq cluster)
- Heat
- Nova-Controller
- Nova-Compute

Partially based on [Rancher](https://github.com/rancher) project: 
- We use Rancher DNS service to simplify the kubernetes deployment. Instead of that, you can use skydns in k8s or whatever you want.
- Rancher deploy automatically full kubernetes cluster distributed on all the hosts.
- Rancher is just a tool to manage the Openstack deployment as well as other platforms based on containers.
- Moreover, the kubernetes deployments files are used to generate Rancher catalogs in order to simplify the way to deploy it.


## Running:

The order needed to deploy the platform should be:

1. Load de config loader in order to get all the environment and configuration params to the Etcd service
   - Configure the [config-loader](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/general) renaming the file (without -sample) and configuring the password variables for all the services.
2. Deploy each service in the next sequence:
   - Mysql using the pxc-cluster
   - Rabbitmq cluster
   - Keystone (Must be the first openstack service to establish all the endpoint tables)
   - Glance
   - Nova-Controller
   - Neutron
   - Nova-Compute
   - The rest of services (cinder, swift, horizon...)

For this step, you can use [k8s-configs] (https://github.com/BBVA/openstack-k8s/tree/master/k8s-configs/kubernetes-templates) in order to deploy each service manually in kubernetes, or if you are using Rancher, you can load this folder as a Rancher Catalog.
  
## ETCD: Config loader

The idea is to provide a way to get all the configuration files params and environment variables to the openstack services containers.
The config-loader is a Pod launched just one time, which load all the params to the Etcd previously loaded:
1. General Environment by changing the file [config-loader](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/general)
2. Openstack service configuration (For instance, just change the params needed for [Glance](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/glance/). If you need some params extra for configure your environment, just add the line with the param needed.
      The config-loader process will do a merge between the default config-file params and the configuration params loaded here.

The Etcd scheme is configured in different branches to keep the information:

1. General Environment: Will be created a new branch in the Etcd named `general` where will be loaded all the enviroment params shown below. An example:
  ```
  general/MYSQL_ROOT_PASSWORD=mysql_password
  ```
2. Openstack service configuration: Will be created a branch with the next structure:
  * Node Role: Useful to separate into controller node, storage node or compute node
  * Service Name: The name of the service
  * Filename: The name of the configuration file which is needed to modify
  * Section: Inside the file, the section's name
  * Key=value: the key/value param will be modified

For instance, in a controller node with the glance service, if we need to modify the connection url inside the database section in the glance-api.conf file should be:
```
controller/glance/glance-api.conf/database/connection=mysql://glance:$GLANCE_DB_PASSWORD@$MYSQL_HOST/glance
```

## Kubernetes Deployment

For each service, you can use [k8s-configs] (https://github.com/BBVA/openstack-k8s/tree/master/k8s-configs/kubernetes-templates) in order to deploy each service manually in kubernetes. The deployment is based on:
 - Services
 - Replication Controllers
 - Pods

Obviously, you can deploy manually in kubernetes loading the service, and replication controller yaml files. If you are using Rancher to deploy the stack, just add the folder in the Rancher Server gui, to get available the new catalog.
After that, will be shown all the services available to deploy just with one click!


## Work In Progress:
We're working on the next services:
- cinder (debugging NFS driver connection)
- Swift (debugging)
- Sahara
- Magnum
- Trove
- Designate

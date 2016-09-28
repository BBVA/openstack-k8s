# openstack-k8s: Openstack Kubernetes deployment

This is an Openstack deployment based on Neutron (without any SDN solution) using kubernetes and docker containers. 

Features:
- Fast Openstack release upgrade: version is parameterized in Dockerfiles getting the code directly from upstream.
- Configuration files externalized to the k8s ETCD. No containers based on config-files. Just get it from Etcd !!
- Kubernetes cluster distributed automatically over all the hosts (using rancher to deploy it).
- Openstack Service definition developed to be scaled (only the first time launched should create the db scheme and params in keystone)

Partially based on [Rancher](https://github.com/rancher) project: 
- We use Rancher DNS service to simplify the kubernetes deployment.
- Rancher deploy automatically full kubernetes cluster distributed on all the hosts.
- Rancher is just a tool to manage the Openstack deployment as well as other platforms based on containers.
- Moreover, the kubernetes deployments files are used to generate Rancher catalogs in order to simplify the way to deploy it.


## Running:

The order needed to deploy the platform should be:

1. Load de config loader in order to get all the environment and configuration params to the Etcd service
  1.1 Configure the [config-loader](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/general) renaming the file (without -sample) and configuring the password variables for all the services.
2. Deploy each service in the next sequence:
  1. - Mysql using the pxc-cluster
  2. - Rabbitmq cluster
  3. - Keystone (Must be the first openstack service to establish all the endpoint tables)
  4. - Glance
  5. - Nova-Controller
  6. - Neutron 
  7. - Nova-Compute
  8. - The rest of services (cinder, swift, horizon...)
  
## ETCD: Config loader concepts

The idea is to provide a way to get all the configuration files params and environment variables to the openstack services containers.
The config-loader is a Pod launched just one time, which load all the params to the Etcd previously loaded:
   1. General Environment by changing the file [config-loader](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/general)
   2. Openstack service configuration (For instance, just change the params needed for [Glance](https://github.com/BBVA/openstack-k8s/tree/master/config-loader/data/bootstrap/glance/). If you need some params extra for configure your environment, just add the line with the param needed.
      The config-loader process will do a merge between the default config-file params and the configuration params loaded here.


* It is mandatory to define the **`AUTO_ATTACH`** variable:
  * If `AUTO_ATTACH` is set to `yes`, then all the container interfaces are attached to the VM. This is the typical use case.
  * If `AUTO_ATTACH` is set to `no`, a list of interfaces have to be declared in the `ATTACH_IFACES` variable. This is useful when launching the container with `net=host` flag, and only a subset of network interfaces need to be attached to the container.
* The VM image needs to be located in `/image/image.qcow2`
* Any additional parameter for QEMU/KVM can be specified as CMD argument when launching the container.
* When launching the VM, its serial port is accesible through `docker attach`


```
$ docker run                                            \
      --name kvm                                        \
      -td                                               \
      --privileged                                      \
      -v /path_to/image_file.qcow2:/image/image.qcow2   \
      -v /lib/modules:/lib/modules                      \
      -v /var/run:/var/run                              \
      -e AUTO_ATTACH=yes                                \
      bbvainnotech/kvm:latest
```

## Work In Progress:

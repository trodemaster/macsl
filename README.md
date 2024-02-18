# macsl
This is my repo for managing a CLI Linux instance that runs alongside macOS. Mac Services for Linux. With the transition to Applesilicon processors, the hypervisor tooling has changed a few times. Qemu, VMware Fusion, UTM and now Lima. 

Lima details https://lima-vm.io

# Install Lima
This is how I install lima
```
sudo port install lima
```

# start the lima build
From the root of this repo run this command
```
limactl create --name=macsl macsl.yaml
```

# rebuild
When iterating on a configuration, I found these steps to be helpful
```
limactl factory-reset macsl
cp ~/code/macsl/macsl.yaml ~/.lima/macsl/lima.yaml
limactl start macsl
```
# docker usage from host
You can configure the docker cli on  your macOS host system to connect directly to the docker instance inside Lima. 
```
docker context create lima-macsl --docker "host=unix:///Users/blake/.lima/macsl/sock/docker.sock"
docker context use lima-macsl
```

Another fun trick is to run an amd64 platform docker container using rosetta on linux
```
docker run --rm -ti --platform linux/amd64 ubuntu:latest
```
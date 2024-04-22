# Building and uploading the image to an SNO

```
make build-and-upload-and-load TAG=sip SERVER=192.168.18.18
```

# Deploying the environment

In order to deploy:
```
make deploy IMAGE=localhost/reproducer:sip
```

You can tear down the environment with:
```
make undeploy
```

# Traffic between pods

`green` is the sender, `blue` forwards traffic and `red` is the destination of traffic.

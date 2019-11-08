## Mongo Docker - mongodb user uid,gid mapping


**Why this was needed?**
* https://stackoverflow.com/questions/35400740/how-to-set-docker-mongo-data-volume
* When data volume is mapped to the mongodb docker container created using official mongodb docker image, it always creates the mongodb uid=999 and gid=999
* In specific case of Kali Linux: uid, gid 999 maps to user: systemd-coredump
  * `/etc/passwd` entry: `systemd-coredump:x:999:999:systemd Core Dumper:/:/sbin/nologin`

**Related Issues:**
* https://github.com/docker-library/mongo/issues/181
* https://github.com/docker-library/mongo/pull/145
* https://github.com/sameersbn/docker-mongodb/commit/0ee6ffdd46476efa6c97ce5a723e1ffc5b9cdccc


## Possible Solutions

1. Create a custom entry point
  - create mongodb user and group on host and pass the required information as enviroment varaibles
  - delete, re-create mongodb user with the new mapping
  - change directory ownership if required
2. Modify the uid, and gid inside the container
3. Create custom mongo docker image
4. **Easiest Wayout:** - modify the official mongodb docker file with the required path 


## Easiest Wayout
1. create a mongodb user and group on the host machine
2. pass the user, group, uid, gid as arguments to the official mongodb dockerfile
3. build the image by passing the values to the respective arguments


## Usage
* `source docker.buildimg.sh <docker-file-name> <docker-image-tag>`
* **Example:**
  ```bash
  source docker.buildimg.mongodb-userfix.sh Dockerfile.mongodb-userfix mongouid
  ```

## Changes to the original docker file

* Comment out the original way of creating the monogdb group and user
```
## add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# RUN groupadd -r mongodb && useradd -r -g mongodb mongodb
```
* Following is added instead:
```
## Easiest way to fix for mongodb uid and gid mapping
## In specific case of Kali Linux: uid, gid 999 maps to user: systemd-coredump
## /etc/passwd entry: systemd-coredump:x:999:999:systemd Core Dumper:/:/sbin/nologin
## Fix: create the fix using the official docker image of mongodb
## create a mongodb user and group on the host machine and pass the same uid, gid and names to the container

ARG mongodb_user
ENV MONGODB_USER $mongodb_user

ARG mongodb_user_id
ENV MONGODB_USER_ID $mongodb_user_id

ARG mongodb_grp
ENV MONGODB_GRP $mongodb_grp

ARG mongodb_grp_id
ENV MONGODB_GRP_ID $mongodb_grp_id

RUN addgroup --gid $MONGODB_GRP_ID $MONGODB_GRP
RUN useradd -r $MONGODB_USER --uid $MONGODB_USER_ID --gid $MONGODB_GRP_ID
```

**Notes:**
* Mongo user in dockerfile added as default system user uid
* Tested on Kali Linux 2019.1 (synonymous to Ubuntu 18.04 LTS - bionic)

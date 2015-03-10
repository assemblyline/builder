* pull somthing from git(hub)
* checkout the right revision
* navigate to the correct path
* build the docker image
* push it
* clean up

### JS

* Pull the code.
* run the build script
* copy the compliled dist to a new image
* push image

### Ruby

* pull the code
* docker build
* run the tests inside the new image
* push imaghe

### In general

builder - pull the code
lang    - run docker build
builder - push


keep git repos in the repo cache
do a clone from the cache & merge the correct branch
simlink node_modules and bower_compontents
do npm install and bower install
grunt build

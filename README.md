# Conway Fantasy Football API

## API built in Common Lisp using the Hunchentoot web server

Custom-built (with some help from IRC friends) :) as a proof of concept and to
be later used as a real app backend.

This repo is to show how to setup sbcl and swank in Docker off a clean phusion/baseimage

See heavily commented Dockerfile for what this repo is about

## Testing locally

Clone this repository
cd into the newly cloned folder
Build the docker image
    sudo docker build --tag conway-ff-api:1.0 .
Now run the newly built image to make your container
    sudo docker run -ti --publish 5000:5000 --publish 4005:4005  --name conway-ff-api conway-ff-api:1.0
Now you can go to http://localhost:4246 to see the server running on the docker container

## Messing around with the live server in emacs (via swank/SLIME)

In emacs run <pre><code>M-x slime-connect</code></pre> (<code><pre>spc
spc slime-connect</code></pre> in Spacemacs) to localhost and port 4005.

## Killing the server

To get rid of then running docker
sudo docker rm --force simple-sbcl.

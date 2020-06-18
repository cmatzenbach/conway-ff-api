# Conway Fantasy Football API

## API built in Common Lisp using the Hunchentoot web server

Custom-built (with some help from IRC friends :) ) as a proof of concept and to
be later used as a real app backend.

This repo is to show how to setup sbcl and swank in Docker off a clean phusion/baseimage

See heavily commented Dockerfile for what this repo is about

## Testing locally

Clone this repository

cd into the newly cloned folder

Build the docker image

    sudo docker build --tag conway-ff-api:1.0 .
	
Now run the newly built image to make your container

    sudo docker run -ti --publish 5000:5000 --publish 4005:4005  --name
	conway-ff-api conway-ff-api:1.0

Now you can go to http://localhost:4246 to see the server running on the docker container

## Messing around with the live server in emacs (via swank/SLIME)

Now HERE'S where the real fun begins!

In Emacs run <pre><code>M-x slime-connect</code></pre>
In Spacemacs run <pre><code>spc spc slime-connect</code></pre>
and bind to localhost and port 4005 when prompted for each.

Now you must ensure you are in the correct package - you should see **CL-USER>** on
the side, meaning you are in the standard Common Lisp package. If you wanted to
add a new route (or edit an existing one), in the REPL type **,** (comma) which will bring
up a new menu - type in and select *change-package*. Then type the name of the
package you want to edit (in our case, the SERVER package - the names will all
be capitalized) and you will see the REPL change to **SERVER>**. Hooray! Time to
hack away! Any code you put in there will be added to the running LISP
container, **but will not be saved after it is closed**. This is excellent for
testing and debugging, but make sure to copy over your code if you want it to remain in the source. This is just like what NASA did to a $100M piece of hardware that was 100 million miles away :)

## Killing the server

To get rid of the running docker container:
<pre><code>sudo docker rm --force simple-sbcl</code></pre>

	

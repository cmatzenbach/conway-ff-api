# Chose this ubuntu base image because its small and optimized for Docker(ness)
FROM phusion/baseimage:latest-amd64

# Installing what I need from ubuntu to do the job.
# - wget to download stuff from the web
#     -- curl gave me a 301 trying to download build app so I swiched to wget
# - sbcl and build-essentials - To build the version of sbcl downloaded
#     -- the sbcl in ubuntu is usually a bit dated that why we download what we want
# - libev-dev - is used by the woo http server that we are using for our example
#
RUN apt update &&\
    apt-get install -y sbcl wget build-essential time libev-dev rlwrap 

# Downloading, compiling and installing our prefered version of SBCL
RUN cd /tmp && \
    wget https://ufpr.dl.sourceforge.net/project/sbcl/sbcl/2.0.5/sbcl-2.0.5-source.tar.bz2 && \
    tar jxvf sbcl-2.0.5-source.tar.bz2 && \
    cd /tmp/sbcl-2.0.5 && \
    sh ./make.sh  && \
    sh ./install.sh && \
    rm -rf /tmp/sbcl*

# Install quicklisp
RUN curl -k -o /tmp/quicklisp.lisp 'https://beta.quicklisp.org/quicklisp.lisp' && \
    sbcl --noinform --non-interactive --load /tmp/quicklisp.lisp --eval \
        '(quicklisp-quickstart:install :path "~/quicklisp/")' && \
    sbcl --noinform --non-interactive --load ~/quicklisp/setup.lisp --eval \
        '(ql-util:without-prompting (ql:add-to-init-file))' && \
    echo '#+quicklisp(push "/src" ql:*local-project-directories*)' >> ~/.sbclrc && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sbcl --noinform --non-interactive --eval '(ql:quickload :swank)' 

# Make a dir for my source on the docker image
RUN mkdir /src/
# Copy project directory to new directory on docker container
COPY . /src/
#ADD ./conway-ff-api.asd /src/

# Create symlink to ~/quicklisp/local-projects for .asd file
RUN ln -s /src/conway-ff-api/conway-ff-api.asd ~/quicklisp/local-projects/conway-ff-api.asd
# Let quicklisp do its thing
RUN sbcl --noinform --non-interactive --eval '(ql:quickload :conway-ff-api)'

# Expose the port that hunchentoot is listening on
EXPOSE 5000
# Expose the port that swank is listening on
EXPOSE 4005

#  When then docker is run this is called to load our toy app.
CMD sleep 0.05; rlwrap sbcl --eval '(ql:quickload :swank)' \
  --eval "(require :swank)" \
	--eval "(setq swank::*loopback-interface* \"0.0.0.0\")" \
	--eval "(swank:create-server :port 4005 :style :spawn :dont-close t)" \
	--eval "(ql:quickload :conway-ff-api)"

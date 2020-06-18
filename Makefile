app_dir := $(dir $(CURDIR))

all: container

container: 
	sudo docker build -t conway-ff-api .

run: container
	sudo docker run -a stdin -a stdout -a stderr -i -t conway-ff-api

clean:
	sudo docker rm $(docker ps -a -q)
	sudo docker rmi $(docker images -q)

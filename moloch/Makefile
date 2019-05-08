build :
	sudo docker build -t markuskont/moloch ./
	sudo docker build -t markuskont/moloch-capture ./capture
	sudo docker build -t markuskont/moloch-viewer ./viewer
	sudo docker build -t markuskont/moloch-wise ./wise
clean :
	sudo docker system prune -f
	sudo docker image rm markuskont/moloch-capture
	sudo docker image rm markuskont/moloch-wise
	sudo docker image rm markuskont/moloch-viewer
	sudo docker image rm markuskont/moloch

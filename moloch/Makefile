build-full :
	docker build --no-cache -t markuskont/moloch:latest ./
	docker build --no-cache -t markuskont/moloch-capture:latest ./capture
	docker build --no-cache -t markuskont/moloch-viewer:latest ./viewer
	docker build --no-cache -t markuskont/moloch-wise:latest ./wise
build :
	docker build -t markuskont/moloch:latest ./
	docker build -t markuskont/moloch-capture:latest ./capture
	docker build -t markuskont/moloch-viewer:latest ./viewer
	docker build -t markuskont/moloch-wise:latest ./wise
clean :
	docker system prune -f
	docker image rm markuskont/moloch-capture:latest
	docker image rm markuskont/moloch-wise:latest
	docker image rm markuskont/moloch-viewer:latest
	docker image rm markuskont/moloch:latest

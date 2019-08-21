build-full:
	docker build --no-cache -t markuskont/suricata:latest ./
build:
	docker build -t markuskont/suricata:latest ./
clean:
	docker system prune -f
	docker image rm markuskont/suricata:latest

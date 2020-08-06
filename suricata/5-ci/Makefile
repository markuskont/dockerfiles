build-full:
	docker build --no-cache -t markuskont/suricata:5.0-ci ./
build:
	docker build -t markuskont/suricata:5.0-ci ./
clean:
	docker system prune -f
	docker image rm markuskont/suricata:5.0-ci

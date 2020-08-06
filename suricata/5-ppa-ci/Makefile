build-full:
	docker build --no-cache -t markuskont/suricata:5.0-ppa-ci ./
build:
	docker build -t markuskont/suricata:5.0-ppa-ci ./
clean:
	docker system prune -f
	docker image rm markuskont/suricata:5.0-ppa-ci

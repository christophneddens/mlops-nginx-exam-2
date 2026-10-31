start-project:
	docker compose -p mlops up -d --build

stop-project:
	docker compose -p mlops down

test: start-project
	sleep 15
	bash tests/run_tests.sh

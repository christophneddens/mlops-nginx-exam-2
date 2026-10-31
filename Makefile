start-project:
	docker compose -p mlops up -d --build

stop-project:
	docker compose -p mlops down

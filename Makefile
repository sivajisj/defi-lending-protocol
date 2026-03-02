up:
	docker compose up -d --build

down:
	docker compose down

contracts-shell:
	docker compose exec contracts bash

frontend-shell:
	docker compose exec frontend sh
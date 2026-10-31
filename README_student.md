# MLOps Exam: Advanced Deployment with Nginx

Christoph Neddens

## Architecture

```
                         +--> api-v1 (3 replicas, round robin)   default
Client --HTTPS (443)--> Nginx
                         +--> api-v2 (debug version)             header "X-Experiment-Group: debug"

Nginx /nginx_status --> nginx_exporter (9113) --> Prometheus (9090) --> Grafana (3000)
```

- **Nginx** (`nginx_revproxy`) is the single entry point (ports 80 and 443).
  - Port 80: redirects every request to HTTPS (301). Also serves `/nginx_status` for the exporter, only from the Docker network.
  - Port 443: HTTPS with a self-signed certificate (`deployments/nginx/certs/`).
  - `/predict` is protected by basic authentication (`.htpasswd`, user `admin`) and rate limited to 10 requests/second per IP (burst 5, then 503).
- **api-v1**: standard FastAPI version, 3 replicas, load balanced by the Nginx upstream `api_v1` (round robin).
- **api-v2**: debug version, also returns `prediction_proba_dict`. Nginx sends a request there only if it has the header `X-Experiment-Group: debug` (`map` in `nginx.conf`).
- **Monitoring**: `nginx_exporter` reads `/nginx_status`, Prometheus scrapes the exporter every 3 s, Grafana (admin/admin) shows the metrics.

## Usage

```bash
make start-project   # build and start all containers
make test            # start the project (if needed) and run tests/run_tests.sh
make stop-project    # stop and remove all containers
```

Example request:

```bash
curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
     --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt
```

Add `-H "X-Experiment-Group: debug"` to get the answer from api-v2.

## Files written for the exam

- `src/api/requirements.txt`, `src/api/v1/Dockerfile`, `src/api/v2/Dockerfile`
- `deployments/nginx/Dockerfile`, `deployments/nginx/nginx.conf`, `deployments/nginx/certs/`
- `docker-compose.yml`, `Makefile`

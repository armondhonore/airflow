FROM apache/airflow:2.9.0

# Single-pod `airflow standalone` (sqlite): auto-migrates the metadata DB, creates an
# admin user, and runs webserver (UI :8080) + scheduler + triggerer in one process.
# The schema has no command field, so the serve command is baked as CMD; the base
# image's dumb-init /entrypoint takes the airflow subcommand as args.
#
# Trim memory/startup footprint so the single pod does not OOM-crash-loop: 1 sync
# gunicorn worker, no example DAGs, SequentialExecutor (sqlite default).
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__EXECUTOR=SequentialExecutor \
    AIRFLOW__WEBSERVER__WORKERS=1 \
    AIRFLOW__WEBSERVER__WORKER_CLASS=sync \
    AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0 \
    AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080 \
    _AIRFLOW_WWW_USER_USERNAME=admin \
    _AIRFLOW_WWW_USER_PASSWORD=admin

EXPOSE 8080
CMD ["standalone"]

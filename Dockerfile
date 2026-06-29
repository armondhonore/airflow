FROM apache/airflow:2.9.0

# Single airflow web pod backed by a dedicated Postgres pod. Postgres makes the
# webserver's mandatory FAB permission sync fast (hundreds of writes that crash-loop
# the pod on sqlite). The base /entrypoint runs db migrate + creates the admin user
# from the _AIRFLOW_* vars (set in nexlayer.yaml), then execs the CMD (webserver).
# The schema has no command field, so CMD is baked here.
#
# Use multiple gthread workers so the UI does not return intermittent 503s when a
# single sync worker is busy / recycling.
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor \
    AIRFLOW__WEBSERVER__WORKERS=2 \
    AIRFLOW__WEBSERVER__WORKER_CLASS=gthread \
    AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0 \
    AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080 \
    AIRFLOW__WEBSERVER__WEB_SERVER_WORKER_TIMEOUT=120 \
    AIRFLOW__WEBSERVER__SECRET_KEY=nexlayer-airflow-secret

EXPOSE 8080
CMD ["webserver"]

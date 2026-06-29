FROM apache/airflow:2.9.0

# Single airflow web pod backed by a dedicated Postgres pod. Postgres makes the
# webserver's mandatory FAB permission sync fast (it is hundreds of row writes that
# crash-loop the pod when run against sqlite — the probe kills the webserver before
# it can bind :8080). The base /entrypoint runs `airflow db migrate` and creates the
# admin user when _AIRFLOW_DB_MIGRATE / _AIRFLOW_WWW_USER_CREATE are set, then execs
# the CMD (webserver). The schema has no command field, so CMD is baked here.
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor \
    AIRFLOW__WEBSERVER__WORKERS=1 \
    AIRFLOW__WEBSERVER__WORKER_CLASS=sync \
    AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0 \
    AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080 \
    AIRFLOW__WEBSERVER__SECRET_KEY=nexlayer-airflow-secret \
    _AIRFLOW_DB_MIGRATE=true \
    _AIRFLOW_WWW_USER_CREATE=true \
    _AIRFLOW_WWW_USER_USERNAME=admin \
    _AIRFLOW_WWW_USER_PASSWORD=admin

EXPOSE 8080
CMD ["webserver"]

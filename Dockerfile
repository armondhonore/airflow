FROM apache/airflow:2.9.0

# Single-pod web UI. `airflow standalone` is too heavy/slow to bind :8080 reliably in
# one pod (webserver+scheduler+triggerer), so instead we PRE-MIGRATE the sqlite
# metadata DB and create the admin user at BUILD time, then run ONLY the webserver at
# runtime — it binds :8080 quickly. The schema has no command field, so CMD is baked;
# the base dumb-init /entrypoint takes the airflow subcommand as args.
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__EXECUTOR=SequentialExecutor \
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////opt/airflow/airflow.db \
    AIRFLOW__WEBSERVER__WORKERS=1 \
    AIRFLOW__WEBSERVER__WORKER_CLASS=sync \
    AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0 \
    AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080 \
    AIRFLOW__WEBSERVER__SECRET_KEY=nexlayer-airflow-secret

# Pre-initialize the DB + admin user at build time (runs as the airflow user, who
# owns /opt/airflow), so the runtime webserver starts against a ready DB.
RUN airflow db migrate \
 && airflow users create --username admin --password admin \
      --firstname Admin --lastname User --role Admin --email admin@example.com

EXPOSE 8080
CMD ["webserver"]

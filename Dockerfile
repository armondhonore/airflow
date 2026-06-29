FROM apache/airflow:2.9.0

# Single-pod web UI. The metadata DB (sqlite) is PRE-MIGRATED and the admin user +
# FAB RBAC permissions are baked at BUILD time, then ONLY the webserver runs at
# runtime. Critically, UPDATE_FAB_PERMS is disabled so the webserver does NOT re-run
# the (very slow on sqlite) permission sync on every boot — that sync was taking long
# enough that the readiness probe killed the pod mid-init -> CrashLoopBackOff. With it
# off, gunicorn binds :8080 within seconds against the already-populated DB.
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__EXECUTOR=SequentialExecutor \
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////opt/airflow/airflow.db \
    AIRFLOW__WEBSERVER__WORKERS=1 \
    AIRFLOW__WEBSERVER__WORKER_CLASS=sync \
    AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0 \
    AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080 \
    AIRFLOW__WEBSERVER__WORKER_REFRESH_INTERVAL=600 \
    AIRFLOW__WEBSERVER__SECRET_KEY=nexlayer-airflow-secret

# Bake DB + admin user + all FAB permissions at build time (slow sqlite writes happen
# here, once), so the runtime boot is fast.
RUN airflow db migrate \
 && airflow users create --username admin --password admin \
      --firstname Admin --lastname User --role Admin --email admin@example.com \
 && airflow sync-perm || true

# Disable per-boot permission sync now that perms are baked.
ENV AIRFLOW__WEBSERVER__UPDATE_FAB_PERMS=False

EXPOSE 8080
CMD ["webserver"]

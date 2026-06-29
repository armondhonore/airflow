FROM apache/airflow:2.9.0

# `airflow standalone` initializes the metadata DB (sqlite by default), creates an
# admin user, and runs webserver (UI on :8080) + scheduler in one process — ideal
# for a single-pod deploy. The nexlayer schema has no command field, so the serve
# command is baked here. The base image's /entrypoint (under dumb-init) takes the
# airflow subcommand as CMD args, so we keep that entrypoint and only set CMD.
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False \
    _AIRFLOW_WWW_USER_USERNAME=admin \
    _AIRFLOW_WWW_USER_PASSWORD=admin

EXPOSE 8080
CMD ["standalone"]

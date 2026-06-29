# Pinned fix — airflow (#153)

Airflow webserver pod + dedicated Postgres pod. Use Postgres (NOT sqlite): the
webserver runs a mandatory FAB permission sync on every boot (hundreds of writes)
that is too slow on sqlite — the readiness probe kills the webserver before it binds
:8080 -> CrashLoopBackOff. Postgres makes the sync fast so it binds quickly.
The DB pod is named airflow-postgres (NOT "postgres") to avoid the shared-namespace
postgres.pod DNS collision; the conn string uses airflow-postgres.pod:5432.
The Dockerfile bakes CMD ["webserver"] + _AIRFLOW_DB_MIGRATE/_AIRFLOW_WWW_USER_CREATE
so the base entrypoint migrates + creates admin before serving. DO NOT switch to sqlite,
DO NOT rename the db pod to "postgres", DO NOT change ports.

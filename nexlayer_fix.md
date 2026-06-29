# Pinned fix — airflow (#153)

Single-pod deploy using `airflow standalone` (sqlite). Standalone auto-migrates the
metadata DB, creates the admin user, and runs webserver+scheduler with the UI on :8080.
The Dockerfile bakes CMD ["standalone"] because the schema has no command field.
NO separate postgres pod (sqlite is self-contained — avoids the postgres.pod shared-ns
DNS collision). DO NOT add postgres, DO NOT restore the upstream Dockerfile, DO NOT
change the port.

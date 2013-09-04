worker_processes 1
listen 83

stderr_path "/srv/sqassignments/unicorn.stderr.log"
stdout_path "/srv/sqassignments/unicorn.stdout.log"
#NOTE linea necesaria para el control con god
pid "/tmp/unicorn/sqassignments.pid"

#!/bin/sh
flask db init || true
flask db migrate -m "Initial migration." || true
flask db upgrade
exec "$@"
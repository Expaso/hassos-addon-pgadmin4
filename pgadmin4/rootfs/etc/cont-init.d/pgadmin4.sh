#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: pgAdmin4
# Configures pgAdmin4 before running (see official-pgadmin4/pkg/docker/entrypoint.sh )
# ==============================================================================


# Populate config_distro.py. This has some default config, as well as anything
# provided by the user through the PGADMIN_CONFIG_* environment variables.
# Only update the file on first launch. The empty file is created during the
# container build so it can have the required ownership.
if [ `wc -m /pgadmin4/config_distro.py | awk '{ print $1 }'` = "0" ]; then
    cat << EOF > /pgadmin4/config_distro.py
CA_FILE = '/etc/ssl/certs/ca-certificates.crt'
LOG_FILE = '/dev/null'
HELP_PATH = '../../docs'
DEFAULT_BINARY_PATHS = {
        'pg': '/usr/local/pgsql-13'
}
EOF

    # This is a bit kludgy, but necessary as the container uses BusyBox/ash as
    # it's shell and not bash which would allow a much cleaner implementation
    for var in $(env | grep PGADMIN_CONFIG_ | cut -d "=" -f 1); do
        echo ${var#PGADMIN_CONFIG_} = $(eval "echo \$$var") >> /pgadmin4/config_distro.py
    done
fi

# Ensure configuration exists
if ! bashio::fs.directory_exists '/data/pgadmin4'; then
    mkdir -p /data/pgadmin4 \
        || bashio::exit.nok "Failed to create data directory"
fi

if [ ! -f /data/pgadmin4/pgadmin4.db ]; then
    # Initialize DB before starting Gunicorn
    # Importing pgadmin4 (from this script) is enough
    cd /pgadmin4
    /venv/bin/python3 run_pgadmin.py || bashio::exit.nok "Failed to initialize Database"
fi


bashio::log.info "Patching pgAdmin to work with HA ingress.."
# Patch pgadmin-files to allow reverse proxying in desktop mode.
# This is needed to support ingress (which is on a deeper path below root)
# We want to run pfAdmin in desktop-mode (no users), because we would like to handle users and authentication ourselves.
# Problem is, in desktop mode, reverse-propxying is not respected.
# And so we patch the files to enale this behaviour again.
#sed -i '105s/config.SERVER_MODE/True/' /pgadmin4/pgadmin/__init__.py    #Line 105: Assume server-mode here to enable reverse-proxy
#sed -i '95s/config.SERVER_MODE/True/' /pgadmin4/pgAdmin4.py             #Line 94: Assume server-mode here to enable reverse-proxy
cd /pgadmin4
git apply -v /etc/pgAdmin.patch


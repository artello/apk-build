#!/bin/sh

APPNAME=$1

cat << EOF
#!/sbin/openrc-run

name=$APPNAME
description="Studio App"
extra_commands="migrate seed"
supervisor="s6"
s6_service_path="${RC_SVCDIR}/s6-scan/${name}"
command=/var/lib/$APPNAME/bin/$APPNAME

migrate() {
  source config_$APPNAME && $command migrate
}

seed() {
  source config_$APPNAME && $command seed
}

depend() {
  need net s6-svscan
}

start_pre() {
  if [ ! -L "${RC_SVCDIR}/s6-scan/${name}" ]; then
    ln -s "/var/lib/${name}/service" "${RC_SVCDIR}/s6-scan/${name}"
  fi
}
EOF
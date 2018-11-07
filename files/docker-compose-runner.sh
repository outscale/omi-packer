#!/bin/bash
# Ce script telecharge le contenu des user-data pour le mettre dans un fichier
# Si ce fichier existe $FILEPATH et que le fichier de verrou $USERDATA_LOCKFILE
# alors lancement de docker-compose
#
# Note: les redirections vers /dev/ttyS0 apparaissent dans la console-output (visible dans API et cockpit)
#
FILEPATH=/opt/osc-docker-compose-runner/docker-compose.yml
OSC_DOCKER_COMPOSER_RUNNER_DIRECTORY=/opt/osc-docker-compose-runner/
USERDATA_LOCKFILE=/opt/osc-docker-compose-runner/user-data-getted.lock
TTYSO_HEADER=--osc-docker-compose-runner

curl --silent http://169.254.169.254/1.0/user-data/ > $FILEPATH

if [ -s "$FILEPATH" ] &&  [ ! -f "$USERDATA_LOCKFILE" ];
then
	echo -e "$TTYSO_HEADER: file getted ! $FILEPATH" > /dev/ttyS0
	cd "$OSC_DOCKER_COMPOSER_RUNNER_DIRECTORY"
	echo -e "$TTYSO_HEADER: running command /usr/local/bin/docker-compose up -d >> /dev/ttyS0"
	/usr/local/bin/docker-compose up -d > /dev/ttyS0

	if [ $? -ne 0 ]; then
		echo "$TTYSO_HEADER: failed to create container" > /dev/ttyS0
	else
		echo "$TTYSO_HEADER: container created with success !" > /dev/ttyS0
		echo "$TTYSO_HEADER: lockfile $USERDATA_LOCKFILE created" > /dev/ttyS0
		touch "$USERDATA_LOCKFILE"
	fi
fi

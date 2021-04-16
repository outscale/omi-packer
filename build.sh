#!/bin/bash
set -o pipefail

# Generate OMI name and Universal OMI Name
export HOTFIX=0

if [ -z "$OVERRIDE_NAME" ]
then
	export OMI_NAME=$BASE_NAME-`/bin/date +%Y.%m.%d`
    if [ $BRANCH != "master" ]
	then
		export OMI_NAME=$AMI_NAME-$BRANCH-$GIT_COMMIT
    else
		while [ -f /usr/local/packer/images/$OUTSCALE_REGION-$OMI_NAME-$HOTFIX ] ; do HOTFIX=$((HOTFIX+1)); done;
    	export OMI_NAME=$OMI_NAME-$HOTFIX
    fi
else
	export OMI_NAME=$OVERRIDE_NAME
fi

export UOMI_NAME=$OUTSCALE_REGION-$OMI_NAME

# Generate OMI
export OUTSCALE_X509CERT='/var/lib/jenkins/cert/cert.pem'
export OUTSCALE_X509KEY='/var/lib/jenkins/cert/key.pem'
export PACKER_LOG=1
/sbin/packer build ./linux.pkr.hcl | tee /usr/local/packer/logs/$UOMI_NAME.log

export OMI_ID=`cat /usr/local/packer/logs/$OMI_NAME.log | grep ami | tail -1 | cut -d ' ' -f 2`
echo $OMI_ID> /usr/local/packer/images/$UOMI_NAME

if [ "$BRANCH" != "master" ]; then exit 0; fi

# Log handling
if [ -f /usr/local/packer/logs/$UOMI_NAME.log ]; then
	ln -fs /usr/local/packer/logs/$UOMI_NAME.log /usr/local/packer/logs/$OUTSCALE_REGION-$BASE_NAME-latest.log
    ln -fs /usr/local/packer/images/$UOMI_NAME /usr/local/packer/images/$OUTSCALE_REGION-$BASE_NAME-latest
fi

# Packages handling
if [ -f /usr/local/packer/logs/packages/$UOMI_NAME ]; then
	ln -s /usr/local/packer/logs/packages/$UOMI_NAME /usr/local/packer/logs/packages/$OMI_ID
fi

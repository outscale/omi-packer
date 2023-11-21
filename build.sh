#!/bin/bash
set -e
set -o pipefail

# Generate OMI name and Universal OMI Name
export HOTFIX=0

if [ -z "$OVERRIDE_NAME" ]
then
    export OMI_NAME=$BASE_NAME-`/bin/date +%Y.%m.%d`
    if [ $BRANCH != "master" ]; then
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
if [ "$VOL_SIZE" == 0 ] || [ -z "$VOL_SIZE" ]; then
    unset PKR_VAR_volsize
else
    export PKR_VAR_volsize=$VOL_SIZE
fi
echo "product_code: `echo $OUTSCALE_PRODUCT_CODES`"
echo "packer version `/bin/packer --version`"
echo "packer plugins: `/bin/packer plugins installed`"

/bin/packer init -upgrade ./config.pkr.hcl
/bin/packer build ./$PACKER_SCRIPT | tee /usr/local/packer/logs/$UOMI_NAME.log

# Workaround for bad Packer exit code
grep successful /usr/local/packer/logs/$UOMI_NAME.log > /dev/null

export OMI_ID=`cat /usr/local/packer/logs/$UOMI_NAME.log | grep ami | tail -1 | cut -d ' ' -f 2`
echo $OMI_ID> /usr/local/packer/images/$UOMI_NAME

if [ "$BRANCH" != "master" ]; then exit 0; fi

# Log handling
if [ -f /usr/local/packer/logs/$UOMI_NAME.log ]; then
    ln -fs /usr/local/packer/logs/$UOMI_NAME.log /usr/local/packer/logs/$OUTSCALE_REGION-$BASE_NAME-latest.log
    ln -fs /usr/local/packer/images/$UOMI_NAME /usr/local/packer/images/$OUTSCALE_REGION-$BASE_NAME-latest
fi

# Packages handling
if [ -d /usr/local/packer/logs/packages ] && [ -f ./packages-$UOMI_NAME ]; then
	mv ./packages-$UOMI_NAME /usr/local/packer/logs/packages/$UOMI_NAME
    ln -s /usr/local/packer/logs/packages/$UOMI_NAME /usr/local/packer/logs/packages/$OMI_ID
fi

#!/bin/bash

export ACCEPT_EULA=Y
export MSSQL_SA_PASSWORD=Outscale2017

curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo -o /etc/yum.repos.d/mssql-server-2017.repo
curl https://packages.microsoft.com/config/rhel/7/prod.repo -o /etc/yum.repos.d/msprod.repo

yum -y install mssql-server mssql-tools unixODBC-devel
/opt/mssql/bin/mssql-conf -n setup

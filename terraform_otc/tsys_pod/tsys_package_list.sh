#!/bin/bash

CODELIST=`cd $1;find . -type f`
COUNT=`echo $CODELIST|wc -w`

echo { \"files\": \"$CODELIST\", \"count\": \"$COUNT\" }

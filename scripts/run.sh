#!/bin/bash

./install.sh
./configure.sh
echo "=> Starting Apache ..."
rm -f /var/run/apache2/apache2.pid
exec apache2ctl -DFOREGROUND

dmesg | grep "pl2303 converter now attached" | awk '{ print $NF }' | tail -n 1

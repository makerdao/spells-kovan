
#!/usr/bin/env bash
set -e

export LP_JOIN=0xd61b8EB7f4890F25BD6016bC3FFbB8f0e08A55FF
export LP_FLIP=0x0B6C3512C8D4300d566b286FC4a554dAC217AaA6
export MCD_PAUSE_PROXY=0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3

# echo 'Relying on pause proxy...'
# seth send $LP_FLIP 'rely(address)' $MCD_PAUSE_PROXY
# seth send $LP_JOIN 'rely(address)' $MCD_PAUSE_PROXY

echo 'Checking relies'
echo FLIP:  $(seth call $LP_FLIP 'wards(address)(uint)' $MCD_PAUSE_PROXY)
echo JOIN:  $(seth call $LP_JOIN 'wards(address)(uint)' $MCD_PAUSE_PROXY)

echo 'Denying deployer address...'
seth send $LP_FLIP 'deny(address)' $ETH_FROM
seth send $LP_JOIN 'deny(address)' $ETH_FROM

echo 'Checking denies'
echo FLIP:  $(seth call $LP_FLIP 'wards(address)(uint)' $ETH_FROM)
echo JOIN:  $(seth call $LP_JOIN 'wards(address)(uint)' $ETH_FROM)

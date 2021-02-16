all    :; DAPP_STANDARD_JSON="config.json" dapp --use solc:0.6.11 build
clean  :; dapp clean
test   :; ./test-dssspell.sh
deploy :; make && dapp create DssSpell

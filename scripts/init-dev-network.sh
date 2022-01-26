#!/bin/bash
set -euxo pipefail

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cleanup() {
  cleanup_init_network_sh
  exit
}
trap cleanup INT TERM EXIT

VALIDATORS=1
IP_ADDRESSES=()
CUSTOM_IPS=false
POSITIONAL=()

NATIVE_CURRENCY="unolus"
VAL_TOKENS="1000000000""$NATIVE_CURRENCY"
VAL_STAKE="1000000""$NATIVE_CURRENCY"
CHAIN_ID="nolus-private"
OUTPUT_DIR="dev-net"
SUSPEND_ADMIN=""


while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in

  -h | --help)
    printf \
    "Usage: %s
    [--chain_id <string>]
    [-v|--validators <number>]
    [--currency <native_currency>]
    [--validator-tokens <tokens_for_val_genesis_accounts>]
    [--validator-stake <tokens_val_will_stake>]
    [-ips <ip_addrs>]
    [--suspend-admin <bech32address>]
    [-o|--output <output_dir>]" "$0"
    exit 0
    ;;

   --chain-id)
    CHAIN_ID="$2"
    shift
    shift
    ;;

   -v | --validators)
    VALIDATORS="$2"
    [ "$VALIDATORS" -gt 0 ] || {
      echo >&2 "validators must be a positive number"
      exit 1
    }
    shift
    shift
    ;;

  --currency)
    NATIVE_CURRENCY="$2"
    shift
    shift
    ;;

  --validator-tokens)
    VAL_TOKENS="$2"
    shift
    shift
    ;;

  --validator-stake)
    VAL_STAKE="$2"
    shift
    shift
    ;;

  -ips)
    for i in ${2//,/ }; do
      IP_ADDRESSES+=("$i")
    done
    CUSTOM_IPS=true
    shift
    shift
    ;;
  --suspend-admin)
    SUSPEND_ADMIN="$2"
    shift
    shift
    ;;

  -o | --output)
    OUTPUT_DIR="$2"
    shift
    shift
    ;;

  *) # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift              # past argument
    ;;

  esac
done

if [[ "$CUSTOM_IPS" = true && "${#IP_ADDRESSES[@]}" -ne "$VALIDATORS" ]]; then
  echo >&2 "non matching ip addresses"
  exit 1
fi

if [[ -z "$SUSPEND_ADMIN" ]]; then
  echo >&2 "Suspend admin was not set"
  exit 1
fi

source "$SCRIPT_DIR"/internal/config-validator-dev.sh
init_config_validator_dev_sh "$SCRIPT_DIR" "$OUTPUT_DIR"

source "$SCRIPT_DIR"/internal/init-network.sh

init_network "$OUTPUT_DIR" "$VALIDATORS" "$CHAIN_ID" "$NATIVE_CURRENCY" "$SUSPEND_ADMIN" "$VAL_TOKENS" "$VAL_STAKE"

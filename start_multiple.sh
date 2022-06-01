#!/bin/bash
NUM_INSTANCES=$1

re='^[0-9]+$'
if ! [[ $NUM_INSTANCES =~ $re ]] ; then
    NUM_INSTANCES=2
    echo "Number of instances defaults to $NUM_INSTANCES"
fi

cargo build --release
TEMP_DIR="tmp"
ROOT_DIR=$PWD
mkdir -p "$TEMP_DIR"
AVAIL_LIGHT_PEER_ID_1="12D3KooWMm1c4pzeLPGkkCJMAgFbsfQ8xmVDusg272icWsaNHWzN"
AVAIL_LIGHT_PEER_ID_2="12D3KooWRMjeT3GuYch6bQJetZyFu6zcGc9bwcTz6VJWNV6wbbvU"
AVAIL_LIGHT_PEER_ID_3="12D3KooWAER6JZP6x1oAqjLp2fhdGSC4jFzXGKTNGRj8GukPKbra"
AVAIL_LIGHT_PEER_ID_4="12D3KooWMGeD9ksCydu6sfVE8dSCKubBJ1vsNsWk8XPcidgMKTxZ"
AVAIL_LIGHT_PEER_ID_5="12D3KooWQ1RPCSFHGLCQv49qSHLAz7BwTeACsB5EJRBHCzs33Nxd"
AVAIL_LIGHT_PEER_ID_6="12D3KooWEcT1nq9TqLfdnFtXLGh2F7o9Wib1UEzY9f9hD8ah3Sma"
AVAIL_LIGHT_PEER_ID_7="12D3KooWLD2hFEicaGGJktt77Qo2t6Eu6zDMiEMUk7D5ddGWAwXR"
AVAIL_LIGHT_PEER_ID_8="12D3KooWDVfE1JJCUEXNqCdVn6M2De6n8nPhBexasXee3yUwpZ3b"
AVAIL_LIGHT_PEER_ID_9="12D3KooWQTPSSj7Ci4AotReAbV69N1nj6oDFnhRi7nNgUW9Fs9Q9"
PIDS=()
for i in $(eval echo "{1..$NUM_INSTANCES}")
do
    CURR="$TEMP_DIR/instance_$i"
    # echo "creating dir $CURR"
    mkdir -p "$CURR"
    cp target/release/avail-light $CURR
    export AVAIL_LIGHT_SERVER_PORT="$(expr 7000 + $i)"
    export AVAIL_LIGHT_IPFS_SEED="$i"
    export AVAIL_LIGHT_IPFS_PORT="$(expr 37000 + $i)"
    export AVAIL_LIGHT_APP_ID="-1"
    NEXT_INSTANCE="$( expr $i + 1 )"
    NEXT_INSTANCE_WRAPPED="$( expr  $i % $NUM_INSTANCES + 1 )"
    NEXT_PEER_ID="AVAIL_LIGHT_PEER_ID_$NEXT_INSTANCE_WRAPPED"
    export AVAIL_LIGHT_PEER_ID="${!NEXT_PEER_ID}"
    export AVAIL_LIGHT_PEER_ADDRESS="/ip4/127.0.0.1/tcp/$(expr 37000 + $NEXT_INSTANCE_WRAPPED)"
    envsubst < "config_template.yaml" > "$CURR/config.yaml"
    SELF_PEER_ID="AVAIL_LIGHT_PEER_ID_$i"
    echo "Running instance $i, rpc port: $AVAIL_LIGHT_SERVER_PORT, ipfs port: $AVAIL_LIGHT_IPFS_PORT, peer_id: ${!SELF_PEER_ID}"
    cd $CURR
    COLOR='\\033[0;31m'
    END_COLOR='\\033[0m' # No Color
    bash -c "script -q -c ./avail-light avail-light.log | sed -e 's/^/Instance_$i: /'" &
    PIDS+=($!)
    cd $ROOT_DIR

done

echo "Running!"
for pid in "${PIDS[@]}"
do
    echo "Instance PID=$pid"
done

trap_ctrlc()
{
        for pid in "${PIDS[@]}"
        do
            echo "Killing $pid"
            kill -9 $pid
        done
        exit
}

trap trap_ctrlc SIGHUP SIGINT SIGTERM
echo "Press [CTRL+C] to stop.."
while :
do
	sleep 1
done


#! /bin/sh

ARBITER_HOST = "tcp://arbiter:4444"
ARBITER_PATH = "/store/secret"
ARBITER_SECRET_FILE = "/run/secrets/ARBITER_TOKEN"
STORE_SECRET_KEY_FILE = "/run/secrets/ZMQ_SECRET_KEY"
ARBITER_PUBLIC_KEY_FILE = "/run/secrets/ZMQ_PUBLIC_KEY"
TOKEN_KEY_FILE = "/tmp/TOKEN_KEY"
ZEST_CLIENT_BINARY = "/app/zest/client.exe"
ZEST_SERVER_BINARY = "/app/zest/server.exe"
ZEST_IMAGE = "jptmoore/zest:v0.0.8"
IDENTITY = $DATABOX_LOCAL_NAME
STORE_DIR = "/database/"
STORE_REQ_PORTS = "5555:5555"
STORE_ROUT_PORTS = "5556:5556"

echo "Get arbiter key"
ARBITER_PUBLIC_KEY=$(cat ${ARBITER_PUBLIC_KEY_FILE}|tr -d '\r\n')

echo "Get arbiter secret"
SECRET=$(cat ${ARBITER_SECRET_FILE}|tr -d '\r\n')
echo "SECRET="$SECRET

echo "Get the store token"
TOKEN=$(docker run --network host -it ${ZEST_IMAGE} ${ZEST_CLIENT_BINARY} --server-key ${ARBITER_PUBLIC_KEY} --request-endpoint ${ARBITER_HOST} --path ${ARBITER_PATH} --mode get --identity ${IDENTITY} --token ${SECRET})
# strip the token of CR and NL
TOKEN=$(echo $TOKEN|tr -d '\r\n')
echo "TOKEN="$TOKEN
# write token to file
echo -n $TOKEN > $TOKEN_KEY_FILE

echo "Starting store"
docker run -p ${STORE_REQ_PORTS} -p ${STORE_ROUT_PORTS} -d --name zest -v ${TOKEN_KEY_FILE}:${TOKEN_KEY_FILE} --rm ${ZEST_IMAGE} ${ZEST_SERVER_BINARY} --secret-key-file ${STORE_SECRET_KEY_FILE} --token-key-file ${TOKEN_KEY_FILE} --identity ${IDENTITY} --store-dir ${STORE_DIR}

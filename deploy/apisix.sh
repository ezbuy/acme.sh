#!/usr/bin/env sh

# The Script to deploy cert into apisix
# Written by developers from ezbuy

apisix_deploy() {
  _cdomain="$1"
  _ckey="$2"
  _ccert="$3"
  _cca="$4"
  _cfullchain="$5"
  _info "Deploying cert to apisix"
  if [ -z "$APISIX_HOST" ]; then
    _debug "APISIX_HOST not set ,using default: http://localhost:9080"
    APISIX_HOST="http://localhost:9080"
  fi

  _debug _cdomain "$_cdomain"
  _debug _ckey "$_ckey"
  _debug _ccert "$_ccert"
  _debug _cca "$_cca"
  _debug _cfullchain "$_cfullchain"

  if [ -z "$APISIX_KEY" ]; then
	_err "APISIX_KEY not set"
	return 1
  fi
  cert_data=$(cat "$_ccert" | sed 's/\//\\\//g')
  key_data=$(cat "$_ckey" | sed 's/\//\\\//g')
  _debug cert_data
  _debug key_data
  body='{"cert": "'$cert_data'", "key": "'$key_data'", "sni": ["'$_cdomain'"]}'

  export _H1="X-API-Key: $APISIX_KEY"
  id_digest="$APISIX_SSL_ID"
  if [ -z "$APISIX_SSL_ID" ];then
  id_digest=$(echo $_cdomain | _base64)
  fi
  _debug body "$body"
  response=$(_post "$body" "$APISIX_HOST/apisix/admin/ssl/$id_digest" 0 PUT)
  if ! _contains "$response" "\"status_code\": 200" >/dev/null; then
    _err "Post crete ssl failed: $response"
    return 1
  fi

  _info "Deploy cert to apisix success"
}

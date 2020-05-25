# Guide: Storing secrets in Barbican

## GitHub Docker Registry

1. Ensure you have a [GitHub personal access token][gh-token] with permissions
   to pull images from the GitHub Docker registry and store it in a file like
   `~/TOKEN.txt`

2. Generate the secret. Ensure the second param after secret
   (docker.pkg.github.com) is in the name under `imagePullSecret` of the
   appropriate kubernetes yaml file.

       SECRET=$(kubectl --dry-run=true create secret \
                                       docker-registry \
                                       docker.pkg.github.com \
                        --docker-server=docker.pkg.github.com \
                        --docker-username="Your_Github_Username" \
                        --docker-password="$(cat ~/TOKEN.txt)" \
                         -o json \
                | jq -r '.data[".dockerconfigjson"]' \
                | base64 --decode)

3. Store the secret in OpenStack Barbican

       openstack secret store \
                 --name="docker.pkg.github.com" \
                 --payload-content-type="text/plain" \
                 --payload="$SECRET"

## OpenStack Cinder Application Credential

1. Ensure you have sourced your OpenStack credentials.

2. Create an application credential

       source <(openstack application credential create \
                          cloud-config \
                          -f shell -c id -c secret)

3. Store the secret in OpenStack Barbican

       openstack secret store \
                 --name="cloud-config" \
                 --payload-content-type="text/plain" \
                 --payload="$(cat <<EOF
       [Global]
       auth-url=${OS_AUTH_URL}
       application-credential-id=${id}
       application-credential-secret=${secret}
       region=${OS_REGION_NAME}
       EOF
       )"

## AURIN API Access Token

1. Apply for the API credentials through the [website](https://aurin.org.au/resources/aurin-apis/sign-up/)

2. After receiving the token {TOKEN}, store it with the following command:

        openstack secret store \
                --name="aurin-token" \
                --payload-content-type="text/plain" \
                --payload="{TOKEN}"

## Twitter Access Tokens & Secrets

1. We require 4 [Twitter tokens](https://developer.twitter.com/en/docs/basics/authentication/oauth-1-0a) which are stored as secrets; the `oauth_consumer_key`, `oauth_consumer_secret`, `oauth_token`, and the `oauth_token_secret`.

2. Once the tokens have been generated, store them with the following commands:

        openstack secret store \
                    --name="consumer-token" \
                    --payload-content-type="text/plain" \
                    --payload="{OAUTH_CONSUMER_KEY}"`

        openstack secret store \
                    --name="consumer-secret" \
                    --payload-content-type="text/plain" \
                    --payload="{OAUTH_CONSUMER_SECRET}"

        openstack secret store \
                    --name="access-token" \
                    --payload-content-type="text/plain" \
                    --payload="{OAUTH_TOKEN}"

        openstack secret store \
                    --name="access-secret" \
                    --payload-content-type="text/plain" \
                    --payload="{OAUTH_TOKEN_SECRET}"`

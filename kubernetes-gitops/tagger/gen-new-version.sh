#!/bin/bash

OLD_VER="v0.0.11"
NEW_VER="v0.0.12"

docker login -u pa3mep docker.io
docker image pull pa3mep/adservice:$OLD_VER
docker image pull pa3mep/cartservice:$OLD_VER
docker image pull pa3mep/checkoutservice:$OLD_VER
docker image pull pa3mep/currencyservice:$OLD_VER
docker image pull pa3mep/emailservice:$OLD_VER
docker image pull pa3mep/frontend:$OLD_VER
docker image pull pa3mep/loadgenerator:$OLD_VER
docker image pull pa3mep/paymentservice:$OLD_VER
docker image pull pa3mep/productcatalogservice:$OLD_VER
docker image pull pa3mep/recommendationservice:$OLD_VER
docker image pull pa3mep/shippingservice:$OLD_VER

docker image tag pa3mep/adservice:$OLD_VER pa3mep/adservice:$NEW_VER
docker image tag pa3mep/cartservice:$OLD_VER pa3mep/cartservice:$NEW_VER
docker image tag pa3mep/checkoutservice:$OLD_VER pa3mep/checkoutservice:$NEW_VER
docker image tag pa3mep/currencyservice:$OLD_VER pa3mep/currencyservice:$NEW_VER
docker image tag pa3mep/emailservice:$OLD_VER pa3mep/emailservice:$NEW_VER
docker image tag pa3mep/frontend:$OLD_VER pa3mep/frontend:$NEW_VER
docker image tag pa3mep/loadgenerator:$OLD_VER pa3mep/loadgenerator:$NEW_VER
docker image tag pa3mep/paymentservice:$OLD_VER pa3mep/paymentservice:$NEW_VER
docker image tag pa3mep/productcatalogservice:$OLD_VER pa3mep/productcatalogservice:$NEW_VER
docker image tag pa3mep/recommendationservice:$OLD_VER pa3mep/recommendationservice:$NEW_VER
docker image tag pa3mep/shippingservice:$OLD_VER pa3mep/shippingservice:$NEW_VER

docker image push pa3mep/adservice:$NEW_VER
docker image push pa3mep/cartservice:$NEW_VER
docker image push pa3mep/checkoutservice:$NEW_VER
docker image push pa3mep/currencyservice:$NEW_VER
docker image push pa3mep/emailservice:$NEW_VER
docker image push pa3mep/frontend:$NEW_VER
docker image push pa3mep/loadgenerator:$NEW_VER
docker image push pa3mep/paymentservice:$NEW_VER
docker image push pa3mep/productcatalogservice:$NEW_VER
docker image push pa3mep/recommendationservice:$NEW_VER
docker image push pa3mep/shippingservice:$NEW_VER
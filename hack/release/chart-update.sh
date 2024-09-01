#!/bin/bash
set -ex

# github tag e.g v1.2.3
GITHUB_TAG=${GITHUB_TAG:-}
# github repo owner e.g mellanox
GITHUB_REPO_OWNER=${GITHUB_REPO_OWNER:-}

BASE=${PWD}
YQ_CMD="${BASE}/bin/yq"
HELM_VALUES=${BASE}/deployment/maintenance-opeator-chart/values.yaml
HELM_CHART=${BASE}/deployment/maintenance-opeator-chart/Chart.yaml


if [ -z "$GITHUB_TAG" ]; then
    echo "ERROR: GITHUB_TAG must be provided as env var"
    exit 1
fi

if [ -z "$GITHUB_REPO_OWNER" ]; then
    echo "ERROR: GITHUB_REPO_OWNER must be provided as env var"
    exit 1
fi

# tag provided via env var
OPERATOR_TAG=${GITHUB_TAG}

# patch values.yaml in-place

# maintenance-operator image:
OPERATOR_REPO=${GITHUB_REPO_OWNER} # this is used to allow to release maintenance-operator from forks
$YQ_CMD -i ".operator.image.repository = \"ghcr.io/${OPERATOR_REPO}/maintenance-operator\"" ${HELM_VALUES}
$YQ_CMD -i ".operator.image.tag = \"${OPERATOR_TAG}\"" ${HELM_VALUES}

# patch Chart.yaml in-place
$YQ_CMD -i ".version = \"${OPERATOR_TAG#"v"}\"" ${HELM_CHART}
$YQ_CMD -i ".appVersion = \"${OPERATOR_TAG}\"" ${HELM_CHART}

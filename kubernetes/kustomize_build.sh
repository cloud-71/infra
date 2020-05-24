#!/usr/bin/env bash
set -euo pipefail

kubernetes_dir=$(dirname "$(readlink -f "$0")")
export KUSTOMIZE_PLUGIN_HOME="$kubernetes_dir/kustomize_plugins"
exec kustomize build --enable_alpha_plugins "$@"

#!/usr/bin/env bash
set -euo pipefail

kubernetes_dir="$(cd "$(dirname "$0")" && pwd)"
export KUSTOMIZE_PLUGIN_HOME="$kubernetes_dir/kustomize_plugins"
exec kustomize build --enable_alpha_plugins "$@"

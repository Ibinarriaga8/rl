#!/usr/bin/env bash

set -e

# Note: This script is sourced by run_all.sh, so the environment is already active

apt-get update && apt-get remove swig -y && apt-get install -y git gcc patchelf libosmesa6-dev libgl1-mesa-glx libglfw3 swig3.0 cmake
ln -s /usr/bin/swig3.0 /usr/bin/swig

export PYTORCH_TEST_WITH_SLOW='1'
export LAZY_LEGACY_OP=False
python -m torch.utils.collect_env
# Avoid error: "fatal: unsafe repository"
git config --global --add safe.directory '*'

root_dir="$(git rev-parse --show-toplevel)"
env_dir="${root_dir}/env"
lib_dir="${env_dir}/lib"

# this workflow only tests the libs
python -c "import minari"

python .github/unittest/helpers/coverage_run_parallel.py -m pytest test/test_libs.py --instafail -v --durations 200 --capture no -k TestMinari --error-for-skips --runslow
coverage combine
coverage xml -i

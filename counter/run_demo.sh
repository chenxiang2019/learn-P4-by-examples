#!/bin/bash

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/../../env.sh

CLI_PATH=$BMV2_PATH/targets/simple_switch/sswitch_CLI

echo "resetting counters"
echo "counter_reset my_indirect_counter" | $CLI_PATH counter.json
echo "counter_reset my_direct_counter" | $CLI_PATH counter.json
echo
echo
echo
echo "displaying counters [0]"
echo "counter_read my_indirect_counter 0" | $CLI_PATH counter.json
echo "counter_read my_direct_counter 0" | $CLI_PATH counter.json
echo
echo
echo
echo "sending 1 packet of size 70"
sudo python send_one.py
sleep 1
echo
echo
echo
echo "displaying counters [0]"
echo "counter_read my_indirect_counter 0" | $CLI_PATH counter.json
echo "counter_read my_direct_counter 0" | $CLI_PATH counter.json
echo
echo
echo
echo "sending 3 packets of size 70"
sudo python send_one.py
sudo python send_one.py
sudo python send_one.py
sleep 1
echo
echo
echo
echo "displaying counters [0]"
echo "counter_read my_indirect_counter 0" | $CLI_PATH counter.json
echo "counter_read my_direct_counter 0" | $CLI_PATH counter.json
echo
echo
echo
echo "resetting counters"
echo "counter_reset my_indirect_counter" | $CLI_PATH counter.json
echo "counter_reset my_direct_counter" | $CLI_PATH counter.json

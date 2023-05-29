#!/bin/bash

./chaper1-netns.bash
sudo ip netns exec router1 /bin/server --mode ch1

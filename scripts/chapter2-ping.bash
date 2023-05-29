#!/bin/bash

sudo ip netns exec host1 arping -I host1-router1 192.168.1.1

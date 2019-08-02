#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import sys

if (len(sys.argv) < 3):
    print("Usage: %s <file to get full path>".format(sys.argv[0]))


for path in sys.argv[1:]:
    if os.path.isfile(path):
        print(os.path.realpath(path))

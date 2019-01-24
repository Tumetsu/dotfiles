#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import os
import sys
try:
    import readline
except ImportError:
    print("Unable to load readline module.")
else:
    import rlcompleter
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

sys.path.append(os.path.expanduser("~/bin"))
from mylib import *

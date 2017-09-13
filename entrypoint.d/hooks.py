#!/usr/bin/env python
import json
import os
import sys
import shlex
import subprocess

__author__ = "Misiu Pajor <misiu.pajor@op5.com>"

HOOKS_FILE = "/usr/libexec/entrypoint.d/hooks.json"

def _load_hooks(type=None):
    try:
        with open(os.path.join(HOOKS_FILE)) as fd:
            json_data = json.load(fd)
            return json_data[type]
    except IOError as e:
        sys.exit("Failed to load {0}. Error: {1}".format(HOOKS_FILE, e))

def trigger_hook(type=None):
        hooks = _load_hooks(type)
        for hook in hooks:
                cmd = hook["path"]
                for arg in hook["args"]:
                        cmd += " " + arg
                cmd = shlex.split(str(cmd))
                print "Running {0} hook: {1}".format(type, cmd)
                try:
                        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        stdout, stderror = p.communicate()
                        if p.returncode != 0:
                                sys.exit("Hook {0} failed. Error: {1} {2}".format(hook["path"], stderror, stdout))
                except (OSError, IOError) as e:
                        sys.exit("Hook {0} failed. Error: {1}".format(hook["path"], e))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        available_types = ["start", "stop"]
        if sys.argv[1] in available_types:
            trigger_hook(sys.argv[1])
        else:
            print "`{0}` is not an valid argument. try: {1}".format(sys.argv[1], tuple(available_types))

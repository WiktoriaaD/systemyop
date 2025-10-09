#!/usr/bin/env python3

import os
import pwd

def list_processes():
    path_proc = "/proc"
    for item in os.listdir(path_proc):
        if item.isdigit():
            pid = item
            proc_path = os.path.join(path_proc, pid)
            uid = os.stat(proc_path).st_uid
            user = pwd.getpwuid(uid).pw_name

            with open(os.path.join(proc_path, 'comm'), 'r') as f:
                    command = f.read().strip()
            print(f"{user:<10} {pid:<10} {command}")


if __name__ == "__main__":
    list_processes()
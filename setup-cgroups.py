import subprocess

# create groups of 12, 16, ..., 32GB memory
names = [7, 8, 9, 10, 11, 12]
mbs = [int(8 + (x * 4)) for x in names]

for item in names:
    subprocess.run("sudo cgcreate -g memory:{}".format(item), shell=True)

subprocess.run("sudo chown -R shawgerj /sys/fs/cgroup/memory", shell=True)

for name, mb in zip(names, mbs):
    subprocess.run("echo {}m > /sys/fs/cgroup/memory/{}/memory.limit_in_bytes".format(mb, name), shell=True)

subprocess.run("sudo swapoff -a", shell=True)
subprocess.run("echo off | sudo tee /sys/devices/system/cpu/smt/control", shell=True)

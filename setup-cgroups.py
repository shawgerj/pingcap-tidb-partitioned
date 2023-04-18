import subprocess

# in GB
names = [24, 32, 40]
mbs = [int(1024 * x) for x in names]

for item in names:
    subprocess.run("sudo cgcreate -g memory:{}".format(item), shell=True)

subprocess.run("sudo chown -R shawgerj /sys/fs/cgroup/memory", shell=True)

for name, mb in zip(names, mbs):
    subprocess.run("echo {}m > /sys/fs/cgroup/memory/{}/memory.limit_in_bytes".format(mb, name), shell=True)

subprocess.run("sudo swapoff -a", shell=True)
subprocess.run("echo off | sudo tee /sys/devices/system/cpu/smt/control", shell=True)

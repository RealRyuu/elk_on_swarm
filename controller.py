import subprocess
import requests
from requests.auth import HTTPBasicAuth
import statistics
import time
import sys
import os

N_WORKERS = 4
N_ELASTIC = 1
N_LOGSTASH_A = 1
N_LOGSTASH_B = 1
DISK_USAGE_THRESHOLD = 11

def should_scale_elastic():
    url = 'http://192.168.99.100:9200/_cat/allocation?format=json'
    res = requests.get(url, verify=False, auth=HTTPBasicAuth('elastic', 'changeme'))
    data = res.json()
    disk_usages = []
    for json in data:
        if json['node'] == "UNASSIGNED":
            continue
        disk_usages.append(float(json['disk.indices'].rstrip("kb").rstrip("mb").rstrip("gb")))
    average_disk_usage = statistics.mean(disk_usages)
    if average_disk_usage > DISK_USAGE_THRESHOLD:
        print("Average disk usage: " + str(average_disk_usage))
        print("Scalling up elastic...")
        return True
    
    return False

def should_scale_logstash_A():
    return False

def should_scale_logstash_B():
    return False

def scale_up_elastic():
    global N_ELASTIC
    global N_WORKERS
    N_ELASTIC += 1
    N_WORKERS += 1
    subprocess.call("./scale_up_elastic.sh " + str(N_WORKERS) + " " + str(N_ELASTIC), shell=True)

def scale_up_logstash_A():
    global N_LOGSTASH_A
    global N_WORKERS
    N_LOGSTASH_A += 1
    N_WORKERS += 1
    subprocess.call("./scale_up_logstash_A.sh " + str(N_WORKERS) + " " + str(N_LOGSTASH_A), shell=True)

def scale_up_logstash_B():
    global N_LOGSTASH_B
    global N_WORKERS
    N_LOGSTASH_B += 1
    N_WORKERS += 1
    subprocess.call("./scale_up_logstash_B.sh " + str(N_WORKERS) + " " + str(N_LOGSTASH_B), shell=True)

def should_scale_down_logstash_A():
    return False
    
def should_scale_down_logstash_B():
    return False

def scale_down(service, current):
    subprocess.call("./scale_down_service.sh " + service + "=" + str(current-1), shell=True)

while True:
    time.sleep(1)
    print("0-nothing")
    print("1-scale elastic")
    print("2-scale logstahA")
    print("3-scale logstahB")
    print("4-scale down logA")
    print("5-scale down logB")
    what = int(input(""))
    if what==1:
        scale_up_elastic()
    if what==2:
        scale_up_logstash_A()
    if what==3:
        scale_up_logstash_B()
    if what==4:
        scale_down("elastic_logstashA", N_LOGSTASH_A)
        N_LOGSTASH_A -= 1
    if what==5:
        scale_down("elastic_logstashB", N_LOGSTASH_B)
        N_LOGSTASH_B -= 1

# coding=utf-8
'''
check server certificate
try to verify servers ssl certificate with a base server

read config from my.conf, data format as follow:
  debug=0
  baseserv=192.168.0.1
  checkservs=192.168.0.2, 192.168.0.3
  alarmmail=alarm@example.com

vserion 0.9
'''

import commands
from multiprocessing import Pool
import os
import re
import logging
logging.basicConfig(level=logging.INFO)

names = locals()
# read config
with open("./my.conf", "r") as f:
    for line in f.readlines():
        if line[:1] == '#':
            continue
        line = line.strip('\n')
        k,v = line.split("=")
        names[k]=v

debug = names['debug']

# read serverlist
baseserv = names['basesev']
servs = names['checkservs'].split(", ")

anchor = "SSL-Session"
pattern = re.compile(r'CONNECTED\(00000003\)\n|CONNECTED\(00000004\)\n')

logging.info("start...")
# openssl s_client -connect servername:443
cmd = "openssl s_client -connect " + baseserv + ":443"
(status, baseoutput) = commands.getstatusoutput(cmd)
idx = baseoutput.find(anchor)
baseoutput = baseoutput[:idx]
baseoutput = pattern.sub('', baseoutput)

def check_serv_status(serv):
    cmd = "openssl s_client -connect "+serv+":443"
    (status, output) = commands.getstatusoutput(cmd)
    idx = output.find(anchor)
    output = output[:idx]
    output = pattern.sub('', output)
    if(status>0):
        logging.info("server %s error, code: %s" % (serv, status))
    else:
        # compare with base sample
        diff = cmp(baseoutput, output)
        if(diff!=0):
            logging.info("different between %s and %s" % (serv, baseserv))

            if debug=='1':
                print "++++++++++ " + baseserv + " ++++++++++"
                print baseoutput
                print "---------- " + serv + " ----------"
                print output
        else:
            logging.info("server %s verified" % serv)


if(status>0):
    print "check base error, code:", status
    print "error msg:", baseoutput
else:
    p = Pool(len(servs))
    for serv in servs:
        p.apply_async(check_serv_status, args=(serv, ))
    p.close()
    p.join()
    logging.info("all servers checked")


# report report
# TODO sendmail

#!/usr/bin/python
# z 
import subprocess  
import hashlib
import difflib
import time,re

omd5sum=oout="";
regexp=re.compile("^\+|\-")
def readauditoutput():
 proc=subprocess.Popen(['cat /var/log/audit/audit.log'],stdout=subprocess.PIPE,shell=True)
 (out,err)=proc.communicate()
 return out 
def readlsof () :
 proc=subprocess.Popen(['lsof -i -n | grep -iv "listen" | sed -ne \'2,$p\''],stdout=subprocess.PIPE,shell=True)
 (out,err)=proc.communicate()
 return out 
def returnDigest(str):
 return hashlib.md5(str).hexdigest()

out=readlsof()
md5sum=returnDigest(out)

while True: 
 oout=readlsof()
 omd5sum=returnDigest(oout)
 if md5sum!=omd5sum:
  # find the diff
  ret=difflib.ndiff(out.splitlines(1),oout.splitlines(1))
  clock=time.ctime()
  print"<diff>"
  for i in ret:
   res=regexp.match(i)
   if(res):
    print " ",clock," ",i.rstrip()
  print"</diff>"
  md5sum=omd5sum
  out=oout
  time.sleep(1)





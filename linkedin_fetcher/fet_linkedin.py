#!/usr/bin/env python
import sys
import requests
from BeautifulSoup import BeautifulSoup
import urllib

fpic=urllib.URLopener()
file=open("lkin_super.txt");
for line in file:
    try:
        line=line.split("$")
        assert(len(line)==2)
        ntag = line[0]
        addr = line[1]
        if addr.find("http://") == -1:
            response = requests.get("http://"+addr.strip())
        else:
            response = requests.get(addr.strip())
        soup = BeautifulSoup(response.text)
        mydivs = soup.findAll("div", { "class" : "summary" })
        print "Fetching "+ntag
        f=open("summary_"+ntag+".lkd","w");
        f.write("#SOE FOR "+ntag+"\n")
        f.write(str(mydivs))
        f.write("#EOE\n")
        f.close()
    except Exception:
        print "failed to catch " + ntag
        continue

    soup_pic = BeautifulSoup(str(soup.findAll("div", { "class" : "profile-picture"})))
    pic_url  = str(soup_pic.find(name="img"))

    tofetch = pic_url.split("\"")

    if tofetch[0] !="None":
        tofetch=str(tofetch[1])
        tofetch.replace("200","400")
        fname = "pic_"+ntag+".jpg"
        fpic.retrieve(tofetch,fname)
file.close()



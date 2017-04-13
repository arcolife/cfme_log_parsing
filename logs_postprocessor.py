#!/bin/env python

import sys
from datetime import datetime

d = open('/tmp/temp.out').read()

start_time=sys.argv[1]
# 2017-03-10T10:45
end_time=sys.argv[2]
# 2017-03-10T11:45

# import pdb; pdb.set_trace()
#  datetime.strptime(i[0], "%Y-%m-%dT%H:%M:%S.%f")
for i in d.split('time: ')[1:]:
    i = i.splitlines()
    tmp = i[0].split('.')[0][:-3]
    print(i[0])
    if tmp >= start_time and tmp <= end_time:
            print(i[0], i[1])

#! /usr/bin/env python

f = open('trace.log')

level = -1
indent = '    '

s = ''

for line in f.readlines():
    e = line[0] == 'E'
    if e: level += 1
    s += indent * level + line
    if not e: level -= 1

print s

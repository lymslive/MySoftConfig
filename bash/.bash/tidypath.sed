#! /bin/sed -rf
#
# tidy dot-path, such as
# /a/b/c/./d/e/f; /a/b/c/../d/e/f; /a/b/c/../../d/e/f; 
# /a/b/c/../../d/../e/./f;
# are full absolute path in no doubt, but unreadable.
# this sed convert the equivalent path without mid-dot paths

s@/\./@/@g
:DO
s@/[^/]+/\.\./@/@
t DO

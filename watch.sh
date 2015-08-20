#!/bin/bash -x

p1=0
p2=0

trap 'kill $p1 $p2; echo; exit' SIGINT SIGTERM

sass -w slideshow.sass:slideshow.css &
p1=$!

coffee -wc slideshow.coffee &
p2=$!

wait $p1 $p2


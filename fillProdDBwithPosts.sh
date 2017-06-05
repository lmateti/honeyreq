#!/bin/bash

for x in {0..900..1}; 
do mysql -h"10.0.0.1" -uroot -p"mysecpas" wordpress < ./naredba; 
done

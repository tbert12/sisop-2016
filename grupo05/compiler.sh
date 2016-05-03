#!/bin/bash

arch_comprimido=source.tar.gz


mkdir source/

cp -ar data/MAEDIR source/
cp -ar data/ARRIDIR source/
mkdir source/BINDIR
cp -a *{.pl,.sh} source/BINDIR
tar -czf $arch_comprimido source/

mkdir CIPAK_G5/

mv $arch_comprimido CIPAK_G5/
cp -ar Documentacion/ CIPAK_G5/ 2> /dev/null
cp -ar doc/ CIPAK_G5/ 2> /dev/null
cp -a installer.sh CIPAK_G5/
cp -a Readme.md CIPAK_G5/

tar -czf CIPAK_G5.tgz CIPAK_G5/

rm -rf source/
rm -rf CIPAK_G5/

exit

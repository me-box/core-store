#! /bin/sh

# compile code
echo "compiling..."
eval `opam config env`
cd src && jbuilder build main.exe
cp ./_build/default/main.exe ../
echo "done compiling"
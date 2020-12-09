#!/bin/bash

# * find a file in the current directory called pXX.input.txt for some digits XX
input_file=$(ls | grep "^p..\.input\.txt$")
prefix=$(echo ${input_file} | cut -d. -f1)

if [[ -z ${prefix} ]]; then
    echo "ERROR: didn't find an input file like pXX.input.txt"
    exit 1
fi

if [[ -e ${prefix}.rb ]]; then
    echo "ERROR: ${prefix}.rb already exists, aborting creation"
    exit 2
fi
echo "input_file: ${input_file}"
echo "prefix: ${prefix}"

echo "creating ${prefix}.rb ..."
cat ../lib/template.rb ${prefix}.input.txt > ${prefix}.rb
chmod a+x ${prefix}.rb
year=$(basename `pwd`)
branchname="${year}_${prefix}"
echo "creating new branch: ${branchname}"
git checkout -b ${branchname} || exit 3
rm ${input_file}
git add ${prefix}.rb
git commit -m "${year} ${prefix} - empty file and input"

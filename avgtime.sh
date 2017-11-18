#!/bin/bash
OPTS=`getopt -o i:o: --long in:,out: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

infile=""
outfile=""

while true; do
  case "$1" in
    -i | --in ) infile="$2"; shift; shift ;;
    -o | --out ) outfile="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ $infile == "" ]]; then
    infile=/dev/null; # No input file specified, read from null
fi

if [[ $outfile == "" ]]; then
    outfile=/dev/stdout; # No output file specified, output to stdout
fi

tempf=$(mktemp "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
for x in {1..5}
do
     /usr/bin/time -f "%U" -a -o $tempf $@ < $infile > $outfile
done
awk '{ usertime += $1; count++ } END {  printf("Average User Time: %.3f seconds\n", usertime/count) }' $tempf >&2
rm -f $tempf

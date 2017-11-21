#!/bin/bash
OPTS=`getopt -o hi:o:n: --long help,in:,out:,number: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

infile=""
outfile=""
number=3

show_help () {
    echo "AvgTime"
    echo "-------"
    echo "Usage: avgtime.sh [-i <input file>] [-o <output file>] [-n <number of runs>] <command to time>"
    echo "Flag | Long Name | Description"
    echo " -h  | --help    | Show help message"
    echo " -i  | --input   | Filename piped to command with < on each run"
    echo " -o  | --output  | Filename to write output to with > on each run"
    echo " -n  | --number  | Number of runs to average times across, default: 3"
    exit 0
}

while true; do
  case "$1" in
    -h | --help ) show_help; shift; shift ;;
    -i | --in ) infile="$2"; shift; shift ;;
    -o | --out ) outfile="$2"; shift; shift ;;
    -n | --number ) number=$2; shift; shift ;;
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
for x in $(seq 1 $number)
do
    /usr/bin/time -f "%U" -a -o $tempf $@ < $infile > $outfile
done
awk '{ usertime += $1; count++ } END {  printf("Average User Time: %.3f seconds\n", usertime/count) }' $tempf >&2
rm -f $tempf

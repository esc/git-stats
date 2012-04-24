#!/bin/bash
LOGOPTS=
END_AND_BEGIN=
#argument parsing
while [ -n "$1" ]; do
    if [[ "$1" == "-s" ]]; then
        shift
        END_AND_BEGIN=$(echo $END_AND_BEGIN --after=$1)
    fi
    if [[ "$1" == "-e" ]]; then
        shift
        END_AND_BEGIN=$(echo $END_AND_BEGIN --before=$1)
    fi
    if [[ "$1" == '-w' ]]; then
        LOGOPTS="$LOGOPTS -w"
    fi
    if [[ "$1" == '-C' ]]; then
        LOGOPTS="$LOGOPTS -C --find-copies-harder"
    fi
    if [[ "$1" == '-M' ]]; then
        LOGOPTS="$LOGOPTS -M"
    fi
    shift
done

#test if the directory is a git
git branch &> /dev/null || exit 3
echo "Number of commits per author:"
git --no-pager shortlog $END_AND_BEGIN  -sn --all
AUTHORS=$( git shortlog $END_AND_BEGIN  -sn --all | cut -f2 | cut -f1 -d' ')

for a in $AUTHORS
do
    echo '-------------------'
    echo "Statistics for: $a"
    echo -n "Number of files changed: "
    git log $LOGOPTS $END_AND_BEGIN --all --numstat --format="%n" --author=$a | cut -f3 | sort -iu | wc -l
    echo -n "Number of lines added: "
    git log $LOGOPTS $END_AND_BEGIN --all --numstat --format="%n" --author=$a | cut -f1 | awk '{s+=$1} END {print s}'
    echo -n "Number of lines deleted: "
    git log $LOGOPTS $END_AND_BEGIN --all --numstat --format="%n" --author=$a | cut -f2 | awk '{s+=$1} END {print s}'
    echo -n "Number of merges: "
    git log $LOGOPTS $END_AND_BEGIN --all --merges --author=$a | grep -c '^commit'

done

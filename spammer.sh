#!/bin/sh
set -eu

CFGF=~/.spammerc
MAILDIR=~/Mail
SPAMDIRS=spam
HAMDIRS=inbox
CHECKDIRS=inbox
DSTSPAM=spam

[ -e $CFGF ] && . $CFGF

CHECKSTAMP="$MAILDIR/.spammer.checkstamp"
LEARNSTAMP="$MAILDIR/.spammer.learnstamp"

check() {
	for dir in $CHECKDIRS ; do
		for m in $MAILDIR/$dir/new/* ; do
			[ $CHECKSTAMP -nt $m ] && continue
			bogofilter < $m && mv $m $MAILDIR/$DSTSPAM/new
		done
	done

	touch $CHECKSTAMP
}

learn() {
	for dir in $HAMDIRS ; do
		find $MAILDIR/$dir/cur -type f -newer $LEARNSTAMP -print0 | xargs -0 bogofilter -n -B
	done
	
	for dir in $SPAMDIRS ; do
		find $MAILDIR/$dir/cur -type f -newer $LEARNSTAMP -print0 | xargs -0 bogofilter -s -B
	done

	touch $LEARNSTAMP
}

maint() {
	bogoutil -m ~/.bogofilter/wordlist.db
}

[ -e $CHECKSTAMP ] || touch -t 197001010000 $CHECKSTAMP
[ -e $LEARNSTAMP ] || touch -t 197001010000 $LEARNSTAMP

case "${1:-}" in
	check)
		check ;;
	learn)
		learn ;;
	maint)
		maint ;;
	*)
		echo "$0 [check|learn|maint]"
		exit 1
		;;
esac








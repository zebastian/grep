#!/bin/bash

: ${srcdir=.}
. "$srcdir/init.sh"; path_prepend_ ../src

# GREP Regression test suite for Fedora bugs and fixes
# (c) 2008 Lubomir Rintel
# Licensed under the same terms as GNU Grep itself

if [ -t 1 ]
then
	# Colored output on terimal
	G='\033[32m'
	R='\033[31m'
	D='\033[0m'
fi

ok ()	{ echo -e "${G}OK${D}"; }
fail () { echo -e "${R}FAIL${D} (See ${U})"; failures=1; }

U=https://bugzilla.redhat.com/show_bug.cgi?id=116909
echo -n "fgrep false negatives: "
cat > 116909.list <<EOF
a
b
c
EOF
cat > 116909.in <<EOF
a
barn
c
EOF
cat > 116909.out <<EOF
a
c
EOF
grep -F -w -f 116909.list 116909.in | diff - 116909.out && ok || fail

U=https://bugzilla.redhat.com/show_bug.cgi?id=123362
echo -n "bad handling of brackets in UTF-8: "
echo Y > 123362.out
echo Y | LC_ALL=de_DE.UTF-8 grep -i '[y,Y]' | diff - 123362.out && ok | fail

U=https://bugzilla.redhat.com/show_bug.cgi?id=112869
echo -n "crash with \W: "
echo '<form>' > 112869.out
LANG=it_IT grep -iE '\Wform\W' 112869.out | diff - 112869.out && ok || fail

if ( timeout --version ) > /dev/null 2>&1; then

  U=https://bugzilla.redhat.com/show_bug.cgi?id=189580
  echo -n "grep -D skip opening a special file: "
  timeout 10 grep -D skip foo /dev/zero
  test $? = 124 && fail || ok

  U=https://bugzilla.redhat.com/show_bug.cgi?id=169524
  echo -n "grep -Fw looping infinitely: "
  echo foobar | timeout 10 grep -Fw ""
  test $? = 124 && fail || ok

  U=https://bugzilla.redhat.com/show_bug.cgi?id=140781
  echo -n "fgrep hangs on binary files: "
  timeout 10 grep -F grep "$abs_top_builddir/src/grep" >/dev/null
  test $? = 124 && fail || ok

fi

U=https://bugzilla.redhat.com/show_bug.cgi?id=161700
echo -n "grep -Fw fails to match anything: "
echo test > 161700.out
grep -Fw test 161700.out | diff - 161700.out && ok || fail

U=https://bugzilla.redhat.com/show_bug.cgi?id=179698
echo -n "grep -w broken in non-utf8 multibyte locales: "
echo za a > 179698.out
LANG=ja_JP.eucjp grep -w a 179698.out | diff - 179698.out && ok || fail

# Skip the rest of tests in compiled without PCRE
echo a |grep -P a >/dev/null || Exit $failures

U=https://bugzilla.redhat.com/show_bug.cgi?id=171379
echo -n "grep -P crashes on whitespace lines: "
echo '   ' > 171379.out
grep -P '^\s+$' 171379.out | diff - 171379.out && ok || fail

U=https://bugzilla.redhat.com/show_bug.cgi?id=204255
echo -n "-e '' does not work if not a first parameter: "
echo test | grep -e 'HighlightThis' -e '' > 204255.first
echo test | grep -e '' -e 'HighlightThis' > 204255.second
diff 204255.first 204255.second && ok || fail

U=https://bugzilla.redhat.com/show_bug.cgi?id=324781
echo -n "bad handling of line breaks with grep -P #1: "
echo -ne "a\na" | grep -P '[^a]' >/dev/null && fail || ok

# This is mostly a check that fix for above doesn't break -P further
echo -n "bad handling of line breaks with grep -P #2: "
echo -ne "a\na" | grep -P '[^b].[^b]' >/dev/null && fail || ok

Exit $failures

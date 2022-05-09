#!/bin/bash

test -n "$1" || {
    echo 1>&2 "The first argument to $0 must be the directory containing the"
    echo 1>&2 "console.log file with the output of qemu/uml/..."
    exit 1
}

TMPOUTPUT="$1/console.log"
test -r "$TMPOUTPUT" || {
    echo 1>&2 "The file '$TMPOUTPUT' does not exist. Either no output was"
    echo 1>&2 "generated by the test, or \$1 is not the correct directory"
    exit 2
}

# See SF-73 for background
if grep -E -q '^1..0' "$TMPOUTPUT" ; then
    # munge the test output to fix-up the number of test suites
    N_TESTS="$(grep -c "    # Subtest:" "$TMPOUTPUT")" || true
    sed -i -e "s/^1..0/1..$N_TESTS/" "$TMPOUTPUT" || true
fi

if [ "$N_TESTS" == "0" ] || ! python3 "{parser}" parse < "$TMPOUTPUT"; then
  if [ "$N_TESTS" == "0" ]; then
    echo 1>&2 "=======> NO TESTS WERE RUN! Something went wrong."
  else
    echo 1>&2 "=======> TESTS FAILED. Scroll up to see the error."
  fi
  exit 100
fi
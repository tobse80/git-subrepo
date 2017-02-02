#!/usr/bin/env bash

set -e

source test/setup

use Test::More


test_round() {
  clone-foo-and-bar
    
  clone_output="$(
    cd $OWNER/foo
    git subrepo clone ../../../$UPSTREAM/bar $1
  )"	   

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../../../tmp/upstream/bar' (master) cloned into '$1'." \
    'subrepo clone command output is correct'    

  test-exists "$OWNER/foo/$1/"

  (
    cd $OWNER/bar
    add-new-files Bar2
    git push
  ) &> /dev/null || die

  # Do the pull and check output:
  {
    is "$(
       cd $OWNER/foo
       git subrepo pull $1
       )" \
       "Subrepo '$1' pulled from '../../../tmp/upstream/bar' (master)." \
       'subrepo pull command output is correct'
  }

  test-exists "$OWNER/foo/$1/"
  
  (
    cd $OWNER/foo/$1
    add-new-files new
    git push
  ) &> /dev/null || die
  
  # Do the push and check output:
  {
    is "$(
       cd $OWNER/foo
       git subrepo -vd push $1
       )" \
       "Subrepo '$1' pushed to '../../../tmp/upstream/bar' (master)." \
       'subrepo push command output is correct'
  }
}

test_round .strange
#test_round str%ange

done_testing

teardown

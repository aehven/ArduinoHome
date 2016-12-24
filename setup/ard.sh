#!/bin/bash

function resource {
  source $ARDUINO_HOME/setup/ard.sh
}

function go {
  cd $ARDUINO_HOME
}

function cls {
  alias cls='printf "\033c"'
}

function mem {
    ps -e -orss=,args= | sort -b -k1,1n | pr -TW$COLUMNS;
    free -h
}

function mem_mon {
  interval=$1
  if [[ -z $interval ]]; then
    interval=3
  fi

  echo "Checking every $interval seconds."

  while [[ 1 ]]; do
    mem > /tmp/mem
    cat /tmp/mem|grep -e "rails s.*3000"|grep -v grep|awk '{printf "Org: %d\t", $1}'
    echo
    sleep $interval
  done
}

function killBranch {
  git branch -d "$1"
  git push origin :"$1"
}

function prune {
  git remote prune origin
}

function genreset {
  cd $ARDUINO_HOME
  rake db:drop
  rake db:create
  rake db:migrate
  rake db:seed
  mysqldump -uaehven -pcypress arduino_home_development > reset.sql
}

function dbreset {
  JUST_RESET=false

  if [[ ! -f $ARDUINO_HOME/reset.sql ]]
    then
    genreset
    JUST_RESET=true
  fi

  case $1 in
    test)
      mysql -usxyphmel0m1m0qud -pyxd7hpyvv2z9i0bc -hbqmayq5x95g1sgr9.cbetxkdyhwsb.us-east-1.rds.amazonaws.com --database cdhf9b99aml66wq5 < reset.sql
      ;;
    *)
      if [[ "$JUST_RESET" != "true" ]]; then
        mysql -uaehven -pcypress --database arduino_home_develop < reset.sql
      fi
      ;;
  esac

  echo "Database reset."
}

export DISALLOWED_CODE='byebug|logger.*#{params}|debugger|binding.pry'

function isDisallowedCodeUsed {
  result=`find $ARDUINO_HOME -type f -name "*.*rb" -o -name "*.*js" -not -path "*\.bundle/*" -not -path "*\bower_components/*" -exec grep -Eln $DISALLOWED_CODE {} \;`

  if [[ ! -z "$result" ]]; then
    echo "***************************************************"
    echo "************** DEPLOYMENT CANCELLED ***************"
    echo "***************************************************"
    echo "***** There are calls to disallowed code in:  *****"
    echo "$result"
    echo "***************************************************"
    return 0
  else
    return 1
  fi
}

function simplify_string() {
  x=$1

  #remove spaces
  x="${x//+([[:space:]])/}"

  #remove color codes
  case $(uname -s) in
    Linux)
      x=$(echo $x|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
      ;;
    Darwin)
      x=$(echo $x|sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
      ;;
  esac

  echo $x
}

function stringify_git_st() {
  st=$(git status --porcelain)
  st=$(simplify_string "$st")
  echo "$st"
}

function stringify_git_origin_diff() {
  d=$(git --no-pager diff $BRANCH origin/$BRANCH)
  d=$(simplify_string "$d")
  echo "$d"
}

function stringify_git_unpushed() {
  u=$(git log @{u}..)
  u=$(simplify_string "$u")
  echo "$u"
}

function codeCheck {
  echo -n "Checking git st.... "
  if [[ $(stringify_git_st) != "" ]]; then
      echo "Uncommitted changes!"
      return 1
  fi
  echo "OK."

  echo -n "Checking git unpushed commits.... "
  if [[ $(stringify_git_unpushed) != "" ]]; then
      echo "Unpushed changes!"
      return 1
  fi
  echo "OK."

  echo "Looking for disallowed code.... "
  if isDisallowedCodeUsed; then
    return 1
  fi
  echo "OK"

  return 0
}

function deploy_usage {
   echo "Usage: deploy -a <test|production> -b <develop|release|master> [ -o <migrate> ] [-l] [-c]"
}

function deploy {
  local OPTIND #reset options index to the start
  unset APP
  unset TYPE
  unset BRANCH
  while getopts "a:b:o:lc" opt; do
    case "${opt}" in
      a)
        APP=${OPTARG}
        [[ $APP == "test" || $APP == "production" ]] || unset APP
        ;;
      b)
        BRANCH=${OPTARG}
        [[ $BRANCH == "develop" || $BRANCH == "release" || $BRANCH == "master" ]] || unset BRANCH
        ;;
      o)
        OPERATION=${OPTARG}
        [[ $OPERATION == "migrate" ]] || OPERATION="invalid"
        ;;
      l)
        NOLOG=true
        ;;
      c)
        NOCODECHECK=true
        ;;
      *)
        deploy_usage
        ;;
    esac
  done

  #the following causes $* and $@ to contain all other command line args that weren't in the getopts options.
  #see here: http://stackoverflow.com/questions/4587076/how-to-create-a-bash-script-that-takes-arguments
  shift $((OPTIND-1))

  if [[ -z $APP || -z $BRANCH || $OPERATION == "invalid" ]]; then
    deploy_usage
    return 1
  fi

  git checkout $BRANCH

  resource

  if [[ -z $NOCODECHECK ]]; then
    if ! codeCheck; then
      return 1
    fi
  fi

  if [[ $APP == "production" ]]
    then
    read -p "Deploying to production.  Are you sure? " -n 1
    echo
    if [[ ! $REPLY =~ [Yy] ]]
      then
      return 1
    fi
  fi

  cd $ARDUINO_HOME

  APPLICATION_NAME="arduino_home-$APP"

  echo -e "\nDeploying $BRANCH to $APPLICATION_NAME\n"

  echo -e "\nPusing code.\n"
  git push -f $APP $BRANCH:master

  if [[ $OPERATION == "migrate" ]]; then
    echo -e "\nMigrating database.\n"
    sleep 10
    heroku run rake db:migrate -a $APPLICATION_NAME
    sleep 5
  fi

  if [[ -z $NOLOG ]]; then
    echo -e "\nTailing log.\n"
    heroku logs --tail -a $APPLICATION_NAME
  fi

  return 0
}

function tmuxinit {
  tmux start-server
  tmux new-session -d -s arduino
  tmux new-window -t arduino:1 -n sql
  tmux new-window -t arduino:2 -n console
  tmux new-window -t arduino:3 -n server
  tmux new-window -t arduino:4 -n shell

  tmux send-keys -t arduino:1 "mysql -uaehven -pcypress arduino_home_development" C-m
  tmux send-keys -t arduino:2 "cd $ARDUINO_HOME; rails c" C-m
  tmux send-keys -t arduino:3 "cd $ARDUINO_HOME; rails s -b0.0.0.0" C-m
  tmux send-keys -t arduino:4 "cd $ARDUINO_HOME" C-m

  tmux select-window -t arduino:3
  tmux attach-session -t arduino
}

function start {
  rm log/development.log; rails s -b0.0.0.0 | tee log/development.log
}

function stop {
  kill -9 $(ps -ef|grep "rails s"|grep -v "rails s"|awk '{print $2}') &> /dev/null
  kill -9 $(ps -ef|grep "puma.*worker"|grep -v "grep"|awk '{print $2}') &> /dev/null
}

echo "ARDUINO_HOME = $ARDUINO_HOME"

# heroku accounts:set nuset
#
# export SMTP_SERVER_USERNAME=16618858-e9cb-4771-ae51-a5f6f8bf834e
# export SMTP_SERVER_PASSWORD=16618858-e9cb-4771-ae51-a5f6f8bf834e
# export SMTP_SERVER_URL=smtp.postmarkapp.com
# export SMTP_SERVER_DOMAIN=www.binarytrees.biz
export WEB_CONCURRENCY=1

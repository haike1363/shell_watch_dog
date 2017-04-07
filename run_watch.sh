#!/bin/bash
SHELL_DIR=$(cd `dirname $0`; pwd)
cd ${SHELL_DIR}

if [ ! -e "watch_app.conf" ];then
  echo "ERROR: run.conf is not exists"
  exit 3
fi

PID_RET=""

source ./watch_app.conf

APP_MD5=`echo ${APP_NAME} | md5sum - | awk '{print $1}'`

SHELL_NAME=`basename $0`

get_watch_pid() {
  PID_RET=`ps -ef | grep ${SHELL_NAME} | grep watch | grep ${APP_MD5} | awk '{print $2}'`
}

start() {
  get_pid
  if [ -z "${PID_RET}" ];then
    start_proc
    get_pid
    if [ ! -z "${PID_RET}" ];then
      echo "start ${APP_NAME} ok pid ${PID_RET}"
    else
      echo "start ${APP_NAME} fail"
      return 1
    fi
  else
    echo "${APP_NAME} is running pid ${PID_RET}"
  fi
  get_watch_pid
  if [ -z "${PID_RET}" ];then
    nohup sh ${SHELL_NAME} watch ${APP_MD5} 2>&1 1>/dev/null &
    get_watch_pid
    echo "start ${APP_NAME} watch ok pid ${PID_RET}"
  else
    echo "${APP_NAME} watch is running pid ${PID_RET}"
  fi
}

stop() {
  get_watch_pid
  if [ ! -z "${PID_RET}" ];then
    kill -9 ${PID_RET}
  if [ ${?} -eq 0 ];then
      echo "stop watch ${APP_NAME} pid ${PID_RET} ok"
  else
    echo "stop watch ${APP_NAME} pid ${PID_RET} fail"
    return 1
  fi
  else
    echo "${APP_NAME} watch is not running"
  fi
  get_pid
  if [ ! -z "${PID_RET}" ];then
    stop_proc ${PID_RET}
  if [ ${?} -eq 0 ];then
      echo "stop ${APP_NAME} pid ${PID_RET} ok"
  else
    echo "stop ${APP_NAME} pid ${PID_RET} fail"
    return 1
  fi
  else
    echo "${APP_NAME} is not running"
  fi
}

get_status() {
  get_pid
  if [ ! -z "${PID_RET}" ];then
    echo "${APP_NAME} is running pid ${PID_RET}"
  else
    echo "${APP_NAME} is not running"
  fi
  get_watch_pid
  if [ ! -z ${PID_RET} ];then
    echo "${APP_NAME} watch is running pid ${PID_RET}"
  else
    echo "${APP_NAME} watch is not running"
  fi
}

watch() {
  while :
  do
    sleep 5
    get_pid
    if [ -z "${PID_RET}" ];then
      echo "${APP_NAME} is not running now start it"
      start
    fi
  done
}


case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        get_status
        ;;
  watch)
      if [ "$2" = "$APP_MD5" ];then
      watch
    fi
      ;;
    *)
    echo "Usage:sh $0 {start|stop|status|restart}"
    exit 2
esac

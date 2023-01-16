#!/bin/bash
echo "> 현재 구동중인 Port 확인"
SW_CURRENT_TOMCAT_1="$(netstat -nap | grep :::9090 | awk '{print $6"\t"$11}')"
SW_CURRENT_TOMCAT_2="$(netstat -nap | grep :::9091 | awk '{print $6"\t"$11}')"
echo "> 구동여부 1번 : ${SW_CURRENT_TOMCAT_1}"
echo "> 구동여부 2번 : ${SW_CURRENT_TOMCAT_2}"
IDLE_PORT=[$IDLE_PORT]

echo "> 전환할 Port: ${IDLE_PORT}"
echo "> Port 전환"
echo "set \$board_service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/services/board-service-url.inc

echo "> Nginx Current Proxy Port: ${IDLE_PORT}"

echo "> Nginx Reload"
sudo service nginx reload

echo "> 반대 port 종료"
if [ "${IDLE_PORT}" == 9090 ]
then
  SW_IDLE_PID="$(lsof -t -i :9091 -s TCP:LISTEN)"
elif [ "${IDLE_PORT}" == 9091 ]
then
  SW_IDLE_PID="$(lsof -t -i :9090 -s TCP:LISTEN)"
fi

sudo kill -9 "${SW_IDLE_PID}"
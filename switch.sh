echo "> 현재 구동중인 Port 확인"
CURRENT_TOMCAT_1="$(netstat -nap | grep :::9090 | awk '{print $6"\t"$11}')"
CURRENT_TOMCAT_2="$(netstat -nap | grep :::9091 | awk '{print $6"\t"$11}')"
echo "> 구동여부 1번 : ${CURRENT_TOMCAT_1}"
echo "> 구동여부 2번 : ${CURRENT_TOMCAT_2}"

if [ "${CURRENT_TOMCAT_1}" == LISTEN ]
then
  IDLE_PORT=9091
elif [ "${CURRENT_TOMCAT_2}" == LISTEN ]
then
  IDLE_PORT=9090
else
  echo "> 구동되는 Tomcat이 없습니다."
  echo "> Tomcat1을 할당합니다. IDLE_TOMCAT:1"
  IDLE_PORT=9090
fi

echo "> 전환할 Port: ${IDLE_PORT}"
echo "> Port 전환"
echo "set \$board_service_url http://localhost:${IDLE_PORT};" | tee /etc/nginx/services/board-service-url.inc

echo "> Nginx Current Proxy Port: ${IDLE_PORT}"

echo "> Nginx Reload"
service nginx reload

echo "> 반대 port 종료"
if [ "${IDLE_PORT}" == 9090 ]
then
  IDLE_PID="$(lsof -t -i :9091 -s TCP:LISTEN)"
elif [ "${CURRENT_TOMCAT_2}" == 9091 ]
then
  IDLE_PID="$(lsof -t -i :9090 -s TCP:LISTEN)"
fi

kill -9 "${IDLE_PID}"
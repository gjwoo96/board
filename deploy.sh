#!/bin/bash
echo "> 현재 구동중인 Tomcat 확인"
CURRENT_TOMCAT_1="$(netstat -nap | grep :::9090 | awk '{print $6"\t"$11}')"
CURRENT_TOMCAT_2="$(netstat -nap | grep :::9091 | awk '{print $6"\t"$11}')"
echo "> 구동여부 1번 : ${CURRENT_TOMCAT_1}"
echo "> 구동여부 2번 : ${CURRENT_TOMCAT_2}"
CURRENT_JENKINS_DIR=/var/lib/jenkins/workspace/github-board_main
CURRENT_JENKINS_BUILD_FILE=/var/lib/jenkins/workspace/github-board_main/target

if [[ "${CURRENT_TOMCAT_1}" == *LISTEN* ]]
then
  IDLE_TOMCAT=2
  IDLE_TOMCAT_DIR=/opt/tomcat-2
  IDLE_PORT=9091
elif [[ "${CURRENT_TOMCAT_2}" == *LISTEN* ]]
then
  IDLE_TOMCAT=1
  IDLE_TOMCAT_DIR=/opt/tomcat-1
  IDLE_PORT=9090
else
  echo "> 구동되는 Tomcat이 없습니다."
  echo "> Tomcat1을 할당합니다. IDLE_TOMCAT:1"
  IDLE_TOMCAT=1
  IDLE_TOMCAT_DIR=/opt/tomcat-1
  IDLE_PORT=9090
fi

echo "> IDLE_TOMCAT 배포"
sudo fuser -k -n tcp ${IDLE_PORT}
sudo rm "${IDLE_TOMCAT_DIR}/webapps/board.war"
sudo cp -iv "${CURRENT_JENKINS_BUILD_FILE}"/*.war "${IDLE_TOMCAT_DIR}/webapps/board.war"
sudo sh "${IDLE_TOMCAT_DIR}/bin/startup.sh"

echo "> IDEL : ${IDLE_TOMCAT} 10초 후 Health check 시작"
sleep 10

echo "> Health check"

for retry_count in {1..10}
do
  response="$(curl -L -k -s -o /dev/null -w "%{http_code}\n" localhost:${IDLE_PORT}/board)"
  up_count="$(echo "${response}" | grep '200' | wc -l)"

  if [ "${up_count}" -ge 1 ]
  then
    echo "> Health check 성공"
    break
  else
    echo "> Health check의 응답을 알 수 없거나 혹은 status가 UP이 아닙니다."
    echo "> Health check: ${response}"
  fi

  if [ "${retry_count}" -eq 10 ]
  then
    echo "> Health check 실패. "
    echo "> Nginx에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sleep 10
done

echo "> 스위칭을 시도합니다..."
sleep 10

echo "> 현재 구동중인 Port 확인"
SW_CURRENT_TOMCAT_1="$(netstat -nap | grep :::9090 | awk '{print $6"\t"$11}')"
SW_CURRENT_TOMCAT_2="$(netstat -nap | grep :::9091 | awk '{print $6"\t"$11}')"
echo "> 구동여부 1번 : ${SW_CURRENT_TOMCAT_1}"
echo "> 구동여부 2번 : ${SW_CURRENT_TOMCAT_2}"

echo "> 전환할 Port: ${IDLE_PORT}"
echo "> Port 전환"
echo "set \$board_service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/services/board-service-url.inc

echo "> Nginx Current Proxy Port: ${IDLE_PORT}"

echo "> Nginx Reload"
sudo service nginx reload

echo "> 반대 port 종료"
echo "${IDLE_PORT}"
SW_IDLE_PID="$(lsof -ti :9091 -s TCP:LISTEN)"
SW_IDLE_PID="$(lsof -ti :9090 -s TCP:LISTEN)"
echo "${SW_IDLE_PID}"

if [[ "${IDLE_PORT}" == 9090 ]]
then
  SW_IDLE_PID="$(lsof -ti :9091 -s TCP:LISTEN)"
  echo "T1 : ${SW_IDLE_PID}"
elif [[ "${IDLE_PORT}" == 9091 ]]
then
  SW_IDLE_PID="$(lsof -ti :9090 -s TCP:LISTEN)"
  echo "T2 : ${SW_IDLE_PID}"
fi

sudo kill -9 "${SW_IDLE_PID}"
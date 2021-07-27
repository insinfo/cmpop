REM docker build -t cmpop_server .
cp -r ..\cmpop_core\ .\cmpop_core
docker build -t cmpop_server -f Dockerfile_aot .
rm -r .\cmpop_core
docker stop cmpop_server
docker rm cmpop_server
REM docker build -t cmpop_server -f ./cmpop_server/Dockerfile .
docker run -e "dbhost=10.0.0.22" -d --name cmpop_server -p 4002:4002 cmpop_server  

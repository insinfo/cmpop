docker container stop cmpop_browser
docker container rm cmpop_browser  
REM docker image rm cmpop_browser  
docker build -t cmpop_browser .
docker run -d -p 8085:8084 --name cmpop_browser --restart always cmpop_browser

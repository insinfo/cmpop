FROM google/dart:2.10 as cmpop_server
WORKDIR /app
ADD pubspec.* /app/
COPY cmpop_core /cmpop_core
RUN pub get 
ADD . /app
RUN pub get --offline
#variavel de tempo de criação de imagem
#ARG dbhost
#pode ser usada assim
#docker build --build-arg dbhost=localhost
#ou na hora de iniciar um container você pode passar variaves
#ENV dbhost e na hora de executar docker run -e "dbhost=192.168.133.13"
ENV dbhost=localhost
#--no-precompile 
# Optionally build generaed sources.
# RUN pub run build_runner build
RUN cp .env.example.linux .env
#CMD ["sh", "-c", "/usr/bin/dart run bin/prod.dart -p 3150 -a 0.0.0.0 --dbhost ${dbhostr}"]
CMD /usr/bin/dart run bin/prod.dart -p 4002 -a 0.0.0.0 --dbhost=$dbhost
#CMD ["/bin/dart", "run", "./bin/prod.dart","-p","3150","-a", "0.0.0.0","-dbhost","$dbhost"]
#ENTRYPOINT ["/usr/bin/dart", "run", "./bin/prod.dart","-p","3150","-a", "0.0.0.0","dbhost",${dbhost}]
EXPOSE 4002
# cria a imagem 
# docker build -t cmpop_server -f ./cmpop_server/Dockerfile cmpop_server
# docker build -t cmpop_server .  
# executa a imagem
# docker run -e "dbhost=192.168.66.123" -d --name cmpop_server -p 4002:4002 cmpop_server   
# docker run -e "dbhost=192.168.66.123" -i --name cmpop_server -p 4002:4002 cmpop_server   

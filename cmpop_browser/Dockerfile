# Estagio 1 - Será responsavel em construir a aplicação
FROM google/dart:2.10 as cmpop_browser
WORKDIR /app
ADD pubspec.* /app/
RUN pub get --no-precompile
ADD . /app/
RUN pub get --offline --no-precompile
ENV PATH="$PATH:/root/.pub-cache/bin"
RUN pub global activate webdev
#EXPOSE 8082 # isso é se for rodar sem nginx
#CMD ["webdev", "serve", "web:8082","--hostname", "0.0.0.0"] 
RUN ["webdev", "build"]
# Estagio 2 - Será responsavel por expor a aplicação
FROM nginx:1.19.4-alpine
COPY --from=jubarte2browser /app/build /var/www/html
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
# cria a imagem 
# docker build -t cmpop_browser .  
# executa a imagem
# docker run -d --name cmpop_browser -p 8082:8082 cmpop_browser   

FROM ubuntu:18.04

MAINTAINER "Victor Bertoldo"

RUN apt-get -y update
RUN apt-get -y install git
RUN mkdir -p /root/.ssh/

# Este passo abaixo adiciona as chaves (privada e publica), que foram geradas na maquina host para a imagem.

ADD id_rsa /root/.ssh/
ADD id_rsa.pub /root/.ssh/

RUN chmod 600 /root/.ssh/*

#Para gerar o build da imagem use sempre docker image build -t nome:tag ---- Como boa pratica sempre use o padrão de tags desta forma v1.0.0 - assim é possivel controlar a versão do build

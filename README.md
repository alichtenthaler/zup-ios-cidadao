# Zeladoria Urbana Participativa - API

## Introdução

Sabemos que o manejo de informação é uma das chaves para uma gestão eficiente, para isso o ZUP apresenta um completo histórico de vida de cada um dos ativos e dos problemas do município, incorporando solicitacões de cidadãos, dados georeferenciados, laudos técnicos, fotografias e ações preventivas realizadas ao longo do tempo. Desta forma, o sistema centraliza todas as informações permitindo uma rápida tomada de decisões tanto das autoridades como dos técnicos em campo.

Esse componente é responsável por ser a ponte entre o usuário e a instituição utilizando o ZUP para a Gestão.

## Notas

É importante que você mantenha o XCode sempre atualizado, pois o aplicativo é desenvolvido sempre com a última versão do IDE e do SDK.

## Servidor

Este aplicativo necessita que o componente [ZUP-API](https://github.com/LaFabbrica/zup-api) esteja rodando no seu servidor local.

## Requerimentos

Ruby
XCode 5+

## Setup do projeto

Primeiramente, você necessitará instalar o [Cocoapods](https://cocoapods.org):

    gem install cocoapods

Após instalado, utilize o seguinte comando para instalar as dependências:

    pod install

Para maiores informações, [acesse a documentação no site do Cocoapods](https://cocoapods.org).

## Suporte

iOS 7.1+

## Libraries/Compiles

Abaixo a lista das libraries / compiles que estão sendo utilizados no projeto:

* SDWebImage 3.7
* ISO8601DateFormatter 0.7


#!/bin/bash

#Limpar diretórios
rm -rf alice/*
rm -rf bob/*
echo o diretorio foi limpo
echo

# Gerar chaves para Alice
openssl genrsa -out alice/private.pem
openssl rsa -in alice/private.pem -pubout -out alice/public.pem
echo as chaves da Alice foram geradas
echo 

# Gerar chaves para Bob
openssl genrsa -out bob/private.pem
openssl rsa -in bob/private.pem -pubout -out bob/public.pem
echo as cahves do Bob foram geradas
echo

# Compartilhar chaves públicas
cp alice/public.pem bob/alice.pub.pem
cp bob/public.pem alice/bob.pub.pem
echo as chaves foram compartilhadas
echo

# Alice gera chave AES
openssl rand -hex 32 > alice/aes_key.txt
openssl rand -hex 16 > alice/aes_iv.txt

AES_KEY_ALICE=$(cat alice/aes_key.txt)
AES_IV=$(cat alice/aes_iv.txt)
echo a chave AES foi gerada
echo

# Alice criptografa a chave AES com chave pública do Bob
echo $AES_KEY_ALICE | openssl rsautl -encrypt -pubin -inkey alice/bob.pub.pem > alice/aes_key.enc
echo a chave AES foi criptografada
echo

# Alice assina a mensagem
## a assinatura se dá criptografando novamente senha utilizando esta vez sua chave privada
openssl dgst -sha256 -sign alice/private.pem -out alice/aes_key.enc.sig alice/aes_key.enc
echo a assinatura da Alice foi gerada
echo

# Alice envia chave criptografada e assinatura para Bob
cp alice/aes_key.enc bob/alice.aes_key.enc
cp alice/aes_key.enc.sig bob/alice.aes_key.enc.sig
echo as chaves a da Alice foram enviadas para Bob
echo

# Bob verifica a assinatura da Alice
openssl dgst -sha256 -verify bob/alice.pub.pem -signature bob/alice.aes_key.enc.sig bob/alice.aes_key.enc
echo a assinatura de Alice foi verificada
echo

# Bob descriptografa a chave de Alice
AES_KEY_BOB=$(cat bob/alice.aes_key.enc | openssl rsautl -decrypt -inkey bob/private.pem)
echo a chave foi descriptografada por Bob
echo

# Alice criptografa mensagem e envia para bob
echo Mensagem secreta de Alice para Bob > alice/mensagem.txt
openssl enc -aes-256-cbc -K $AES_KEY_ALICE -iv $AES_IV -in alice/mensagem.txt -out bob/mensagem.alice.enc
echo a mensagem de Alice foi criptografada e entregue a Bob
echo

# Bob descriptografa e lê a mensagem recebida da Alice
echo $(openssl enc -d -aes-256-cbc -K $AES_KEY_BOB -iv $AES_IV -in bob/mensagem.alice.enc)
echo a mensagem de Alice foi lida por Bob
echo

# Bob criptografa mensagem e envia para Alice
echo Mensagem secreta de Bob para Alice > bob/mensagem.txt
openssl enc -aes-256-cbc -K $AES_KEY_BOB -iv $AES_IV -in bob/mensagem.txt -out alice/mensagem.bob.enc
echo a mensagem de Bob foi criptografada e entregue a Alice
echo

# Alice descriptografa e lê a mensagem recebida de Bob
echo $(openssl enc -d -aes-256-cbc -K $AES_KEY_ALICE -iv $AES_IV -in alice/mensagem.bob.enc)
echo a mensagem de Bob foi lida por Alice

echo e assim continuaram a conversar de forma segura e felizes para sempre
echo FIM

# #Limpar diretórios
# rm -rf alice/*
# rm -rf bob/*

#Referencias

# https://medium.com/b2w-engineering/compartilhando-chaves-aes-utilizando-rsa-com-openssl-3beffb1b2010
# https://zeroandrade.com.br/como-criptografar-arquivos-com-openssl.html
# https://sleeplessbeastie.eu/2021/05/12/how-to-encrypt-or-decrypt-files-using-openssl-utility/
#!/bin/bash

printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m Installation [By @HadiDotSh]\e[0m"
read -p $'\n\e[0;92m?\e[0m\e[1;77m CloudFlare Token: \e[0;96m' cloudFlareToken

testToken=$(curl -sX GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
-H "Authorization: $cloudFlareToken" \
-H "Content-Type:application/json" | grep 'active')

if [[ -z $testToken ]];then
      printf "\e[0;91mx \e[0m\e[1;77mError !\e[0m\e[1;90m Double-check your Token or get helped at :\nhttps://dynbashdns.what-the-shell.me/\e[0m\n"
else
    printf "\n\e[0;92m✓ \e[0m\e[1;77mToken Added\e[0m\n"
    mkdir ~/.DynBashDns
    mv DynBashDns.sh ~/.DynBashDns/DynBashDns
    touch ~/.DynBashDns/records.txt
    IP=$(curl -s4 https://www.cloudflare.com/cdn-cgi/trace | grep 'ip' | sed 's/ip=//g')
    echo 'cloudFlareToken="'$cloudFlareToken'"
OLD_IP="'$IP'"
telegram=false
telegramToken=""
telegramChatID=""' > ~/.DynBashDns/records.txt
    printf "\n\e[0;92m- \e[0m\e[1;90mDynBashDns path : ~/.DynBashDns/\e[0m\n"
    printf "\n\e[0;92m- \e[0m\e[1;90mDon't touch this directory unless you know what you are doing ;)\e[0m"
    printf "\n\e[0;92m- \e[0m\e[1;77mType : \e[0;96mchmod 777 ~/.DynBashDns/DynBashDns\e[0m\n"
    printf "\n\e[0;92m- \e[0m\e[1;77mYou can add an alias to ~/.DynBashDns/DynBashDns in your bashrc/zshrc :\e[0m\n"
    printf "\n\e[0;92m- \e[0m\e[1;90mecho 'alias DynBashDns=\"bash ~/.DynBashDns/DynBashDns\"' >> .bashrc # or .zshrc \e[0m"
    printf "\n\e[0;92m- \e[0m\e[1;77mYou can add a crontab for DynBashDns too\e[0m\n"
    printf "\n\e[0;92m- \e[0m\e[1;90mGet helped at :\nhttps://dynbashdns.what-the-shell.me/\e[0m"

fi
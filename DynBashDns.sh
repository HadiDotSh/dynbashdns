#! /bin/bash
# Created by @HadiDotSh

add_record() {
    cloudFlareToken=$(cat ~/.DynBashDns/records.txt | sed -n 1p | sed 's/cloudFlareToken="//g;s/"//g' )
    printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m Add Record\e[0m"
    printf "\n\e[0;92m- \e[0m\e[1;90mYou can found help here: https://dynbashdns.what-the-shell.me \e[0m"
    read -p $'\n\e[0;92m?\e[0m\e[1;77m Domain Name (exemple.com): \e[0;96m' domainName
    read -p $'\e[0;92m?\e[0m\e[1;77m Subdomain (dbd.exemple.com, press enter if not): \e[0;96m' subDomainName

    # Ask the cloudflare api for the zone ID
    zoneID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/?name=$domainName" \
    -H "Authorization: $cloudFlareToken" \
    -H "Content-Type: application/json" | sed 's/,/\n/g' | grep 'id' | sed 's/{"result":\[{"id":"//g ; s/"//g' | sed -n 1p)

    if [[ -z "$zoneID" ]];then
      printf "\n\e[0;91mx \e[0m\e[1;77mError while getting the zone ID for \e[0;91m$domainName\e[0m\e[1;90m, double-check your domain name or get helped at https://dynbashdns.what-the-shell.me\e[0m\n"
      exit
    else
        printf "\e[0;92m- \e[0m\e[1;77mZone ID found\e[0m\e[1;90m ($zoneID)\e[0m\n"
    fi

    if [[ ! -z "$subDomainName" ]];then
        domainName="${subDomainName}.${domainName}"
    fi

    printf "\e[0;92m? \e[0m\e[1;77mProxy ?\e[0;96m [y/n]\e[0m"
    read yn
    if [[ "$yn" == "y" || "$yn" == "yes" || "$yn" == "Y" || "$yn" == "Yes" ]]; then
        proxied="true"
    else
        proxied="false"
    fi

    # Ask the cloudflare api for the record ID
	recordID=$( curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records?type=A&name=$domainName" \
     -H "Authorization: $cloudFlareToken" \
     -H "Content-Type: application/json" | sed 's/,/\n/g ; s/{/\n/g' | grep '"id"' | sed 's/"id":"//g ; s/"//g' )
    if [[ -z "$recordID" ]];then
      printf "\e[0;91mx \e[0m\e[1;77mError while getting the record ID for \e[0;91m$domainName\e[0m\e[1;90m, double-check your subdomain or get helped at https://dynbashdns.what-the-shell.me\e[0m\n"
      exit
    else
        printf "\e[0;92m- \e[0m\e[1;77mRecord ID found\e[0m\e[1;90m ($recordID)\e[0m\n"
        echo "$domainName $zoneID $recordID $proxied" >> ~/.DynBashDns/records.txt
        printf "\n\e[0;92m✓ \e[0m\e[1;77mRecord Added\e[0m\n"
    fi
}

remove_record() {
    printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m Remove Record\e[0m"
    read -p $'\n\e[0;92m+\e[0m\e[1;77m Full Domain Name : \e[0;96m' domainName

    choosenDomain=$(cat ~/.DynBashDns/records.txt | grep --ignore-case -m1 "^${domainName}")
    if [[ -z "$choosenDomain" ]];then
        printf "\e[0;91mx \e[0m\e[1;77mError while getting the full domain name\e[0m\e[1;90m, type \"DynBashDns list\" to see your current records\e[0m\n"
        exit
    else
        removeTemp=$(sed '/^'"$choosenDomain"'/d' ~/.DynBashDns/records.txt)
        echo "$removeTemp" > ~/.DynBashDns/records.txt
        printf "\e[0;92m✓ \e[0m\e[1;77mRecord Removed\e[0m\n"
    fi
}

list_records() {
    printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m List records\e[0m"
    printf "\n\e[0;92m? \e[0;90mFull Domain Name\e[0m\n\n"
    records=$(cat ~/.DynBashDns/records.txt | sed '1d;2d;3d;4d;5d' | grep -Eo '^[^ ]+')
    printf "$records\n"
}

list_detail_records() {
    printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m List records in detail\e[0m"
    printf "\n\e[0;92m? \e[0;90mFull Domain Name   ;   Zone ID   ;   Record ID   ;   Proxy\e[0m\n\n"
    records=$(cat ~/.DynBashDns/records.txt | sed '1d;2d;3d;4d;5d')
    printf "$records\n"
}

add_telegram() {
    printf "\e[0;92m- \e[0m\e[1;77mDynBashDns\e[0;96m Telegram Notifications\e[0m"
    read -p $'\n\e[0;92m?\e[0m\e[1;77m Telegram Token: \e[0;96m' telegramToken
    read -p $'\e[0;92m?\e[0m\e[1;77m Telegram Chat ID: \e[0;96m' telegramChatID

    date=$(date +"%d-%m-%Y  %T")
    curl -s -o /dev/null "https://api.telegram.org/bot${telegramToken}/sendMessage?chat_id=${telegramChatID}&parse_mode=HTML&text=\
🧶 <b>DynBashDns :</b>\
%0AAttempt to add telegram notifications\
%0A%0A<i>${date}</i>%0A--------------------------------------%0A%0A"
    printf "\e[0;92m? \e[0m\e[1;77mDid you receive the DynBashDns message?\e[0;96m [y/n]\e[0m"
    read yn
    if [[ $yn == y ]]; then
        modifTemp=$(cat ~/.DynBashDns/records.txt | sed 's/telegram=.*/telegram=true/g' )
        echo "$modifTemp" > ~/.DynBashDns/records.txt
        modifTemp=$(cat ~/.DynBashDns/records.txt | sed 's/telegramToken=.*/telegramToken="'"$telegramToken"'"/g' )
        echo "$modifTemp" > ~/.DynBashDns/records.txt
        modifTemp=$(cat ~/.DynBashDns/records.txt | sed 's/telegramChatID=.*/telegramChatID="'"$telegramChatID"'"/g' )
        echo "$modifTemp" > ~/.DynBashDns/records.txt
        printf "\n\e[0;92m✓ \e[0m\e[1;77mTelegram Notifications Added\e[0m\n"
        exit
    else
        printf "\n\e[0;91mx \e[0m\e[1;77mDouble-check your token,tchat ID or get helped at https://dynbashdns.what-the-shell.me\e[0m\n"
        exit
    fi

}

remove_telegram() {
    modifTemp=$(cat ~/.DynBashDns/records.txt | sed 's/telegram=.*/telegram=false/g' )
    echo "$modifTemp" > ~/.DynBashDns/records.txt
    printf "\e[0;92m✓ \e[0m\e[1;77mTelegram Notifications Removed\e[0m\n"
}

empty () {
    IP=$(curl -s4 https://www.cloudflare.com/cdn-cgi/trace | grep 'ip' | sed 's/ip=//g')
    cloudFlareToken=$(cat ~/.DynBashDns/records.txt | sed -n 1p | sed 's/cloudFlareToken="//g;s/"//g' )

    if ! $IP > /dev/null 2>&1 ; then
        OLD_IP=$(cat ~/.DynBashDns/records.txt | sed -n 2p | sed 's/OLD_IP="//g;s/"//g' )

        if [[ ! "${OLD_IP}" == "${IP}" ]];then
            allRecords=$( cat ~/.DynBashDns/records.txt |  sed 's/ /_/g;1d;2d;3d;4d;5d' )
            
            for record in $allRecords
            do
                record=$( echo "$record" |  sed 's/_/\n/g' )

                # Curl the cloud flare api to change the content of the record
                domainName=$(echo "$record" | sed -n 1p)
                zoneID=$(echo "$record" | sed -n 2p)
                recordID=$(echo "$record" | sed -n 3p)
                proxied=$(echo "$record" | sed -n 4p)

                ERROR=$(curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records/$recordID" \
                    -H "Authorization: $cloudFlareToken" \
                    -H "Content-Type: application/json" \
                    --data '{"type":"A","name":"'$domainName'","content":"'$IP'","proxied":'$proxied'}' | grep '"success":false' )

                # Checking if your records has been changed
                if [[ ! -z "$ERROR" ]];then
                    printf "\n\e[0;91mx \e[0m\e[1;77mError while changing your records..\e[0m"
                    if $telegram ;then
                telegramToken=$(cat ~/.DynBashDns/records.txt | sed -n 4p | sed 's/telegramToken="//g;s/"//g' )
                telegramChatID=$(cat ~/.DynBashDns/records.txt | sed -n 5p | sed 's/telegramChatID="//g;s/"//g' )
        		date=$(date +"%d-%m-%Y  %T")
	curl -s -o /dev/null "https://api.telegram.org/bot${telegramToken}/sendMessage?chat_id=${telegramChatID}&parse_mode=HTML&text=\
⛔️ <b>DynBashDns :</b>\
%0AAn error occurred while changing the dns record\
%0A%0A<i>${date}</i>%0A--------------------------------------%0A%0A"
                    fi
                    exit 1
                fi
            done

            # Saving your new IP adress in a file.
            modifTemp=$(cat ~/.DynBashDns/records.txt | sed 's/'"$OLD_IP"'/'"$IP"'/g')
            echo "$modifTemp" > ~/.DynBashDns/records.txt

            # Send the telegram notifications
            telegram=$(cat ~/.DynBashDns/records.txt | sed -n 3p | sed 's/telegram=//g' )
            if $telegram ;then
                telegramToken=$(cat ~/.DynBashDns/records.txt | sed -n 4p | sed 's/telegramToken="//g;s/"//g' )
                telegramChatID=$(cat ~/.DynBashDns/records.txt | sed -n 5p | sed 's/telegramChatID="//g;s/"//g' )
        		date=$(date +"%d-%m-%Y  %T")
                		curl -s -o /dev/null "https://api.telegram.org/bot${telegramToken}/sendMessage?chat_id=${telegramChatID}&parse_mode=HTML&text=\
🧶 <b>DynBashDns :</b>\
%0AHey, your IP has just changed, the dns record has been successfully changed\
%0AHere is the new one : <b>${IP}</b>\
%0A%0A<i>${date}</i>%0A--------------------------------------%0A%0A"
            fi
        fi
    else
        printf "\n\e[0;91mx \e[0m\e[1;77mNo internet connection.\e[0m"
    fi
	exit
}
[ -z "$1" ] && empty

############# Args
while [[ ! -z "$*" ]];do

    if [[ "$1" == "help" ]];then
		printf "\e[0;92m✓ \e[0m\e[1;77mDynBashDns\e[0;96m [By @HadiDotSh]\e[0m"
		printf "\n"
		printf "\n\e[1;77mArguments :\e[0m"
		printf "\n\e[1;92mhelp            \e[0m\e[1;77mShow brief help\e[0m"
		printf "\n\e[1;92madd [*]         \e[0m\e[1;77mAdd a new record or telegram notifications\e[0m"
		printf "\n\e[1;92mremove [*]      \e[0m\e[1;77mRemove a record or telegram notifications\e[0m"
		printf "\n\e[1;92mlist            \e[0m\e[1;77mList all current records\e[0m"
        printf "\n\e[1;92mlist detail     \e[0m\e[1;77mList records with name,zoneID,recordID and proxy status\e[0m"
		printf "\n"
        printf "\n\e[1;92m[*] Can be \"record\" or \"telegram\"     \e[0m"
		printf "\n\e[0;92m? \e[0m\e[1;77mMore information on\e[0;96m https://DynBashDns.what-the-shell.me\e[0m\n"
		exit
        
    elif [[ "$1" == "add" ]];then
        shift
        if [[ "$1" == "record" ]];then
            add_record
        elif [[ "$1" == "telegram" ]];then
            add_telegram
        else
            printf "\e[0;91mx \e[0m\e[1;77mUnknown argument \"$1\"\e[0m\n" && exit
        fi
        exit

    elif [[ "$1" == "remove" ]];then
        shift
        if [[ "$1" == "record" ]];then
            remove_record
        elif [[ "$1" == "telegram" ]];then
            remove_telegram
        else
            printf "\e[0;91mx \e[0m\e[1;77mUnknown argument \"$1\"\e[0m\n" && exit
        fi
        exit

    elif [[ "$1" == "list" ]];then
        shift
        if [[ -z "$1" ]];then
            list_records
        elif [[ "$1" == "detail" ]];then
            list_detail_records
        else
            printf "\e[0;91mx \e[0m\e[1;77mUnknown argument \"$1\"\e[0m\n" && exit
        fi
        exit

    else
        printf "\e[0;91mx \e[0m\e[1;77mUnknown argument \"$1\"\e[0m\n" && exit
    fi
    
done
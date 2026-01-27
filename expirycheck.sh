#### script owner: Vaibhavi Suri 
#### last modified: 01/11/2022
#!/bin/bash
####### Secret Name Pull from cluster ######
case $action in
secretpull)
secretNa=$secret
secretname=$(echo $secretNa | awk -F ' ' '{print $2}' | sed 's/.$//g')
echo $secretname
echo "##vso[task.setvariable variable=Var;isOutput=true]$secretname"
;;

####### End Date Pull from cluster ######
datepull)
crts=$certs
val=$(echo $crts | base64 -d | openssl x509 -enddate -noout |  awk -F '=' '{print $2}')
echo $val
echo "##vso[task.setvariable variable=Value;isOutput=true]$val"
;;

####### Email Report Fix ######
reportfix)
cd /agent/_work/_tasks/EmailReport_36fd41b1-8024-4ce9-a5a0-53c3e54ed105/1.1.8
cp ./index.js ./Index.js
sed -i -e "s~\\\\\\\\~/~" ./htmlreport/HTMLReportCreator.js
sed -i -e "s~\\\\\\\\~/~" ./model/helpers/LinkHelper.js
;;

####### Verifying the end date and dropping mail to stakeholders ######
emailcheck)
####### Verifying cluster running status ######
while IFS= read -r run; do
if [ ! -z "$value" ] && [ "$run" = "api.email.com" ]
      then
        outputapi="OK"
       elif [ $run == "email.ly" ]
         then
            output=$(curl -s https://$run/urlresolverapi/healthz)
        else  
          output=$(curl -s https://$run/healthz)
        fi          
if [ "$output" = 'OK' -o "$output" = 'URLResolver-API is ready.' -o "$outputapi" = 'OK' -a ! -z "$output" ]
then
           echo "$run domain's cluster is in running state, please proceed as expected"
           echo $run >> finaldomain.txt
else
           echo "$run domain's cluster is not in running state, please ignore that domain and proceed with remaining"
           echo -e "<tr style="color:red"><td style="text-align:center">$run</td></tr>" >> notrun.html
          fi
done < Domains/domains.txt
if [ -e notrun.html ]
           then
               sed -i '1s/^/<html>\n/' notrun.html
               sed -i '1 a\<head>\n' notrun.html
               sed -i '2 a\<body Type = text/html>\n' notrun.html
               sed -i '3 a\<table border=1 frame=void rules=rows">\n' notrun.html
               sed -i '4 a\<tr><th>DOMAIN NAME</th></tr>' notrun.html
               echo "</table>" >> notrun.html
               echo "</body>" >> notrun.html
               echo "</head>" >> notrun.html
               echo "</html>" >> notrun.html
               sed -i '3 a\<p>Hello DevOps Team, <br><br>Skipping SSL certificate verification for the below domains:</p>' notrun.html
               echo "<p><strong>Reason:</strong> Kubernetes Cluster not reacheable</p>" >> notrun.html
               echo -e "<p style="color:green"><strong>NOTE:  This is auto generated email please do not reply</strong></p>" >> notrun.html
               cat notrun.html | sendemail -f $user -t $to -u $subone -s smtp.office365.com:587 -xu $user -xp $pass -v -o tls=auto
          else
               echo "All Domains Clusters are running you can proceed further "
          fi  
####### Pulling end date from all domains ######          
if [ -e finaldomain.txt ]
then
while IFS= read -r line;do         
        echo "The domain name is $line"
		if [ $line == "api.email.com" ]
        then
        	datediffstr=$value
                if [ -z "$datediffstr" ]
                then
                     echo "$line didn't have value from above stages please verify"
                     exit 1
                else
                     echo "OpenSSL command is triggered for domain $line as expected saving the output in file"
                     echo "$line|$datediffstr" >> datedomain.txt
                fi
        else
        datestr=$(echo | openssl s_client -servername $line -connect $line:443 2>/dev/null | openssl x509 -enddate -noout | awk -F '=' '{print $2}')
        if [ -z "$datestr" ]
        then
                sleep 60
                datestrif=$(echo | openssl s_client -servername $line -connect $line:443 2>/dev/null | openssl x509 -enddate -noout | awk -F '=' '{print $2}')
                if [ -z "$datestr" ]
                then
                echo "Unable to trigger OpenSSL command as, tried for 2 times for $line domain still no response please check"
                exit 1
        else
                echo "OpenSSL command is triggered for domain $line as expected saving the output in file"
                echo "$line|$datestrif" >> datedomain.txt
        fi
        else
                echo "OpenSSL command is triggered for domain $line as expected saving the output in file"
                echo "$line|$datestr" >> datedomain.txt
        fi
        fi
done < finaldomain.txt
else
    echo "Cluster is not running for the domains please check"
fi  
####### Pulling domain list which will expire in less than 10 days ######  
if [ -e datedomain.txt ]
then
while IFS= read -r space; do
        datessl=$(echo $space | awk -F '|' '{print $2}')
        domain=$(echo $space | awk -F '|' '{print $1}')
        expirydate=$(date --date="$datessl" --utc +"%m-%d-%Y")
        mm=$(echo $expirydate | awk -F '-' '{print $1}')
        dd=$(echo $expirydate | awk -F '-' '{print $2}')
        yy=$(echo $expirydate | awk -F '-' '{print $3}')
        format="$yy-$mm-$dd"
        currentdate=$(echo $(date) | date --date="$(date)" --utc +"%m-%d-%Y")
        mmc=$(echo $currentdate | awk -F '-' '{print $1}')
        ddc=$(echo $currentdate | awk -F '-' '{print $2}')
        yyc=$(echo $currentdate | awk -F '-' '{print $3}')
        formatc="$yyc-$mmc-$ddc"
        one=$(date -d "$format" '+%s')
        two=$(date -d "$formatc" '+%s')
        difff=$(( (one - two) / (60*60*24) ))
        if [ $difff -le 10 ]
        then
                        echo "The certificate expiry of domain $domain is in $difff days, dropping mail to stakeholders"
                        echo -e "<tr><td>$domain</td><td>$difff</td></tr>" >> mail.html

                else
                        echo "The certificate expiry of domain $domain is in $difff days, no need of mail"
        fi
done < datedomain.txt
else
        echo "The OpenSSL command didn't run as expected and file is not generated, please check"
        exit 1
fi
####### Dropping mail for domains which will expire in 10 days ######  
if [ -e mail.html ]
then
        sed -i '1s/^/<html>\n/' mail.html
        sed -i '1 a\<head>\n' mail.html
        sed -i '2 a\<body Type = text/html>\n' mail.html
        sed -i '3 a\<table border=1 frame=void rules=rows">\n' mail.html
        sed -i '4 a\<tr><th>DOMAIN NAME</th><th>EXPIRY IN</th></tr>' mail.html
        echo "</table>" >> mail.html
        echo "</body>" >> mail.html
        echo "</head>" >> mail.html
        echo "</html>" >> mail.html
        sed -i '3 a\<p>Hello DevOps Team, <br><br>Below is the list of certificates that will expire in 10 or less than 10 days.</p>' mail.html
        sed -i '4 a\<p>Please renew the below list if auto renewal did not happen.</p>' mail.html
        echo "<p style="color:green"><strong>NOTE:This is auto generated email please do not reply</strong></p>" >> mail.html
        cat mail.html | sendemail -f $user -t $to -u $subtwo -s smtp.office365.com:587 -xu $user -xp $pass -v -o tls=auto
else
        echo "All certificates expiry is greater than 10 days so no mail is required"
fi
;;
*)
echo "argument is not passed correctly"
;;

esac

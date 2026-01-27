cd
mkdir .kube
cp /scripts/config .kube/
kubectl config use-context $1
if [ $1 == "tanla-wapp-dev-aks-01-admin" ] || [ $1 == "tanla-dev-ott-ent-cloud-aks-01-admin" ]
then
	kubectl get po -n nats | awk '{print $1}' | grep -v "NAME" >> podnames.txt
	kubectl get po -n redis | awk '{print $1}' | grep -v "NAME" >> podnames.txt
	kubectl get po -n vault | awk '{print $1}' | grep -v "NAME" >> podnames.txt
	kubectl get po -n pg-ha | awk '{print $1}' | grep -v "NAME" >> podnames.txt
elif [  $1 == "nats-hub-aks-01-admin" ] || [ $1 == "tanla-wapp-dev-aks-02-admin" ]
then
	kubectl get po -n nats | awk '{print $1}' | grep -v "NAME" >> podnames.txt
elif [ $1 == "keycloak-server-dev-aks-01" ]
then
	kubectl get po -n keycloak | awk '{print $1}' | grep -v "NAME" >> podnames.txt
else
	echo "New cluster not mentioned in the list, please check"
	exit 1
fi	
while IFS= read -r podname; do
	if [ $1 == "tanla-wapp-dev-aks-01-admin" ] || [ $1 == "tanla-dev-ott-ent-cloud-aks-01-admin" ]
	then
		if [[ "$podname" == *"redis"* ]]
		then
			kubectl exec -it $podname -n redis -- df -kh | awk '{print $5","$6}' >> mountdata.txt
			kubectl exec -it $podname -n nats -- df -kh | awk '{print $5","$6}' >> mountdata.txt
			kubectl exec -it $podname -n vault -- df -kh | awk '{print $5","$6}' >> mountdata.txt
			kubectl exec -it $podname -n pg-ha -- df -kh | awk '{print $5","$6}' >> mountdata.txt
		else
			echo "namespace doesn't exist in core and telco clusters"
		fi
	elif [  $1 == "nats-hub-aks-01-admin" ] || [ $1 == "tanla-wapp-dev-aks-02-admin" ]
	then 
		if [[ "$podname" == *"nats"* ]]
		then
			kubectl exec -it $podname -n nats -- df -kh | awk '{print $5","$6}' >> mountdata.txt
		else
			echo "namespace doesn't exist in hub cluster"
		fi
	elif [ $1 == "keycloak-server-dev-aks-01-admin" ]
	then
		if [[ "$podname" == *"keycloak"* ]]
		then 
			kubectl exec -it $podname -n keycloak -- df -kh | awk '{print $5","$6}' >> mountdata.txt
		else 
			echo "namespace doesn't exist in keycloak cluster"
		fi
	else
		echo "New cluster not mentioned in the array, please check"
		exit 1
	fi
	if [ -e mountdata.txt ]
	then
		while IFS= read -r data; do
			percent=$(echo $data | awk -F ',' '{print $1}')
			numb=$(echo $percent | sed 's/%//g')
			mount=$(echo $data | awk -F ',' '{print $2}')
			if [[ $numb -ge 75 ]]
			then
				echo "The mount $mount is greater than 75%, alerting devops team"
				echo -e "<tr><td>$mount</td><td>$percent</td><td>$podname</td></tr>" >> mail.html
			else
				echo "The mount $mount is less than 75%"
			fi
		done < mountdata.txt
        else
		echo "The file is not present please check"
		exit 1
	fi
done < podnames.txt
if [ -e mail.html ]
then
	sed -i '1s/^/<html>\n/' mail.html
	sed -i '1 a\<head>\n' mail.html
	sed -i '2 a\<body Type = text/html>\n' mail.html
	sed -i '3 a\<table border=1 frame=void rules=rows">\n' mail.html
	sed -i '4 a\<tr><th>MOUNT NAME</th><th>USED PERCENT</th><th>POD NAME</th></tr>' mail.html
	echo "</table>" >> mail.html
	echo "</body>" >> mail.html
	echo "</head>" >> mail.html
	echo "</html>" >> mail.html
	sed -i "3 a\<p>Hello DevOps Team, <br><br><strong>WARNING:</strong> Disk usage for below mount points on cluster $1 is > 75%.</p>" mail.html
	sed -i '4 a\<p>Please increase Disk Size (OR) Purge Unwanted Data.</p>' mail.html
	echo "<p style="color:green"><strong>NOTE: This is auto generated email please do not reply</strong></p>" >> mail.html
	cat mail.html | sendemail -f noreply-wiselyalerts@tanla.com -t devops@tanla.com -cc Pavan.Kuchibhatla@tanla.com -u ALERT : $1 mounts usage warning -s smtp.office365.com:587 -xu noreply-wiselyalerts@tanla.com -xp 'Q&^%RT$#1235' -v -o tls=yes
else
	echo "All mounts are less than 75% so no mail is required"
fi
rm -rf mountdata.txt
rm -rf mail.html
rm -rf podnames.txt
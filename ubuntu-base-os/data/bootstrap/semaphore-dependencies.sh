#!/usr/bin/env bash


function get_dependencies (){
	if [ -z "$1" ];then
		echo -e "\n\n *** ERROR ***: Arguments 1 are empty. You must to give one service to check the service dependency"
		exit
	fi
										
	case $1 in
		"keystone") service_dependency="pxc" service_port="3306";;
		"glance") service_dependency="keystone" service_port="5000";;
		"nova-controller") service_dependency="glance" service_port="9292";;
		"neutron") service_dependency="nova-controller" service_port="8775";;
		"nova-compute") service_dependency="neutron" service_port="9696";;
		*) echo "No Dependency" 
		   exit;;
	esac
}


function get_ip_pods_check (){
	kube_token=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
	
        while true; do
        pods_dependencies=$(curl -sSk -H "Authorization: Bearer $kube_token" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/ | jq -c '.items[] | select(.metadata.name | contains("'$service_dependency'"))' | jq '. | { IP: .status.podIP}' | jq -r .[])
                if [ ! -z "$pods_dependencies" ] && [ "$pods_dependencies" != "null" ];then
                        echo "  FOUND¡¡ Pods dependencies-->>> $pods_dependencies"
                        break
                else
                        echo -e "\n Pods dependencies not found -->>> $pods_dependencies"
                        sleep $(($RANDOM%5))
                fi
        done

	
}

function wait_green (){
	count_num_pods=0
	timeout=0
	num_pods=$(echo "$pods_dependencies" | wc -l)
	
	for pod in $pods_dependencies
	do
		while true; do
		echo -e "\n Waiting Pod with ip ---> $pod ----> and port $service_port"
		nc -vz -w3 $pod $service_port 2>&1 | grep -q succeeded
		if [ $? -eq 0 ]; then
			let count_num_pods=$count_num_pods+1
			if [ $count_num_pods -eq $num_pods ];then
				echo -e "\n ALL CHECKS SUCCEEDED!!  Pod with ip ---> $pod ---> and port $service_port. Checks ok are $count_num_pods and num pod to check is $num_pods"
				return 1
			else
				echo -e "\n ONLY ONE CHECK SUCCEEDED!!  Pod with ip ---> $pod ---> and port $service_port. Checks ok are $count_num_pods and num pod to check is $num_pods . Continue...."
				break
			fi
		fi
		let timeout=$timeout+1
		if [ "$timeout" -eq "600" ];then
			echo -e "\n We have waited 300 seconds to the pods with ip $pod and we havent received succeded OK TOTAL pod with ip $pod. Num PODS chequeados $count_num_pods"
			echo -e "\n CONTINUE......."
			sleep 10
			#return 1
		fi
		
		sleep 1
		
		done
	done
}

function check_dependency (){
	if [ -z "$1" ];then
		echo -e "\n\n *** ERROR ***: Arguments 1 are empty. You must to give one service to check the service dependency"
		return 0
		exit
	fi
	
	get_dependencies "$1"
	get_ip_pods_check 
	wait_green

}



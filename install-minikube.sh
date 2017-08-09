#!/bin/bash

set -e

function install_socat() {
    sudo apt-get install -y socat
}

function install_requirements() {
	cd /tmp
	wget https://storage.googleapis.com/kubernetes-helm/helm-v2.4.1-linux-amd64.tar.gz > /dev/null 2>&1
	tar -xf helm-v2.4.1-linux-amd64.tar.gz
	mv linux-amd64/helm $HOME/bin/helm
	chmod +x $HOME/bin/helm
	sudo apt-get update > /dev/null 2>&1
	sudo apt-get install -y socat build-essential libncurses5-dev libslang2-dev gettext zlib1g-dev libselinux1-dev debhelper lsb-release pkg-config po-debconf autoconf automake autopoint libtool > /dev/null 2>&1
	git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git util-linux > /dev/null 2>&1
	pushd util-linux/
	./autogen.sh > /dev/null 2>&1
	./configure --without-python --disable-all-programs --enable-nsenter > /dev/null 2>&1
	make > /dev/null 2>&1
	sudo mv nsenter /usr/local/bin/nsenter
	popd
}

function install_minikube() {
	cd ~/
	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl
	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
	export MINIKUBE_WANTUPDATENOTIFICATION=false
	export MINIKUBE_WANTREPORTERRORPROMPT=false
	export MINIKUBE_HOME=$HOME
	export CHANGE_MINIKUBE_NONE_USER=true
	mkdir $HOME/.kube || true
	touch $HOME/.kube/config
	export KUBECONFIG=$HOME/.kube/config
}

function wait_for_minikube() {
	set +e
	for i in {1..150} # timeout for 5 minutes
	do
	    ./kubectl get po
	    if [ $? -ne 1 ]; then
	      break
	    fi
	  sleep 2
	done
	set -e
}

install_requirements
install_minikube
sudo -E ./minikube start --vm-driver=none
wait_for_minikube
echo "minikube started"

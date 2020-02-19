.PHONY: keys
keys /tmp/tmate/keys /tmp/tmate/keys/tmate.conf:
	docker build -t keys keys
	mkdir -p /tmp/tmate
	docker run -v /tmp/tmate:/etc/tmate keys
	sudo chown -R ${USER}:${USER} /tmp/tmate
	ls /tmp/tmate/keys

.PHONY: config
config:
	kubectl get secret tmate-keys -o=jsonpath="{.data.tmate\.conf}" | base64 --decode > ~/.tmate.conf
	sed -i "s/localhost/$(shell kubectl get service tmate -o=jsonpath={.status.loadBalancer.ingress[0].ip})/" ~/.tmate.conf
	
.PHONY: secret
secret: /tmp/tmate/keys
	kubectl delete secret tmate-keys 2>/dev/null | true
	kubectl create secret generic tmate-keys --from-file=/tmp/tmate/keys/ssh_host_ed25519_key --from-file=/tmp/tmate/keys/ssh_host_rsa_key --from-file=/tmp/tmate/keys/tmate.conf

.PHONY: deploy
deploy: secret
	kubectl delete -f k8s/deployment.yaml 2>/dev/null | true
	kubectl apply -f k8s/deployment.yaml

.PHONY: service
service: deploy
	kubectl delete -f k8s/service.yaml 2>/dev/null | true
	kubectl apply -f k8s/service.yaml

.PHONY: clean
clean:
	rm -fr /tmp/tmate

.PHONY: clean-remote
	kubectl delete -f k8s/service.yaml	
	kubectl delete -f k8s/deployment.yaml
	kubectl delete secret tmate-keys

.PHONY: clean-all
clean-all:
	$(MAKE) clean
	$(MAKE) clean-service

.PHONY: build
build: check-env-tag
	podman build -t reproducer:$(TAG) .

.PHONY: upload
upload: check-env-tag check-env-server
	podman save localhost/reproducer:$(TAG) > _output/$(TAG).tar
	scp _output/$(TAG).tar core@$(SERVER):

.PHONY: load
load: check-env-tag check-env-server
	ssh core@$(SERVER) "sudo podman load < $(TAG).tar"

.PHONY: build-and-upload-and-load
build-and-upload-and-load: build upload load

.PHONY: build-image
build-image: check-env-image
	podman build -t $(IMAGE) .

.PHONY: push-image
push-image: check-env-image
	podman push $(IMAGE)

.PHONY: build-and-push-image
build-and-push-image: build-image push-image

.PHONY: deploy
deploy: check-env-image
	oc new-project reproducer || oc project reproducer
	oc adm policy add-scc-to-user privileged -z default
	oc adm policy add-role-to-user cluster-reader -z default
	bash privileged.sh reproducer
	oc create configmap --from-file=blue.sh=blue.sh --from-file=red.sh=red.sh entrypoint --from-file=send-sip.sh=send-sip.sh
	cat blue.yaml | sed 's#IMAGE#$(IMAGE)#' | oc apply -f -
	cat red.yaml | sed 's#IMAGE#$(IMAGE)#' | oc apply -f -

.PHONY: undeploy
undeploy:
	oc project default
	oc delete project reproducer

.PHONY: check-env-tag
check-env-tag:
ifndef TAG
	$(error TAG is undefined (e.g. test3))
endif

.PHONY: check-env-image
check-env-image:
ifndef IMAGE
	$(error IMAGE is undefined (e.g. quay.io/akaris/fedora:sip))
endif

.PHONY: check-env-server
check-env-server:
ifndef SERVER
	$(error SERVER is undefined (e.g. 192.168.18.18))
endif

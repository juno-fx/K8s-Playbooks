.PHONY: build-ee ansible-shell

build-ee:
	docker build . -t junoinnovations/ansible-ee:unstable-local --target k8s-playbooks

ansible-shell: build-ee
	docker run -v ${HOME}/.ssh:/root/.ssh:ro -v ${PWD}:/runner:ro -it --rm junoinnovations/ansible-ee:unstable-local

venv/bin/activate:
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt
	venv/bin/ansible-galaxy install -r roles/requirements.yml --force

clean:
	rm -rf venv

build-oneclick:
	sudo rm -rf oneclick-bundle oneclick-oci
	rm juno-oneclick.tar.gz || true
	docker build . -t junoinnovations/oneclick:latest --target oneclick
	skopeo copy docker-daemon:junoinnovations/oneclick:latest oci:oneclick-oci:latest
	umoci unpack --rootless --image oneclick-oci:latest oneclick-bundle
	sudo mv oneclick-bundle/rootfs oneclick-bundle/juno-oneclickfs
	sudo tar -czf juno-oneclick.tar.gz -C oneclick-bundle/ juno-oneclickfs
	sudo chown $(USER) juno-oneclick.tar.gz

lint:
	@docker run --rm -v "${PWD}:/mnt" koalaman/shellcheck:stable .oneclick/juno-oneclick.install .hack/lint-urls.sh
	.hack/lint-urls.sh "${PWD}/README.md"

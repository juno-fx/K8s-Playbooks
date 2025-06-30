.PHONY: build-ee ansible-shell

build-ee:
	docker build . -t junoinnovations/ansible-ee:unstable-local

ansible-shell: build-ee
	docker run -v ${HOME}/.ssh:/root/.ssh:ro -v ${PWD}:/runner:ro -it --rm junoinnovations/ansible-ee:unstable-local

venv/bin/activate:
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt
	venv/bin/ansible-galaxy install -r roles/requirements.yml --force

clean:
	rm -rf venv

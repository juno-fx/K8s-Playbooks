.PHONY: build-ee ansible-shell

build-ee:
	docker build . -t juno-ee:unstable

ansible-shell: build-ee
	docker run -v ${HOME}:/root -v ${PWD}:/runner -it --rm juno-ee:unstable


venv/bin/activate:
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt
	venv/bin/ansible-galaxy install -r roles/requirements.yml --force

clean:
	rm -rf venv

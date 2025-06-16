FROM quay.io/ansible/awx-ee:latest

USER root

COPY roles/requirements.yml /tmp/requirements.yml
COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

RUN ansible-galaxy install -r /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml


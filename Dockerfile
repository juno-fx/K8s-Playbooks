FROM quay.io/ansible/awx-ee:latest AS k8s-playbooks

USER root

COPY roles/requirements.yml /tmp/requirements.yml
COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

RUN ansible-galaxy install -r /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml


FROM k8s-playbooks AS oneclick
COPY .oneclick /oneclick
RUN chmod 755 /oneclick/oneclick.sh
RUN curl -L https://get.k3s.io -o /oneclick/install_files/k3s_install.sh
RUN curl -L https://github.com/k3s-io/k3s/releases/download/v1.33.1%2Bk3s1/k3s -o /oneclick/install_files/k3s

RUN mv /oneclick/juno-oneclick.install /juno-oneclick.install
RUN chmod 755 /juno-oneclick.install

RUN dnf install -y procps-ng util-linux && \
    dnf clean all

ENTRYPOINT ["/oneclick/oneclick.sh"]

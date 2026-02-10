FROM quay.io/ansible/awx-ee:latest AS k8s-playbooks-build

USER root

COPY roles/requirements.yml /tmp/requirements.yml
COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

RUN ansible-galaxy install -r /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml

RUN mkdir /install_files

RUN curl -L https://get.k3s.io -o /install_files/k3s_install.sh
RUN curl -L https://github.com/k3s-io/k3s/releases/download/v1.33.1%2Bk3s1/k3s -o /install_files/k3s
RUN git clone https://github.com/juno-fx/Juno-Bootstrap.git /install_files/Juno-Bootstrap

# Ansible EE brings in a ton of collections by default that are not necessary.
# A great way to trim it down is to run `ncdu` (available on all distros via `apt/dnf/whatever search ncdu`, seeing what takes up space and nuking it.)
RUN rm -rf /usr/local/lib/python3.11/site-packages/azure
RUN rm -rf /usr/local/lib/python3.11/site-packages/openstack
RUN rm -rf /usr/local/lib/python3.11/site-packages/msgraph # interesting...

FROM scratch as k8s-playbooks

COPY --from=k8s-playbooks-build / /


FROM k8s-playbooks AS oneclick
COPY .oneclick /oneclick
RUN chmod 755 /oneclick/oneclick.sh

RUN mv /oneclick/juno-oneclick.install /juno-oneclick.install
RUN chmod 755 /juno-oneclick.install

RUN dnf install -y procps-ng util-linux && \
    dnf clean all

ENTRYPOINT ["/oneclick/oneclick.sh"]

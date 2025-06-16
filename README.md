# K8s-Playbooks

This repository will provide you an easy, out-of-the-box Ansible setup you can use to deploy the Orion and the Juno Platform.
To learn more about how we transform high-performance workstation workflows, visit [Juno Innovations](https://www.juno-innovations.com/)

Reading through below sections will provide you with a step-by-step process of getting up&running.
You can also deploy our workstation platform on existing, out-of-the-box Kubernetes providers by visiting our [Orion Deployment Documentation](https://juno-fx.github.io/Orion-Documentation/installation/prod/nodes/eks/)

The steps below focus on self-managed deployments.

## What this repo contains

We provide both airgapped and non-airgapped installation examples.


It serves as a reference/quickstart point. We encourage you to fork it and adjust it from there to your deployment.
It aligns well with the state-of-the-art practices in the Ansible community
If you are new to Ansible, you can also use it as scaffolding for your other deployments - you can name your fork in a generic way eg. "ansible-deployments"

## Using with existing Ansible workflows

If you already established an Ansible workflow and would like to integrate our deployment into it, that is possible too!
You can find the juno_k3s role: [here](http://github.com/juno-fx/juno_k3s)

It contains a detailed description of available variables, as well as example playbooks.
We encourage using the latest release tag on it - those undergo thorough automated testing that confirms both online&airgap installs work before release.

# How-To


## Prerequisites

The requirements below concern this ansible repo itself. You will also need valid hosts to deploy onto.
You can find requirements for those hosts in the [Orion documentation](https://juno-fx.github.io/Orion-Documentation/installation/pre-reqs/requirements/).

To get running, you must have:
- ssh access as your current user to target hosts
  - if your SSH key is password-protected, you can use `eval \`ssh-agent\` && ssh-add -t 3600` to grant your current session convenient access.
- sudo capability on your target hosts
  - the guides below assume passwordless sudo. If your sudo access is password-protected, you must pass the `-K` flag (see `ansible-playbook --help`)
- either python3.12+ or container tooling (`docker`,`podman`, etc.) on the machine you will perform the deployment from.

Moreover, for airgapped installations:
  - you must have the latest `docker.io/junoinnovations/ansible-ee:stable` image ingested into your airgapped machine
    - we recommend doing it via your internal image registry (ECR/Harbor/etc.)
  - container tooling access (`docker`,`podman` or similar) - it is no longer optional for airgapped installs


There are additional requirements for airgapped installations - details on those will be published soon.


## Forking this repo


Whether you opt for an online or airgapped installation, you should first:


1. Fork this repo. We recommend you make it private.
2. Copy or rename `inventories/example_inventory.yaml` and replace example hosts with your own. Add as many nodes as you'd like.
If you use a cloud provider, you can also look at [dynamic inventories](https://docs.ansible.com/ansible/latest/plugins/inventory.html)

Those exist for most major&small cloud providers and virtualisation platforms - for usage, refer to the upstream Ansible & provider documentation resources.


## Online installation

The steps below assume both your target hosts to deploy Juno onto and your local machine both have internet access.

1. Get your fork of the repo onto the machine you'll execute Ansible from (eg. your laptop or jump host)
2. Pick a method and either run: `docker run -v ${HOME}:/root -v ${PWD}:/runner -it --rm docker.io/junoinnovations/ansible-ee:stable`
or alternatively, setup a python venv with all the dependencies: `make venv/bin/activate`
3. When using a password-protected SSH key, run: `eval \`ssh-agent\` && ssh-add -t 3600"`
3. (only when using the venv): Run `source venv/bin/activate`
4. Run your deployment playbook: `ansible-playbook -u <username> -i inventories/example_inventory.yml playbooks/deploy/juno-k3s.yml`

`<username>` is the user you are ssh-ing to on the target host.
When using password-protected sudo, you can also pass the `-K` flag to get prompted for the credential.

## Airgapped installation


Documentation on generic airgapped installtions is coming soon.
The below outlines only how to run the playbooks and will be updated with prerequisites shortly.


Before performing the steps, replace the download URLs in your fork with ones relevant to your environment. You can find them in `playbooks/deploy/juno-k3s-airgap.yml`
For detailed information on the download URL variables, see the [role README.md](https://github.com/juno-fx/juno_k3s)

If you have multiple environments with distinct variables, consider defining them [in your inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#inheriting-variable-values-group-variables-for-groups-of-groups)

Once that is ready, you can go ahead and deploy:

1. Get the repo onto the host you'll execute ansible from. This would usually be your airgapped workstation/admin host.
2. Get your fork of this repo onto the same host. Open it in your terminal as your working directory (`cd <path>/<to>/<fork>`)
3. Run `docker run -v ${HOME}:/root -v ${PWD}:/runner -it --rm <image>`. Replace `<image>` with the URL in your container image repository.
4. When using a password-protected SSH key, run: `eval \`ssh-agent\` && ssh-add -t 3600"`
5. Run the airgapped playbook via: `ansible-playbook -u <username> -i inventories/example_inventory.yml playbooks/deploy/juno-k3s.yml`

`<username>` is the user you are ssh-ing to on the target host.
When using password-protected sudo, you can also pass the `-K` flag to get prompted for the credential.

## Secret handling

While secret handling will differ from organisation to organisation, we can recommend you two approaches that cover most needs:

- [ansible-vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) - simple, symetric encryption - recommended for smaller orgs and small, fast-moving teams.
- [sops](https://docs.ansible.com/ansible/latest/collections/community/sops/docsite/guide.html) - asymetric encryption, recommended for bigger teams&organisations, as well as cross-team secret management.
  The relevant section of the sops docs is: https://docs.ansible.com/ansible/latest/collections/community/sops/docsite/guide.html#working-with-encrypted-variables


We strongly recommended you avoid storing plaintext secrets in git.
That opens you up to much risk if your repo gets leaked or any of your developer machines is compromised.


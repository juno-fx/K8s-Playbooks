# K8s-Playbooks

This repository will provide you an easy, out-of-the-box Ansible setup you can use to deploy the Orion and the Juno Platform.
To learn more about how we transform high-performance workstation workflows, visit [Juno Innovations](https://www.juno-innovations.com/)

Reading through below sections will provide you with a step-by-step process of getting up&running.
You can also deploy our workstation platform on existing, out-of-the-box Kubernetes providers by visiting our [Orion Deployment Documentation](https://juno-fx.github.io/Orion-Documentation/installation/deployments/)

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
  - you must have the latest `docker.io/junoinnovations/ansible-ee:main` image ingested into your airgapped machine
    - we recommend doing it via your internal image registry (ECR/Harbor/etc.)
  - container tooling access (`docker`,`podman` or similar) - it is no longer optional for airgapped installs


There are additional requirements for airgapped installations - those are the resources you need to make available on your network to get up&running.

You can find them in the [Orion Air-Gapped Install Documentation](https://juno-fx.github.io/Orion-Documentation/installation/special/air-gapped/)
A list of necessary images is listed under the [Image Guide](https://juno-fx.github.io/Orion-Documentation/installation/pre-reqs/images/)


## Forking this repo


Whether you opt for an online or airgapped installation, you should first:


1. Fork this repo. We recommend you make it private.
2. Copy or rename `inventories/example_inventory.yaml` and replace example hosts with your own. Add as many nodes as you'd like.
If you use a cloud provider, you can also look at [dynamic inventories](https://docs.ansible.com/ansible/latest/plugins/inventory.html)

Those exist for most major&small cloud providers and virtualisation platforms - for usage, refer to the upstream Ansible & provider documentation resources.


## Online installation

### Online installation - Configuring the playbook

For the online installation, you only need to adjust:
- the Juno-Bootstrap values. Those control settings such as the URL you use to access the deployments.
  Those are controlled by `juno_bootstrap_chart_values` in `playbooks/deploy/juno-k3s.yml`, where you can also find a practical example. 

  We highlighted the fields  you must define with "(REQUIRED)"
- Mark your nodes as workstation/headless/service nodes in the inventory. By default all control plane hosts you define are "service nodes", while all workers are workstations.

If you'd like to get more in-depth details on those, make sure to check out:
- the [Internet-enabled Installation Guide](https://juno-fx.github.io/Orion-Documentation/installation/juno/)
- the [Juno-Bootstrap repository](https://github.com/juno-fx/Juno-Bootstrap)

### Online installation - Running the playbook

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

### Airgapped installation - Configuring the playbook

Before you run the playbook, you need to pass it details about your environment.
For a full list, refer to [Juno-Bootstrap values](https://github.com/juno-fx/Juno-Bootstrap) and the explanation in the  [airgap install guide](https://juno-fx.github.io/Orion-Documentation/installation/special/air-gapped/) mentioned earlier.

All configuration is passed in as variables. You can see them in the playbook (`playbooks/deploy/juno-k3s-airgap.yml`) under `vars`.
The example `juno_bootstrap_chart_values` vars show what you will need to adjust to get Juno running. We highlighted the fields  you must define with "(REQUIRED)"

Another important configuration is pointing the deployment at your local container image registry. You can either:
- explicitly adjust Juno-Bootstrap values to use your registry and imagePullSecrets. The values enable you to adjust each individual component as well, such as GPU-Operator or Nginx
- use the k3s_registries_yaml var to map docker.io/junoinnovations to a path in your local registry.


You will also need to mark your nodes as workstation/headless/service nodes in the inventory. By default all control plane hosts you define are "service nodes", while all workers are workstations.

If you have multiple environments with distinct variables, consider defining them [in your inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#inheriting-variable-values-group-variables-for-groups-of-groups).
The in-inventory vars are optional and only pointed out to make it easier for you to handle more complex use cases.

### Airgapped installation - Running the playbook

Once you've satisfied the [Prerequisites](#Prerequisites) and configured your deployment across the playbooks/inventories, you can run the playbook following the below:

Before performing the steps, replace the download URLs in your fork with ones relevant to your environment. You can find them in `playbooks/deploy/juno-k3s-airgap.yml`
For detailed information on the download URL variables, see the [role README.md](https://github.com/juno-fx/juno_k3s)


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



## "oneclick" installer

This repo also contains our oneclick installer.
Detailed documentation is coming soon for it.

### "oneclick" installer - Attributions&Licensing

We repackage parts of the k3s project, which is distributed under the [Apache licnese](https://github.com/k3s-io/k3s/blob/master/LICENSE)
On top of sharing the license, we'd also like to ackowneldge the great work the project has done in making Kubernetes very accessible - it's thanks to their hard work we can provide you with an installer for a simple, out-of-the-box distribution.

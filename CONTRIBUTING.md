This is developer-facing oneclick installer documentation.
For user-facing docs, see: https://juno-fx.github.io/Orion-Documentation/


## oneclick installer


The oneclick installer relies on a simple chroot to provide all Ansible&k3s dependencies.
The aim is to make it easy to build for both standard and normal environments.


To test, bring up a VM, copy in a juno-bootstrap values file, copy in and unpack the tar produced by `build-oneshot` and:

```
./juno-oneclickfs/juno-oneclick.install /tmp/values.yml
```

This is all you need. Ansible will then provision the host as a controlplane node and bootstrap Juno onto it.


### oneclick installer - how does this work?

We simply take the container image, unpack it into a tarball and ship it.

We then chroot (change the root filesystem) to our tarball with pre-built ansible dependencies.

Ansible then connects back to our host via the same chroot mechanism (see inventory). It can then provision it and "copy in" the depencecies.

Ansible sees the world from within the prebuilt tarball, where it can access all libraries and dependencies with no interferance from the host OS.
The host OS is simply taken in from its filesystem, together with all the messaging buses required to make systemd work.

We achieve that through simple bind mounts in the install script.

The reason we bind mount /proc is to  share the exact same OS context - including all of its mountpoints correctly preserved.

This is the same mechanisms that Linux uses for running containers, with few minor differences.
We use less isolation - chroot is not the same call as the more secure `pivot_root` that real runtimes call, but it suffices for our needs.

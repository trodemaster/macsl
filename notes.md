


You can pass in the credentials via environment variables when you create the VM, e.g.
$ limactl start alpine --set '.env.SECRET="KEY"'
…
$ limactl shell alpine printenv SECRET
KEY
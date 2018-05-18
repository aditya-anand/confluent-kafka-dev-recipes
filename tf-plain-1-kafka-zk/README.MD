#Simple Kafka w / Terraform

Create 1 broker, 1 zookeeper node with TF and Docker on local host.

**For OS X use:**

```bash
tf init
tf apply -var "hostname=`hostname`" -var cp-version=4.1.0 -auto-approve
```


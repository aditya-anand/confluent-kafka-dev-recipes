# Single Node Kafka w/ SASL_PLAINTEXT authentication + Simple ACLs using Terraform

Create 1 broker, 1 zookeeper node with TF and Docker on local host.
The broker uses SASL_PLAINTEXT for security. Server jaas is in the module folder `kafka_server_jaas.conf`

**For OS X use:**

```bash
# socat is required to expose docker api over tcp socket
docker run --name docker-socat -d -v /var/run/docker.sock:/var/run/docker.sock -p 2376:2375 bobrik/socat TCP4-LISTEN:2375,fork,reuseaddr UNIX-CONNECT:/var/run/docker.sock
tf init
tf apply -auto-approve -var "hostname=`hostname`" -var cp-version=4.1.0
```

#Troubleshooting tips

## Kafka Docker-image Interactive Mode

You can launch the kafka docker container with bash using the following command
```bash
docker run \
--rm \
--name kafka-check \
-e "KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN" \
-e "KAFKA_SECURITY_INTER_BROKER_PROTOCOL=SASL_PLAINTEXT" \
-e "KAFKA_BROKER_ID=2" \
-e "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1" \
-e "KAFKA_SASL_ENABLED_MECHANISMS=PLAIN" \
-e "KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/secrets/kafka_server_jaas.conf" \
-e "KAFKA_AUTHORIZER_CLASS_NAME=kafka.security.auth.SimpleAclAuthorizer" \
-e "KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND=false" \
-e "KAFKA_SUPER_USERS=User:admin" \
-e "KAFKA_ADVERTISED_LISTENERS=SASL_PLAINTEXT://:9092" \
-e "KAFKA_ZOOKEEPER_CONNECT=biggie.fios-router.home:2181" \
-p 9093:9092 \
-v /Users/adityaanand/IdeaProjects/confluent-kafka-dev-recipes/tf-sasl-plaintext-1-kafka-zk/ensure-skip-zk-check:/etc/confluent/docker/ensure \
-v /Users/adityaanand/IdeaProjects/confluent-kafka-dev-recipes/tf-sasl-plaintext-1-kafka-zk:/etc/kafka/secrets \
-it confluentinc/cp-kafka:4.1.0 /bin/bash
```

This can be useful if Kafka fails to start for any reason.
The entry-point for the container when lauched normally is `/etc/confluent/docker/run`

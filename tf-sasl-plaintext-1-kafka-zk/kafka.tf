variable "hostname" {
  description = "docker hostname, required for OS X"
  default = "localhost"
}

variable "cp-version" {
  description = "Version of confluent platform to deploy"
  default = "3.3.1"
}

variable "zk-port" {
  description = "port where zk listens."
  default = 2181
}


provider "docker" {
  host = "tcp://${var.hostname}:2376/"
}

# Create a container
resource "docker_container" "zk-sasl-1" {
  image = "${docker_image.cp-zk-img.latest}"
  name = "zk-sasl-1"
  env = [
    "ZOOKEEPER_CLIENT_PORT=${var.zk-port}",
    "ZOOKEEPER_TICK_TIME=2000"
  ]
  ports {
    internal = "${var.zk-port}",
    external = "${var.zk-port}"
  }
}

resource "docker_container" "kafka-sasl-1" {
  image = "${docker_image.cp-kafka-img.latest}"
  name = "kafka-sasl-1"
  env = [
    "DEPENDS_ON=${docker_container.zk-sasl-1.name}",
    "KAFKA_BROKER_ID=1",
    "KAFKA_AUTHORIZER_CLASS_NAME=kafka.security.auth.SimpleAclAuthorizer",
    "KAFKA_SUPER_USERS=User:admin",
    "KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND=false",
    "KAFKA_SECURITY_INTER_BROKER_PROTOCOL=SASL_PLAINTEXT",
    "KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN",
    "KAFKA_SASL_ENABLED_MECHANISMS=PLAIN",
    "KAFKA_ADVERTISED_LISTENERS=SASL_PLAINTEXT://:9092",
    "KAFKA_ZOOKEEPER_CONNECT=${var.hostname}:${var.zk-port}",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/secrets/kafka_server_jaas.conf"
  ]
  volumes {
    host_path = "${path.module}"
    container_path = "/etc/kafka/secrets"
  }
  volumes {
    host_path = "${path.module}/ensure-skip-zk-check"
    container_path = "/etc/confluent/docker/ensure"
  }
  ports {
    internal = 9092,
    external = 9092
  }
}


resource "docker_image" "cp-zk-img" {
  name = "confluentinc/cp-zookeeper:${var.cp-version}"
  keep_locally = true
}

resource "docker_image" "cp-kafka-img" {
  name = "confluentinc/cp-kafka:${var.cp-version}"
  keep_locally = true
}
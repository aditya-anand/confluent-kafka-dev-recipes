variable "hostname" {
  description = "docker hostname, required for OS X"
  default = "localhost"
}

variable "cp-version" {
  description = "Version of confluent platform to deploy"
  default = "3.3.1"
}

provider "docker" {
  host = "tcp://${var.hostname}:2376/"
}

# Create a container
resource "docker_container" "zk1" {
  image = "${docker_image.cp-zk-img.latest}"
  name = "zk1"
  env = [
    "ZOOKEEPER_CLIENT_PORT=2181",
    "ZOOKEEPER_TICK_TIME=2000"
  ]
  ports {
    internal = 2181,
    external = 2181
  }
}

resource "docker_container" "kafka1" {
  image = "${docker_image.cp-kafka-img.latest}"
  name = "kafka1"
  env = [
    "KAFKA_BROKER_ID=1",
    "KAFKA_ZOOKEEPER_CONNECT=${var.hostname}:2181",
    "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://:9092",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1"
  ]
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

output "hostname" {
  value = "${var.hostname}"
}
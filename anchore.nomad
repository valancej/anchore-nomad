
job "anchore" {
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  group "anchore" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 300
    }

    task "anchore" {
      driver = "docker"
      config {
        image = "anchore/anchore-engine:latest"
        port_map = {
          anchore = 8228
        }
        volumes = [
          "/home/ubuntu/aevolume/config.yaml:/config/config.yaml",
        ]
      }

      resources {
        cpu    = 3000 
        memory = 3000
        network {
          mbits = 10
          port "anchore" {
            static = 8228
          }
        }
      }

      service {
        name = "anchore-engine"
        tags = ["global", "anchore"]
        port = "anchore"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

[![](https://badge.imagelayers.io/jonnybgod/filebeat:latest.svg)](https://imagelayers.io/?images=jonnybgod/filebeat:latest)

# What is Filebeat?
Filebeat is a lightweight, open source shipper for log file data. As the next-generation Logstash Forwarder, Filebeat tails logs and quickly sends this information to Logstash for further parsing and enrichment.

![alt text](https://static-www.elastic.co/assets/blta28996a125bb8b42/packetbeat-fish-nodes-bkgd.png?q=755 "Filebeat logo")

> https://www.elastic.co/products/beats/filebeat


# Why this image?

This image uses the Docker API to collect the logs of all the running containers on the same machine and ship them to a Logstash. No need to install Filebeat manually on your host or inside your images. Just use this image to create a container that's going to handle everything for you :-)


# How to use this image
Build with:

```bash
docker build -t filebeat .
```

Start Filebeat as follows:

```bash
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e LOGSTASH_HOST=monitoring.xyz -e LOGSTASH_PORT=5044 \
  filebeat
```

Two environment variables are needed:
* `LOGSTASH_HOST`: to specify on which server runs your Logstash
* `LOGSTASH_PORT`: to specify on which port listens your Logstash for beats inputs

Optional variables:
* `INDEX`: to specify the elasticsearch index (default: filebeat) 
* `LOG_LEVEL`: to specify the log level (default: error) 
* `SHIPPER_NAME`: to specify the Filebeat shipper name (default: the container ID) 
* `SHIPPER_TAGS`: to specify the Filebeat shipper tags

The docker-compose service definition should look as follows:
```yalm
filebeat:
  image: jonnybgod/filebeat
  restart: unless-stopped
  volumes:
   - /var/run/docker.sock:/var/run/docker.sock
  environment:
   - LOGSTASH_HOST=monitoring.xyz
   - LOGSTASH_PORT=5000
```


# Logstash configuration:

Configure the Beats input plugin as follows:

```
input {
  beats {
    port => 5044
  }
}
```

In order to have a `containerName` field and a cleaned `message` field, you have to declare the following filter:

```
filter {

  if [type] == "filebeat-docker-logs" {

    grok {
      match => { 
        "message" => "\[%{WORD:containerName}\] (\[%{WORD:logtype}\])? %{TIMESTAMP_ISO8601:time} %{GREEDYDATA:message_remainder}"
      }
    }
    
    date { 
      match => [ "time", "ISO8601"]
    }

    mutate {
      replace => { "message" => "%{message_remainder}" }
    }
    
    mutate {
      remove_field => [ "message_remainder" ]
    }

  }

}
```
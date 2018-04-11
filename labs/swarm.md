 
# Lab 3: Setting Up a Docker EE Basic

**Goal:** Create a Docker EE Basic Swarm Cluster configured with recommended logging and device-mapper configuration. 

1. Install Docker EE on the two worker nodes using the following [docs](https://docs.docker.com/engine/installation/)
2. Set up a 5-node Swarm with 3-managers and 2 workers nodes.
3. Set up Docker cluster logging using ELK (Elasticsearch, Logstash, and Kibana)
	
	- ELK is already set up for you on the `services` node. All you need is to set up Docker daemon logging configuration to default to using `journald`. The reason we're doing this is to ensure that you can have a local copy of the logs to be able to use `docker logs` and `docker service logs`. 
	- This is the recommended logging configuration to place in`/etc/docker/daemon.json`:


			{
			  "log-driver": "journald",
			  "log-level": "debug",
			  "log-opts": {
			    "tag":"{{.ImageName}}/{{.Name}}/{{.ID}}"
			  }
			}

	- Make sure you restart the Docker daemon after you change these configs.
	- Stream all Docker logs to ELK. This is done using a tool called [journalbeat](https://github.com/mheese/journalbeat). A modified version of it that we're using to work with Docker can be found [here](https://github.com/nicolaka/journalbeat).
	- We will run `journalbeat` as a `global` service in our Docker cluster. This requires that you configure Step 2 before hand. 
	- On one of the Docker manager nodes run the following:
	```
	$ git clone https://github.com/nicolaka/elk-dee.git
	$ cd elk-dee
	$ export LOGSTASH_HOST=<SERVICE_NODE_PRIVATE_IP>
	$ docker stack deploy -c journalbeat-docker-compose.yml journalbeat
	```
	- Proceed to access Kibana at `http://<SERVICES_PUBLIC_IP_ADDRESS>:5601` and confirm that you can see the logs. 

5. Finally, confirm that you have logging working, full Swarm setup and logging configured.

# Lab 4: Install and configure highly available Docker EE Standard Cluster


 **Goal:**  Install and configure highly available Docker EE Standard (UCP) cluster using Docker recommended best practices.
  
1. Install UCP version `2.2.2` on top of existing swarm cluster using the [docs](https://docs.docker.com/datacenter/ucp/2.2/guides/admin/install/).
	- You can perform this operation from any manager node. 
	- During the installation process, you will be asked to enter an admin username and password. You can choose any username and password.
	- UCP needs to listen on non-standard port `12390` (you need to use `--controller-port 12390` during the installation process )
	- Make sure you add the correct SAN. The SAN should be the CNAME DNS for your UCP-LB (e.g `--san team1.ucp-lb.dockerpartners.org`).

2. Access UCP using the public IP of any of the managers node after installation is complete by going to `https://<MANAGER-PUBLIC-IP>:12390`
3. Install your Docker EE license. 
4. Generate and Install Let's Encrypt certificates for UCP domain. Let's Encrypt is a free service that provides valid SSL certificates.

	* SSH into the `ucp-lb` node.
	* Retrieve the node's proper DNS CNAME record that's assigned to it. 
	* You can use Let's Encrypt to generate certs. Make sure you substitute YOUR-EMAIL and UCP_LB_CNAME variables:
		
		```
			 docker run --rm \
		    -p 443:443 -p 80:80 --name letsencrypt \
		    -v "/etc/letsencrypt:/etc/letsencrypt" \
		    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
		    certbot/certbot:latest \
		    certonly -n -m $YOUR_EMAIL -d $UCP_LB_CNAME --standalone --agree-tos
		```
		
	* This operation will generate the SSL certs for the UCP domain.  
	* Under `/etc/letsencrypt/live/$UCP_LB_CNAME` you'll find the following:
		- cert.pem: server certificate only.
		- chain.pem: root and intermediate certificates only.
		- fullchain.pem: combination of server, root and intermediate certificates (replaces cert.pem and chain.pem).
		- privkey.pem: private key (do not share this with anyone!).
7. Deploy HAPROXY on UCP LB node (`ucp-lb`)
	* SSH to the `ucp-lb` node.
	* HAPROXY needs to listen on ports 80/443 and forward to non-standard port of UCP. Please use port *12390* as the backend port. 
	* Copy the `ucp-haproxy.cfg` file located in the main directory [here](../ucp-haproxy.cfg) in this directory to the `ucp-lb` node. E.g., login to the `ucp-lb` node, then:
	
	```
	curl -o ucp-haproxy.cfg https://github.com/docker-partners/mta-dac/raw/master/ucp-haproxy.cfg
	```
	
	* Still on the `ucp-lb` node, reconfigure `ucp-haproxy.cfg` with your setup's info by substituting `$MANAGER_IP` in the config file with the PRIVATE IP address of the three UCP managers. Then launch the haproxy container using the following command:
	
	```
	docker run -d -p 443:443 -p 8181:8181 --restart=unless-stopped --name ucp-lb -v ${PWD}/ucp-haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:1.7-alpine haproxy -d -f /usr/local/etc/haproxy/haproxy.cfg
	```	
	 
8. Go the UCP portal using the `ucp-lb` CNAME ( e.g `https://ucp-lb-cname` ) then navigate to top left corner, click on the logged-in username > **Admin Settings** > **Certificates** and install the generated certs for UCP. You need to use `fullchain.pem` for Server Cert, `privkey.pem` for the Private Key, and [this](https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt) cert as the CA Root Cert. 

9. Set up HRM on standard ports 80 and 443 using the following [documentation](https://docs.docker.com/datacenter/ucp/2.2/guides/admin/configure/use-domain-names-to-access-services/)
10. Set up node labels using the following instructions and [documentation](https://docs.docker.com/engine/swarm/manage-nodes/#change-node-availability)
      - Label the one worker node as `environment=staging` and the other as `environment=production`
      - Label the two worker nodes with their availability zones ( you can find an instance availability zone using `curl http://169.254.169.254/latest/meta-data/placement/availability-zone`). e.g `zone=us-west-2a`
11. Perform a UCP backup using this [documentation](https://docs.docker.com/datacenter/ucp/2.1/guides/admin/backups-and-disaster-recovery/#backup-command)



# Sample App Deployment Instructions

## About

These instructions were provided by the Application Subject Matter Expert (SME) along with some high level details about their environment

## App Architecture

2-tier architecture:

* App Tier
  * Tomcat 9
  * Spring MVC
  * Simple CRUD App
* Database Tier
  * MySQL

## App Infrastructure

OS: Ubuntu 16.04

* App Tier
  * 3 nodes
* Database Tier
  * 1 node

## Source Code

While you don't have to build from source code, the app source and configuration is [here](app_src).

## Application Deployment Instructions

### 1. Install Java

```bash
#!/bin/bash

$ sudo apt-get update
```

```bash
#!/bin/bash

$ sudo apt-get install default-jdk
```

### 2. Create Tomcat User

```bash
#!/bin/bash

$ sudo useradd -r tomcat9 --shell /bin/false
```

### 3. Install Tomcat

```bash
#!/bin/bash

$ cd /opt
$ sudo wget http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.0.M22/bin/apache-tomcat-9.0.0.M22.tar.gz
```

```bash
#!/bin/bash

$ sudo tar -zxf apache-tomcat-9.0.0.M22.tar.gz
```

```bash
#!/bin/bash

$ sudo ln -s apache-tomcat-9.0.0.M22 tomcat
$ sudo chown -hR tomcat9: tomcat apache-tomcat-9.0.0.M22
```

```bash
#!/bin/bash

$ sudo nano /etc/systemd/system/tomcat.service
```

add the following to the tomcat.service file:

```bash
#!/bin/bash

[Unit]
Description=Tomcat9
After=network.target

[Service]
Type=forking
User=tomcat9
Group=tomcat9

Environment=CATALINA_PID=/opt/tomcat/tomcat9.pid
Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment="CATALINA_OPTS=-Xms512m -Xmx512m"
Environment="JAVA_OPTS=-Dfile.encoding=UTF-8 -Dnet.sf.ehcache.skipUpdateCheck=true -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

```bash
#!/bin/bash


$ cd ~
```

### 4. Enable Tomcat

```bash
#!/bin/bash

$ sudo systemctl daemon-reload
$ sudo systemctl enable tomcat

```

### 5. Install MySQL

```bash
#!/bin/bash

$ sudo apt-get install mysql-server
```

### 6. Deploy App

```bash
#!/bin/bash

$ sudo rm -r /opt/tomcat/webapps/ROOT
```

```bash
#!/bin/bash

$ sudo wget --quiet https://broyal.blob.core.windows.net/mta/mta-java.war
```

```bash
#!/bin/bash

$ sudo cp mta-java.war /opt/tomcat/webapps/ROOT.war
```

```bash
#!/bin/bash

$ sudo systemctl start tomcat
$ sudo systemctl status tomcat
```

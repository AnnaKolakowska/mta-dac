# MTA In Practice

The purpose of this lab is to get a foundational understanding of the key processes and considerations of an MTA POC.  This lab is a group exercise and will run participants through the major components of an MTA POC - starting from understanding the target application to deployment of a containerized version of the app to Docker.

During this lab, you and your team members will act as the **Solution Architect** and **Application Engineer** roles to achieve the objectives of stage of the lab.  You'll also be working with your **Customer Application SME** - the instructor - to help you to understand the target MTA application.

## Team Size

2 per team

## Objective

The objective of this lab is simple.  Use all the tools and knowledge at your disposal to **containerize** and **deploy** the customer application to Docker Enterprise, showcasing Docker EE capabilities like:

* Stacks
* Service Updates
* Service Scaling
* Healthchecks
* Image Lifecycle (Pull/Push)
* Image Scanning

### Quick Resources

* [docs.docker.com](https://docs.docker.com)
* [success.docker.com](https://success.docker.com)

### Getting Started

This lab is broken down into tasks that mirror the most critical portions of the MTA POC process.  While there are some commands called out, this lab is designed to **_NOT_** provide all the answers. It's up to you to use you knowlege of Docker EE to `Modernize the Traditional App`.  If your team gets stuck, **RAISE YOUR HANDS** and your instructor will point you in the right direction.

**NOTE:** _Places where you see <>, assume you need to replace these with appropriate values

### Tasks

* [Prerequisites](#prerequisites)
* [Task 1: Understand Target App](#task-1-understand-target-app)
* [Task 2: App Containerization](#task-2-app-containerization)
  * [Task 2.1: Create App Dockerfile](#task-21-create-app-dockerfile)
  * [Task 2.2: Run and Validate App Functionality](#task-22-run-and-validate-app-functionality)
* [Task 3: Composition & Configuration](#task-2-composition--configuration)
  * [Task 3.1: Compose Application](#task-31-compose-application)
* [Task 4: Deploy to Docker EE](#task-4-deploy-to-docker-ee)
  * [Task 4.1: Deploy Application as Stack](#task-41-deploy-application-as-stack)
  * [Task 4.2: Scale Service](#task-42-scale-service)
  * [Task 4.3: Update Service](#task-43-update-service)

### Prerequisites

You'll need a Windows/Mac laptop with the configurations below:

* Laptop w/ Virtualization Enabled
  * Docker for Mac / Docker for Windows
  * VirtualBox (optional)
  * Vagrant (optional)
  * Text Editor (VSCode, Sublime, etc.)

### Task 1: Understand Target App

Before we can do anything, we need to build a foundational understanding of our target application.  The following has been provided by the customer:

* [Architecture + App Deployment Instructions](mta-in-practice/app_deployment.md)
* [App Source Code](mta-in-practice/app_src)
* [Working Virtual Machine](mta-in-practice/app_vm)

Use these resources, ensuring your team understands the app's...

✔︎ Deployment Process

✔︎ Required Infrastructure

✔︎ Dependencies

✔︎ Successful Functionality

**NOTE: Don't forget the database**
If necessary, deploy the apps dependencies including databases on the same machine on which you'll be building your container.  While deployments should use dedicated VMs, for the purposes of this lab, this can be deployed as a container.

### Task 2: App Containerization

In this task, we'll start by containerizing our target application using the information we gathered from the previous task.

#### Task 2.1: Create App Dockerfile

Create a root directory for the lab

```bash
#!/bin/bash

$ mkdir mta-in-practice
$ cd mta-in-practice
```

Create an application directory in the root

```bash
#!/bin/bash

$ mkdir app
$ cd app
```

Create a web component directory and create a blank `Dockerfile`

```bash
#!/bin/bash

$ mkdir web
$ cd web
$ touch Dockerfile
```

Open the `Dockerfile` in your preferred text editor and begin building it out using the following decisions as a guide

**CONSIDERATION 1:** What's the most appropriate base image?

**CONSIDERATION 2:** What (if any) cleanup is required before copying in our compiled application?

**CONSIDERATION 3:** Given we've be provided compiled code, what's the most efficient way to get it into the image?

**CONSIDERATION 4:** Are there scripts in the src that could be helpful when starting/running this app?

**CONSIDERATION 5:** Is there an opportunity to run a healthcheck against the app?

**CONSIDERATION 6:** How is this application being exposed to users?

**CONSIDERATION 7:** How do we most appropriately start the application at runtime?

Once you feel you have a working Dockerfile, let's build it.

```bash
#!/bin/bash

$ docker build -t atsea_app:1 .
```

If your Dockerfile successfully built, proceed to the next **Task**.  If it failed, make modifications to the configuration until you're able to get a successful build.  Remember the [Application Architecture and Deployment Doc](mta-in-practice/app_deployment.md) can be very useful when creating a `Dockerfile`.

#### Task 2.2: Run and Validate App Functionality

Now that you have an image, let's use it to create our app container.

```bash
#!/bin/bash

$ docker run <your options> atsea_app:1
```

Browse the application...checking that the app functions as expected.  If the app isn't functioning, review [Task 2.1: Create App Dockerfile](#task-21-create-app-dockerfile), paying particular attention to each of the considerations.

If you're satisfied with the functionality of your app, proceed to the next **Task**

### Task 3: Composition & Configuration

Now that you have a single container working, we need to add the image to a new compose file that includes both the application and the database.

#### Task 3.1: Compose Application

Let's get started by creating a new, clean docker-compose.yml file

```bash
#!/bin/bash

$ cd ..
$ touch docker-compose.yml
```

By this point, your file structure should look something like this:

```filesystem
⎣ mta-team-lab
    - docker-compose.yml
    ⎣ web
        - Dockerfile
```

Open your docker-compose.yml file with your preferred text editor and start building it out use the following considerations:

**CONSIDERATION 1:** What's the appropriate version of our docker-compose.yml file?

**CONSIDERATION 2:** What services do I need to represent in my compose-file based on the application architecture?

**CONSIDERATION 3:** What networks do I need to join my services to?  How do my services communicate to one another?

**CONSIDERATION 4:** How can I take advantage of environment variables for common configuartions within my file (e.g. HUB username)?

Remember to refer to the [Application Architecture and Deployment Doc](mta-in-practice/app_deployment.md) for architecture guidance

To validate the functionality on a single node without swarm enabled, use

```bash
#!/bin/bash

$ docker-build
$ docker-compose up -d
```

***HINT:** Remember you can specific both you fully qualified image name and the relative path to your Dockerfile.  This let's you correctly build and tag all your images in a single command.

### Task 4: Deploy to Docker EE

Once your application is working within compose it's time to deploy it as a stack to your Docker EE cluster

#### Task 4.1: Deploy Application as Stack

1. Deploy your images to HUB

**NOTE: Be sure you're labeling your images with your HUB username***

```bash
#!/bin/bash

$ docker login
$ docker push <image_name>
```

1. Use docker-compose.yml file generated from **Task 2** to deploy a stack

```bash
#!/bin/bash

$ docker stack deploy -c docker-compose.yml atsea
```

#### Task 4.2: Scale Service

1. While on the same node that you just deployed your stack to, scale app service from 1 to 3 containers

```bash
#!/bin/bash

$ docker service scale <app_service_name>=3
```

1. Validate that service has scaled

```bash
#!/bin/bash

$ docker service ps <service_name>
```

#### Task 4.3: Update Service

1. Build new version of you image with the `tag` as `2` instead of `1` (e.g. `<hub_username>/atsea_app:2`)

1. Push new image to HUB

```bash
#!/bin/bash

$ docker push <image_name>
```

1. Update service

```bash
#!/bin/bash

$ docker service update --image <hub_username>/atsea_app:2 <service_name>
```

### Team Feeling Confident?  Show it off

Notify the instructor if you've completed these tasks. Time permitting you may have an opportunity to show off your app to the group.
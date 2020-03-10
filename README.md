## Dana's Reverie Homework

This is the code associated with the [Reverie Labs Infrastructure Engineer Coding Challenge
](https://docs.google.com/document/d/1vDSAmYqN1vCqNFWLdVUkOufRYRE97uT59Lgx-sP1xy4/edit?usp=sharing).

### Installation
#### Setup AWS CLI

First install the latest version of the AWS CLI
(I used aws-cli/2.0.0)

```bash
# create a new profile in your ~/.aws/credentials
# (you can use any name, but note it for later)
aws configure --profile reverie-homework
```

#### Setup Terraform

First install the latest version of Terraform
(I used v0.12.23)

```bash
cd terraform
terraform init
```

I like using a `tfvars` file:
```bash
cat variables.tfvars
# this is where you put specify things specific to your setup
region = "us-east-1"
# this must match the profile in your ~/.aws/credentials
profile = "reverie-homework"
application_environment = "test"
```

You then add `-var-file variables.tfvars` to your terraform commands and save some time.

#### Setup Kubernetes

First install kubectl
(I used 1.17.3)

Next you will have to do an initial `terraform apply` (see the next steps)


### Running Terraform

Create a plan:

```bash
cd terraform
terraform plan -out reverie-homework.plan
```

Now look over the output, make sure it looks sane.
If everything looks good, we can apply the plan:

```bash
# this may take a long time, if no EKS cluster exists already
terraform apply reverie-homework.plan
```

At the end of the successful run you will see some useful outputs:
* the location of the Docker container registry (used later)
* a YAML file that can be used to configure `kubectl` (though it is easier to use the AWSCLI, see the next section)


### Working with Kubernetes

#### Configuring kubectl

You can use [eks update-kubeconfig](https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html) to install the config for you:

```bash
# note you may need --region and --profile if you have many AWS profiles
aws eks update-kubeconfig --name reverie-hw
```

#### Deploying web app

Now that kubectl is configured, we can use the templates in the `k8s` directory:

```bash
kubectl apply -f k8s/web-app.yaml
# create an ELB for the app:
kubectl expose deployment hello-world --type=LoadBalancer --name=web-app
# get the ELB address (you will need the port, too):
kubectl get services web-app
# test it
curl <address>:<port>
```
If everything worked as expected, you should see "Hello, Kubernetes!"


#### Building the ping-server

The ping server is designed to periodically ping the web app and record its response.
We must build a Docker image, and push it to the container registry.

```bash
cd docker/ping-server
docker build -t reverie/ping-server .
# test it locally
docker run -t reverie/ping-server:latest
```

#### Deploying the ping-server

Find the container registry URL from the terraform output (it should look something like 123456789.dkr.ecr.REGION.amazonaws.com/ENV_registry).

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <repository URL>
docker tag reverie/ping-server:latest <repository URL>/ping-server
docker push <repository URL>/ping-server
```

Now that the container is pushed up to the registry, we can deploy it:

```bash
kubectl apply -f k8s/ping-server.yaml
```

With that, we should be good!


### Network Security Choices

By using EKS, my network security needs were straightforward from the start.
I opened the [bare minimum](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) ports for EKS to function, which keeps the surface area for attack pretty low.
I opened EKS console access only to the IP of my workstation (in reality, the IP of whoever is running the terraform commands).

The VPCs I created are minimal, with only a single Internet Gateway for access to the EKS cluster.
Poking a hole for the web app is done using an ELB with minimal settings.

The S3 bucket only allows allows access from the EKS node group servers.
Depending on your outlook, this is tight security or it's loose... as the number of services on the cluser goes up, those services will have access to the bucket, and a new method for locking down the bucket should be chosen.
(I like using IAM roles attached to instances for this because we don't need to handle AWS access keys, the right boxes "Just Can" access the bucket).

The lack of AWS service/user accounts is pretty egregious... right now the only account is the AWS Root Account.
This is bad practice and would be one of the first things to fix if we were to go live with this stack.


### Things to Improve

While I covered a lot of ground and went a little beyond the prompt, there's always more to be done :)

* Use Route53 to create friendly names
* Use those friendly names to replace hardcoding
* Create account(s) with limited permissions instead of using Root Account
* Destroy the stack and re-create it a few times to find more things to automate
* Create a second cluster in "VPC 2" to run ping-server (as was requested in the prompt)


# two_vpc_different_region_connection

# What this code does:
This repository contains terraform code that will create two EC2 instances in different VPCs and located in different regions that will be able to communicate with between each other over their private IPs.

# Why use this repo:
This repo will help with understanding how to use connection peering between two VPCs in AWS and also how to automate the creation of the needed infrastructure with Terraform.

# How to use this repo:
This how-to will focused on using MacOS, these instructions may vary between different OSs.

1. To use this repo you need to have Terraform installed on your local machine. You can install it with from [here](https://www.terraform.io/downloads.html):

2. Clone this repo locally so you are able to work with it.

```
git clone git@github.com:yordanivh/two_vpc_different_region_connection.git
```
3. You need to have you AWS credentials set up before starting. You can read up [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) on how to authenticate to AWS when using Terraform. I would suggest using environment variables because it is the easiest way for this example.

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```

4. In the code intself for the two ec2 instances I have attached key pairs. Those need to created beforehand in each of the two region so that you are able to login to the created EC2s.If you choose to use your own just change the names in the code. For the purpose of this demonstration I have decided to go with the `us-east-1` and `us-east-2` regions. Feel free to change them if you feel suited.

5. When you are ready with the previos steps you can start deploying the infrastructure.

6.
```
terraform init
```
You should get this output:

```
❯ terraform init

Initializing the backend...

Initializing provider plugins...
- Using previously-installed hashicorp/aws v3.16.0

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/aws: version = "~> 3.16.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

7.Validate that there are no issues with the configuration
```
terraform validate
```
```
❯ terraform validate
Success! The configuration is valid.
```

8. Run `terraform plan` to see what will be deployed

9. Run `terraform apply -auto-approve` to deploy the infrastructure. You will notice in the end there are two outputs.`public_ip_to_login` will be IP that you will be able to login from your local computer.This is the ec2 instance deployed in `us-east-1`.`ip_to_try_to_ping` is the private IP of the second EC2 instance in `us-east-2`. If you ping that IP from the first ec2 instance that will prove we have a peering connection between two VPCs in different regions

```
❯ terraform apply -auto-approve
aws_vpc.vpc_east_1: Creating...
aws_vpc.vpc_east_2: Creating...
aws_vpc.vpc_east_1: Creation complete after 7s [id=vpc-0065405c7c825e204]
aws_internet_gateway.east1: Creating...
aws_subnet.subnet_east_1: Creating...
aws_security_group.ec2_east_1: Creating...
aws_vpc.vpc_east_2: Creation complete after 7s [id=vpc-09af9e75dba0c62ea]
aws_subnet.subnet_east_2: Creating...
aws_vpc_peering_connection.peer: Creating...
aws_security_group.ec2_east_2: Creating...
aws_subnet.subnet_east_2: Creation complete after 2s [id=subnet-02b9ef79066512299]
aws_vpc_peering_connection.peer: Creation complete after 3s [id=pcx-02c96be126e06c53e]
aws_route.east2_peer: Creating...
aws_vpc_peering_connection_accepter.peer: Creating...
aws_route.east1_peer: Creating...
aws_subnet.subnet_east_1: Creation complete after 3s [id=subnet-04d5491820921f10f]
aws_route_table_association.east1: Creating...
aws_internet_gateway.east1: Creation complete after 3s [id=igw-0ce5f31c52a631607]
aws_route.east1: Creating...
aws_route_table_association.east1: Creation complete after 1s [id=rtbassoc-0648fca6436ebc1ca]
aws_route.east2_peer: Creation complete after 2s [id=r-rtb-0c3d67159503d844f80081744]
aws_route.east1_peer: Creation complete after 2s [id=r-rtb-097f5eb4041eff1e53362780110]
aws_route.east1: Creation complete after 3s [id=r-rtb-097f5eb4041eff1e51080289494]
aws_security_group.ec2_east_2: Creation complete after 6s [id=sg-0e6f7284c56abfafb]
aws_instance.ec2_instnace_east2: Creating...
aws_security_group.ec2_east_1: Creation complete after 6s [id=sg-0d24d9b569c88efe5]
aws_instance.ec2_instnace_east1: Creating...
aws_vpc_peering_connection_accepter.peer: Creation complete after 7s [id=pcx-02c96be126e06c53e]
aws_instance.ec2_instnace_east2: Still creating... [10s elapsed]
aws_instance.ec2_instnace_east1: Still creating... [10s elapsed]
aws_instance.ec2_instnace_east2: Still creating... [20s elapsed]
aws_instance.ec2_instnace_east1: Still creating... [20s elapsed]
aws_instance.ec2_instnace_east2: Creation complete after 21s [id=i-074865419325df543]
aws_instance.ec2_instnace_east1: Creation complete after 30s [id=i-08c554c6f8ec7eeae]

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

ip_to_try_to_ping = 10.1.1.107
public_ip_to_login = 3.238.41.203
```

10. Try connectiong to the public IP:

```
ssh -i "<pem_file>" ubuntu@3.238.41.203
```

```
ubuntu@ip-10-0-1-16:~$
```

11. Now try to ping the private ip from the output:

```
ubuntu@ip-10-0-1-16:~$ ping 10.1.1.107
PING 10.1.1.107 (10.1.1.107) 56(84) bytes of data.
64 bytes from 10.1.1.107: icmp_seq=1 ttl=64 time=12.1 ms
64 bytes from 10.1.1.107: icmp_seq=2 ttl=64 time=12.1 ms
64 bytes from 10.1.1.107: icmp_seq=3 ttl=64 time=12.1 ms
64 bytes from 10.1.1.107: icmp_seq=4 ttl=64 time=12.2 ms
```

12. We can push it a step further. Add the private_key of you key pair for the second EC2 and try to connect to it via SSH
```
ubuntu@ip-10-0-1-16:~$ vim pem
ubuntu@ip-10-0-1-16:~$ chmod 400 pem
ubuntu@ip-10-0-1-16:~$ ssh -i "pem" ubuntu@10.1.1.107
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1029-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri Nov 20 14:36:47 UTC 2020

  System load:  0.08              Processes:             101
  Usage of /:   16.8% of 7.69GB   Users logged in:       0
  Memory usage: 20%               IPv4 address for eth0: 10.1.1.107
  Swap usage:   0%

1 update can be installed immediately.
0 of these updates are security updates.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-1-1-107:~$ who
ubuntu   pts/0        2020-11-20 14:36 (10.0.1.16)
ubuntu@ip-10-1-1-107:~$ ping 10.0.1.16
PING 10.0.1.16 (10.0.1.16) 56(84) bytes of data.
64 bytes from 10.0.1.16: icmp_seq=1 ttl=64 time=12.4 ms
64 bytes from 10.0.1.16: icmp_seq=2 ttl=64 time=12.5 ms
64 bytes from 10.0.1.16: icmp_seq=3 ttl=64 time=12.5 ms
64 bytes from 10.0.1.16: icmp_seq=4 ttl=64 time=12.5 ms
```
13. We definetely have connectivity between the two servers. Now after this test is finished destroy the entire infrastructure to avoid getting billed.

```
❯ terraform destroy -auto-approve
aws_vpc.vpc_east_2: Refreshing state... [id=vpc-09af9e75dba0c62ea]
aws_vpc.vpc_east_1: Refreshing state... [id=vpc-0065405c7c825e204]
aws_subnet.subnet_east_2: Refreshing state... [id=subnet-02b9ef79066512299]
aws_security_group.ec2_east_2: Refreshing state... [id=sg-0e6f7284c56abfafb]
aws_internet_gateway.east1: Refreshing state... [id=igw-0ce5f31c52a631607]
aws_vpc_peering_connection.peer: Refreshing state... [id=pcx-02c96be126e06c53e]
aws_subnet.subnet_east_1: Refreshing state... [id=subnet-04d5491820921f10f]
aws_security_group.ec2_east_1: Refreshing state... [id=sg-0d24d9b569c88efe5]
aws_instance.ec2_instnace_east2: Refreshing state... [id=i-074865419325df543]
aws_route.east1: Refreshing state... [id=r-rtb-097f5eb4041eff1e51080289494]
aws_route_table_association.east1: Refreshing state... [id=rtbassoc-0648fca6436ebc1ca]
aws_vpc_peering_connection_accepter.peer: Refreshing state... [id=pcx-02c96be126e06c53e]
aws_route.east1_peer: Refreshing state... [id=r-rtb-097f5eb4041eff1e53362780110]
aws_route.east2_peer: Refreshing state... [id=r-rtb-0c3d67159503d844f80081744]
aws_instance.ec2_instnace_east1: Refreshing state... [id=i-08c554c6f8ec7eeae]
aws_route_table_association.east1: Destroying... [id=rtbassoc-0648fca6436ebc1ca]
aws_route.east1: Destroying... [id=r-rtb-097f5eb4041eff1e51080289494]
aws_route.east1_peer: Destroying... [id=r-rtb-097f5eb4041eff1e53362780110]
aws_instance.ec2_instnace_east1: Destroying... [id=i-08c554c6f8ec7eeae]
aws_route.east2_peer: Destroying... [id=r-rtb-0c3d67159503d844f80081744]
aws_vpc_peering_connection_accepter.peer: Destroying... [id=pcx-02c96be126e06c53e]
aws_vpc_peering_connection_accepter.peer: Destruction complete after 0s
aws_instance.ec2_instnace_east2: Destroying... [id=i-074865419325df543]
aws_route.east1: Destruction complete after 0s
aws_internet_gateway.east1: Destroying... [id=igw-0ce5f31c52a631607]
aws_route.east2_peer: Destruction complete after 0s
aws_route.east1_peer: Destruction complete after 0s
aws_vpc_peering_connection.peer: Destroying... [id=pcx-02c96be126e06c53e]
aws_route_table_association.east1: Destruction complete after 0s
aws_vpc_peering_connection.peer: Destruction complete after 3s
aws_instance.ec2_instnace_east1: Still destroying... [id=i-08c554c6f8ec7eeae, 10s elapsed]
aws_instance.ec2_instnace_east2: Still destroying... [id=i-074865419325df543, 10s elapsed]
aws_internet_gateway.east1: Still destroying... [id=igw-0ce5f31c52a631607, 10s elapsed]
aws_internet_gateway.east1: Destruction complete after 20s
aws_instance.ec2_instnace_east1: Still destroying... [id=i-08c554c6f8ec7eeae, 20s elapsed]
aws_instance.ec2_instnace_east2: Still destroying... [id=i-074865419325df543, 20s elapsed]
aws_instance.ec2_instnace_east1: Still destroying... [id=i-08c554c6f8ec7eeae, 30s elapsed]
aws_instance.ec2_instnace_east2: Still destroying... [id=i-074865419325df543, 30s elapsed]
aws_instance.ec2_instnace_east1: Destruction complete after 32s
aws_subnet.subnet_east_1: Destroying... [id=subnet-04d5491820921f10f]
aws_security_group.ec2_east_1: Destroying... [id=sg-0d24d9b569c88efe5]
aws_instance.ec2_instnace_east2: Destruction complete after 32s
aws_subnet.subnet_east_2: Destroying... [id=subnet-02b9ef79066512299]
aws_security_group.ec2_east_2: Destroying... [id=sg-0e6f7284c56abfafb]
aws_security_group.ec2_east_2: Destruction complete after 1s
aws_security_group.ec2_east_1: Destruction complete after 1s
aws_subnet.subnet_east_2: Destruction complete after 1s
aws_vpc.vpc_east_2: Destroying... [id=vpc-09af9e75dba0c62ea]
aws_subnet.subnet_east_1: Destruction complete after 1s
aws_vpc.vpc_east_1: Destroying... [id=vpc-0065405c7c825e204]
aws_vpc.vpc_east_2: Destruction complete after 1s
aws_vpc.vpc_east_1: Destruction complete after 0s

Destroy complete! Resources: 15 destroyed.
```

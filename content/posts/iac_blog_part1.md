+++
comments = false
date = "2019-08-05"
draft = false
showpagemeta = true
showcomments = true
slug = ""
categories = ["IT"]
tags = ["IAC", "Terraform", "Godaddy"]
title = "Infrastructure As Code Blog part 1 Godaddy with Terraform"
description = "My first blog entry explaning how I use Terraform to handle Godaddy and the rest of my infrastructure"

+++

## Background

As you know if you have read my [last blog entry ]({{< ref "/posts/azure_hugo_ci.md" >}}) I use GitHub ti host my static page and Azure Pipeline for CI/CD.
I have choosen Godaddy to be my DNS provider, the bigest reason behind this is that Azure and Godaddy have a partnership and I want to keep things simple. Godaddy is also big enough for other people to develop nice Terraform plugins, something that is missing in the Swedish DNS providers i have looked in to.

## Why Terraform

So why do I choose Terraform you may ask?

### Requierments

* Support multiple SaaS/PaaS and most of it's features
* Broad support amongst the community
* Be fast to update if the Saas/PaaS changes API
* Easy to extend with scripts or other tools
* Easy to get started
* From basic to advanced
* Good documentation
* Open-source

### IAC options

* Terraform
* Ansible
* Puppet
* Chef
* Saltstack
* PaaS/SaaS own json/yaml or API
* Python lib

There are many more options then these but above you can see some of the old and new options.

From what I have found Terraform is the only option that passes all my requierments. For my blog Terraform should be more then enough but if I choose to do something more intresting in the future like seting up a Kubernetes cluster I will be able to use Terraform together with Ansible or simular tools.

#### Mutable Infrastructure vs Immutable

I also want to mention mutable vs immutable IAC.

First to explain what mutable infrstructure is:
Puppet, Ansible, Chef, Saltstack etc. is mutuable, if you run PXE on prem you call on your IAC tool and it configures it as defined, same thing in the cloud but your "golden image" calls on the IAC tool. If something needs to change for example DNS is to be updated we perfrom a change in our tool and it connects to the servers or the servers connect to the tool and get's the new configuration.

Classicly Terraform is immutable, if you want to update your DNS you reinstall your entire infrastrucutre. This is the dream for allot of SRE and operations personal, becouse it more or less removes the configuration drift between servers at least if you see this as a more or less monthly activity witch it should be since you should patch all your servers about once a month.

For you who haven't worked with operations probably don't think of this but you should never change anything outside of your **IAC tool!**
I don't know how many times I have gotten requests to copy a server since we need a secondary test server or something and I copy the IAC config boot the server and asks the requester to verify that it works and I get infomred it isn't working. In about 99% of the time this is due to someone have done a manual "quick" fix to make something work and haven't commited in to your IAC tool.

Great then we reinstall all our servers once a month with the latest patches, config and problem is solved?
Well no the problem is that reallity isn't that simple.
Currently it's extermly hard to reinstall servers for every configrutaion change. Anything that stores state is a pain overall, I know that the Kubernetes community is working on ways of handeling storadge and databases in a easier way but most of us haven't come that far in our infrastrucutre (netflix and other companies like it is the shining star no the standard).
Licenses for special applications is also very hard, normally you need to provide at least three physical servers (you want high avaliability) with your mac addresses and your server serial number to make sure you can only serve licenses from these servers and thus making sure you only use the amount of licences that you have.
I haven't worked with thesse kind of issues in 18 months so i don't know if tools like FLEXLM have given some cloud solutions but to my knowladge it's still a pain.

If you wan't to read a about Infrastrucutre As Code I can realy recomend a [book][IAC_oreilly] by Kief Morris (I don't get paid for Oreilly for this, i just think it's a great book).

This is why **I** think you should use Terraform as a base to decler your infrastrucutre (how many of everything, on what network etc.) and Ansible to handle small config changes on the servers.
I still think you should make it "hard" for users to login directly to your servers unless they have a good reason to. In short it's only ansible that should login to your server and perform changes. The users should only use the application from there client.
I wan't to NOTE that containers is something else, the applications that you build today should be built in such a way that we can scale it up and down seamlessly using a tool like Kubernetes.

## Godaddy Terraform

I assume that you already have installed Terrafrom and have some basic knowladge about it's syntax.
There is no official Terraform plugin from Hashicorp as described in this [issue][github_gd_issue].
But we are in luck the community have [created one][terrafrom_gd].
For instructions on how to install the plugin please follow the [README][gd_t_install] in the repo.


[IAC_oreilly]: http://shop.oreilly.com/product/0636920039297.do
[github_gd_issue]: https://github.com/hashicorp/terraform/issues/3673
[terrafrom_gd]: https://github.com/n3integration/terraform-godaddy
[gd_api_key]: https://developer.godaddy.com/keys/
[gd_t_install]: https://github.com/n3integration/terraform-godaddy#api-key

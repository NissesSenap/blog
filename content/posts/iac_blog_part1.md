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

As you know if you have read my [last blog entry ]({{< ref "/posts/azure_hugo_ci.md" >}}) I use GitHub to host my static page and Azure Pipeline for CI/CD.
I have chosen Godaddy to be my DNS provider, the biggest reason behind this is that Azure and Godaddy have a partnership and I want to keep things simple. Godaddy is also big enough for other people to develop nice Terraform plugins, something that is missing in the Swedish DNS providers i have looked in to.

## Why Terraform

So why do I choose Terraform you may ask?

### Requirements

* Support multiple SaaS/PaaS and most of it's features
* Broad support amongst the community
* Be fast to update if the SaaS/PaaS changes API
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
* SaltStack
* PaaS/SaaS own json/yaml or API
* Python lib

There are many more options then these but above you can see some of the old and new options.

From what I have found Terraform is the only option that passes all my requirements. For my blog Terraform should be more than enough but if I choose to do something more interesting in the future like setting up a Kubernetes cluster.
I will be able to use Terraform together with Ansible or similar tools.

#### Mutable Infrastructure vs Immutable

I also want to mention mutable vs immutable IAC.

First to explain what mutable infrastructure is:
Puppet, Ansible, Chef, SaltStack etc. is mutable, if you run PXE on-premise you call on your IAC tool and it configures it as defined, same thing in the cloud but your "golden image" calls on the IAC tool. If something needs to change for example DNS is to be updated we perform a change in our tool and it connects to the servers or the servers connect to the tool and get's the new configuration.

Classically Terraform is immutable, if you want to update your DNS you reinstall your entire infrastructure. This is the dream for a lot of SRE and operations personnel, because it more or less removes the configuration drift between servers at least if you see this as a more or less monthly activity which it should be since you should patch all your servers about once a month.

For those of you who haven't worked with operations probably don't think of this but you should never change anything outside of your **IAC tool!**
I don't know how many times I have gotten requests to copy a server since we need a secondary test server or something and I copy the IAC config boot the server and asks the requester to verify that it works and I get informed it isn't working. In about 99% of the time this is due to someone have done a manual "quick" fix to make something work and haven't committed in to your IAC tool.

Great then we reinstall all our servers once a month with the latest patches, config and problem is solved?
Well no the problem is that reality isn't that simple.
Currently it's extremely hard to reinstall servers for every configuration change. Anything that stores state is a pain overall, I know that the Kubernetes community is working on ways of handling storage and databases in an easier way but most of us haven't come that far in our infrastructure (Netflix and other companies like it is the shining star no the standard).
Licenses for special applications is also very hard, normally you need to provide at least three physical servers (you want high availability) with your mac addresses and your server serial number to make sure you can only serve licenses from these servers and thus making sure you only use the amount of licences that you have.
I haven't worked with these kind of issues in 18 months so I don't know if tools like FLEXLM have given some cloud solutions but to my knowledge it's still a pain.

If you want to read about Infrastructure As Code I can really recommend a [book][IAC_oreilly] by Kief Morris (I don't get paid by O’Reilly for this, i just think it's a great book).

This is why **I** think you should use Terraform as a base to declare your infrastructure (how many of everything, on what network etc.) and Ansible to handle small config changes on the servers.
I still think you should make it "hard" for users to login directly to your servers unless they have a good reason to. In short it's only Ansible that should login to your server and perform changes. The users should only use the application from their client.
I want to NOTE that containers is something else, the applications that you build today should be built in such a way that we can scale it up and down seamlessly using a tool like Kubernetes.

## Godaddy Terraform

I assume that you already have installed Terraform and have some basic knowledge about it's syntax.
There is no official Terraform plugin from Hashicorp as described in this [issue][github_gd_issue].
But we are in luck the community have [created one][terrafrom_gd].
For instructions on how to install the plugin please follow the [README][gd_t_install] in the repo.

[IAC_oreilly]: http://shop.oreilly.com/product/0636920039297.do
[github_gd_issue]: https://github.com/hashicorp/terraform/issues/3673
[terrafrom_gd]: https://github.com/n3integration/terraform-godaddy
[gd_api_key]: https://developer.godaddy.com/keys/
[gd_t_install]: https://github.com/n3integration/terraform-godaddy#api-key

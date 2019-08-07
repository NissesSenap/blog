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

I have the following needs:

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

Bellow is the IAC options that i feel viable.

* Terraform
* Ansible
* Puppet
* Chef
* SaltStack
* PaaS/SaaS own json/yaml or API
* Python lib

There are many more options then these but above you can see some of the old and new tools.

From what I have found Terraform is the only option that passes all my requirements.

For my blog Terraform should be more than enough but if I choose to do something more interesting in the future like setting up a Kubernetes cluster.
I will be able to use Terraform together with other tools like Ansible to handle minor configuration changes.

#### Mutable Infrastructure vs Immutable

First to explain what mutable infrastructure is:

Should you be able to change something to a server after you have installed it?
Mutable says **yes** and immutable says **no**.

But of course you need to patch and change config on servers, when following the Immutable module you should instead reinstall the server.
The good thing with this is that you minimize configuration drift. Configuration drift the difference on the server from what you have defined in your IAC tool.
This is a big issue since it overall mean that you have done some manual changes on the server and this makes operations, debugging and security much harder.

Today there are tools available Terraform and [Packer](www.packer.io) which makes it possible to be immutable.

Puppet, Ansible, Chef, SaltStack etc. is classically mutable.
You run your configuration during your initial setup and the tool calls or gets called by your IAC tool to make sure that the config stays the same.

The immutable is the dream for a lots of SRE and operations personnel, but most environments isn't ready for it.
In **my personal opinion** it's to much work to reinstall your environment for a single patch for minor config change.

 Handling anything that stores state is still a pain, I know that the Kubernetes community amongst others is working on ways of handling storage and databases in an easier way but most of us haven't come that far in our infrastructure (Netflix and other companies like it is the shining star not the standard).

Licenses for special applications is also very hard, normally you need to provide at least three physical servers (you want high availability) with mac addresses and your server serial number to make sure you can only serve licenses from these servers and thus making sure you only use the amount of licences that you have.
I haven't worked with these kind of issues in 18 months so I don't know if tools like FLEXLM have given some cloud solutions but to my knowledge they haven't and handling licenses is still a pain.

If you want to read about Infrastructure As Code I can really recommend a [book][IAC_oreilly] by Kief Morris (I don't get paid by O’Reilly for this, i just think it's a great book).

So why do I still choose Terraform?
Well Terraform is a great way to declare the base of your infrastructure (how many of everything, on what network etc.) and my plan is to use Ansible to handle small config changes on the servers.
I still think users shouldn't login directly to your servers unless they have a good reason to.
In short it's only Ansible that should login to your server and perform changes, the users should only use the application from their client and not from the server.
I want to **NOTE** that containers is something else, the applications that you build today should overall follow [The Twelve Factor App](https://12factor.net/) thus building it in such a way that we can scale it up and down seamlessly using a tool like Kubernetes.

## Godaddy Terraform

So after my long ramble lets go in to using Terraform to configure Godaddy.

I assume that you already have installed Terraform and have some basic knowledge about it's syntax.
There is no official Terraform plugin from Hashicorp as described in this [issue][github_gd_issue].
But we are in luck the community have [created one][terrafrom_gd].
For latest instructions on how to use the plugin please follow the [README][github_terraform_install_gd_api] in the repo.

### Setting up Godaddy API key

When writing this Godaddy has two API:s one for [testing and one for production][gd_dev_doc].
First you need to create a [API key][gd_api_key], click "Create New API Key" choose the Production environment and you are good to go.
{{< figure src="/img/blog/iac_blog_part1/gd_api.png" width="100%">}}

The plugin supports both environment variables and defining them as a variable in the tf file.
I use environment variables.

```bash
export GODADDY_API_KEY=e4N7aHtEpeoG_XUjkXCRb7pqYrzaQwDAwuc
export GODADDY_API_SECRET=MyAPISecret0000000
```

### Download the current config

If you followed my setup in [Hugo github CI using azure devops]({{< ref "/posts/azure_hugo_ci.md" >}}), you will also have a current setup.
But since I'm a lazy person and the developer of the plugin have created the feature lets download the current config of to Terrafrom

```bash
terraform import godaddy_domain_record.gd-runningit runningit.se
```

I got the import statment from the README of the terraform plugin.
But in short godaddy_domain_record is the plugin, gd-runningit is a random name and runningit.se is my domain that tells the Godaddy API where to look.

This will create a terraform.tfstate file that should look something like this:

```json
  "resources": [
    {
      "mode": "managed",
      "type": "godaddy_domain_record",
      "name": "gd-runningit",
      "provider": "provider.godaddy",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "domain": "runningit.se",
            "record": [
              {
                "data": "185.199.108.153",
                "name": "@",
                "priority": 0,
                "ttl": 600,
                "type": "A"
              },
              {
                "data": "185.199.109.153",
                "name": "@",
                "priority": 0,
                "ttl": 600,
                "type": "A"
              },
              {
                "data": "185.199.110.153",
                "name": "@",
                "priority": 0,
                "ttl": 600,
                "type": "A"
              },
              {
                "data": "185.199.111.153",
                "name": "@",
                "priority": 0,
                "ttl": 600,
                "type": "A"
              },
              {
                "data": "@",
                "name": "www",
                "priority": 0,
                "ttl": 3600,
                "type": "CNAME"
              },
              {
                "data": "_domainconnect.gd.domaincontrol.com",
                "name": "_domainconnect",
                "priority": 0,
                "ttl": 3600,
                "type": "CNAME"
              }
            ]
          },
        }
      ]
    }
  ]
```

I convert all this to terraform code and put it in to a file i call go_daddy.tf.

```json
provider "godaddy" {
}

resource "godaddy_domain_record" "gd-runningit" {
  domain   = "runningit.se"

  record {
    name = "@"
    type = "A"
    data = "185.199.108.153"
    ttl = 600
    priority = 0
  }

  record {
    name = "@"
    type = "A"
    data = "185.199.109.153"
    ttl = 600
    priority = 0
  }

  record {
    name = "@"
    type = "A"
    data = "185.199.110.153"
    ttl = 600
    priority = 0
  }

  record {
    name = "@"
    type = "A"
    data = "185.199.111.153"
    ttl = 600
    priority = 0
  }

  record {
    name = "www"
    type = "CNAME"
    data = "@"
    ttl = 3600
    priority = 0
  }

  record {
      name = "_domainconnect"
      data = "_domainconnect.gd.domaincontrol.com"
      priority = 0
      ttl = 3600
      type = "CNAME"
  }
}
```

Time to apply the configuration

```bash
# Make sure the everything looks okay
terraform plan

# Apply the config
terraform apply
```

For updates and how to see my complete file look at my [BLOG_IAC repo][BLOG_IAC].

[IAC_oreilly]: http://shop.oreilly.com/product/0636920039297.do
[github_gd_issue]: https://github.com/hashicorp/terraform/issues/3673
[terrafrom_gd]: https://github.com/n3integration/terraform-godaddy
[gd_api_key]: https://developer.godaddy.com/keys/
[github_terraform_install_gd_api]: https://github.com/n3integration/terraform-godaddy#api-key
[gd_dev_doc]: https://developer.godaddy.com/getstarted
[BLOG_IAC]: https://github.com/NissesSenap/BLOG_IAC/blob/master/go_daddy.tf

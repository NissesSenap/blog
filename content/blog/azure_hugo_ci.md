+++
comments = false
date = "2019-07-22T15:59:13-04:00"
draft = false
showpagemeta = true
showcomments = true
slug = ""
tags = ["CI", "devops", "hugo", "github"]
title = "Hugo github CI using azure devops"
description = "Building a Azure CI piepline for my hugo blog"

+++

## Basic requierments

* Trigger CI system at PR (pull request)
* Give feedback to the user that the PR have passed
* When I merge the pull, automatically publish my updated blog.

The last one is already solved thanks to that i use github static page to share my homepage.

## Tools

My plan is to use the following tools:

* Azure Pipelines
* github
* [hub][hub_link]
* hugo
* [Yaspeller][yaspeller_git] (to help me with my crappy spelling)

The reason why I chose hugo as a static page generator is that I don't want to use Jekyll (don't like ruby) and it feels like a much more modern any way.
I have worked with gerrit and played with gitlab, and bitbucket and they all work just fine but most people use github today and I want to use something that I most likley will use for my source-controle in the future.

### Why do i pick Azure

Today we have many many options for CI/CD systems that is integrated with [github][github_ci].
I won't go through my reason why I thought X was better then Y but for me had the following main options:

* TravisCI
* CircleCi
* Azure Pipelines
* Google Cloud Build
* Codefresh

Travis was among the early CI systems that was enabled for free to open-source projects. I have contributed to a number of puppet modules that used Travis and it all worked great.
But i would like to use something else, so it's not realy an option for me.
So in enters the rest of the options.

In the end I choose **Azure Pipelines**, the main reasons:

* They have great documentation overall.
* If the documentation is bad they have it all open on github and you can create a issue or a pull-request to fix it. Something that AWS is defently missing.
* It's one of the big three cloud companys so it's a big chance of using this knoladge in the future.
* I can use Terraform or other IAC soltuions to create my CI system (something I will explore in the future).

## Detailed CI flow

Even though I'm alone on this project I need to define some WoW (Way Of Working), or at least if i want to be able to run automated CI systems and get feedback from my pushses. It's kind of to late to run a spelling check if I just push the code directly to the repo.

My current plan looks like this:

* Create blog branch
* Write new blog entry
* push the blog branch to the repo
* create a github pull-request
* Start the CI
* If CI passes report back to github as a message in the pull-request
* Merge the PR
* Azure Pipline triggers a build of hugo to the /docs folder and pushes the changes directly to the master branch

## Setup Azure Pipelines

Something something, explain how the setup LOOKS

[hub_link]: https://github.com/github/hub
[github_ci]: https://github.com/marketplace/category/continuous-integration
[yaspeller_git]: https://github.com/hcodes/yaspeller

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

H# Basic requirements

* Trigger CI system at PR (pull request)
* Give feedback to the user that the PR have passed
* When I merge the pull, automatically publish my updated blog.

The last one is already solved thanks to that i use GitHub static page to share my homepage.

## Tools

My plan is to use the following tools:

* Azure Pipelines
* GitHub
* [hub][hub_link]
* Hugo
* [Yaspeller][yaspeller_git] (to help me with my crappy spelling)

The reason why I chose Hugo as a static page generator is that I don't want to use Jekyll (don't like ruby) and it feels like a much more modern any way.
I have worked with Gerrit and played with Gitlab, and Bitbucket and they all work just fine but most people use GitHub today and I want to use something that I most likely will use for my source-control in the future.

### Why do i pick Azure

Today we have many many options for CI/CD systems that is integrated with [GitHub][github_ci].
I won't go through my reason why I thought X was better then Y but for me had the following main options:

* TravisCI
* CircleCI
* Azure Pipelines
* Google Cloud Build
* Codefresh

TravisCI was among the early CI systems that was enabled for free to open-source projects. I have contributed to a number of puppet modules that used TravisCI and it all worked great.
But i would like to use something else, so it's not really an option for me.
So in enters the rest of the options.

In the end I choose **Azure Pipelines**, the main reasons:

* They have great documentation overall.
* If the documentation is bad they have it all open on GitHub and you can create a issue or a pull-request to fix it. Something other cloud providers is missing.
* It's one of the big three cloud company's so it's a big chance of using this knowledge in the future.
* I can use Terraform or other IAC solutions to create my CI system (something I will explore in the future).

## Detailed CI flow

Even though I'm alone on this project I need to define some WoW (Way Of Working), or at least if i want to be able to run automated CI systems and get feedback from my pushes. It's kind of to late to run a spelling check if I just push the code directly to the repo.

My current plan looks like this:

* User create blog branch
* Write new blog entry
* Push the blog branch to the repo
* Create a GitHub pull-request
* Start the CI
* If CI passes report back to GitHub as a message in the pull-request
* Merge the PR
* Azure Pipeline triggers a build of Hugo to the /docs folder and pushes the changes directly to the master branch

## Setup Azure Pipelines

I'm assuming that you already got a azure account, if you don't go in to azure.com.

First we need to sync our repo to azure pipeline, follow the Microsoft [documentation][sync_azure_github] how to do it.

[hub_link]: https://github.com/github/hub
[github_ci]: https://github.com/marketplace/category/continuous-integration
[yaspeller_git]: https://github.com/hcodes/yaspeller
[sync_azure_github]: https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#where-to-install-the-github-app

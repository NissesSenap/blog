+++
comments = false
date = "2019-07-22"
draft = false
showpagemeta = true
showcomments = true
slug = ""
categories = ["IT"]
tags = ["CI", "devops", "hugo", "github", "azure"]
title = "Hugo github CI using azure devops"
description = "Building a Azure CI piepline for my Hugo blog"

+++

## Basic requirements

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
You more or less push this [link][github_azure_app] and you point to the repo you want azure Pipelines to have access to and trigger on.

### CI

Now it's time to create the CI job which in Azure Pipeline is a yaml file, you can find the update version here: [my Azure Pipeline CI file][azure_pipeline_ci]

```yaml
trigger:
- blog

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: NodeTool@0
  inputs:
    versionSpec: '10.x'
  displayName: 'Install Node.js'

- script: |
    npm install
    npm run spellcheck
  displayName: 'npm install and build'
```

The yaml file does the following:

* Only trigger when i push stuff to blog branch
* Define which os and node type to use
* Use a built in Azure function and get's node
* Install all npm dependencies
* Run the spellchecker

Go to Azure DevOps -> New Build Pipeline (under the current UI you will find it under the +) -> Existing Azure Pipelines YAML file
{{< figure src="/img/blog/azure_hugo_ci/add_pipeline.png" width="100%">}}

Save, commit and push to your repo.
The CI job should now trigger on any PR from the blog branch.

### Prepare the CD

During the CD stage of the tipeline we want to be able to push a commit to GitHub.

#### GitHub deploykeys

First we need to add an GitHub [deploykey][github_deploykeys].

GitHub deploykey is a way for CI/CD systems to talk to GitHub using ssh keys. From a UX based os perfrom ssh-keygen and follow the instructions, if you already got a current ssh-keygen **don't** overwrite your current one.

Go to your GitHub repo -> settings -> Deploy Keys and add your newly generated public key.

{{< figure src="/img/blog/azure_hugo_ci/github_deploykey.png" width="100%">}}

#### Azure secret file

Since the CD job needs to be able to push to our repo we need to add the private ssh-key to Azure. We will use a feature in Azure Pipeline called Secure files. This enabels us to save a file as a secret just as the name is hinting at.

Open your Azure Pipeline -> Libary -> Secure files and add the private ssh-key.
{{< figure src="/img/blog/azure_hugo_ci/azure_priv_key.png" width="100%">}}

The first time I ran my job i got an error saying my job didn't have access to the secure file.
I coulden't find what option to add, but the popup gave me a question asking to fix it. Just push the button and it should work.

Now we should be able to add the deployment job.

### CD

If I merge the PR my [deployment job][azure_pipeline_cd] should triggr.

```yaml
trigger:
- master

pr: none

variables:
  HUGO_VERSION: 0.55.6
  HUGO_BINARY: hugo_$(HUGO_VERSION)_Linux-64bit.tar.gz

pool:
  vmImage: 'ubuntu-latest'

steps:
- bash: |
    wget https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_BINARY)
    tar xzf $(HUGO_BINARY)
    rm -r $(HUGO_BINARY)
    chmod 755 ./hugo
  displayName: 'Install hugo'

- bash: |
    git submodule update --init --recursive
    ./hugo -t hugo-coder -d docs
    git config --local user.name "Azure Pipelines"
    git config --local user.email "azuredevops@runningit.se"
    git status
    git add docs
    git commit -m "CD after merge in blog branch $(date) ***NO_CI***"
  displayName: "Add submodule, run hugo and commit"

- task: DownloadSecureFile@1
  inputs:
    secureFile: blog_rsa
  displayName: 'Get the deploy key'

- script: |
    mkdir ~/.ssh && mv $DOWNLOADSECUREFILE_SECUREFILEPATH ~/.ssh/id_rsa
    chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
    git remote set-url --push origin git@github.com:NissesSenap/blog.git
    git push origin HEAD:master
  displayName: 'Publish GitHub Pages'
  condition: |
    and(not(eq(variables['Build.Reason'], 'PullRequest')),
        eq(variables['Build.SourceBranch'], 'refs/heads/master'))

```

I have taken most of this from a [Microsoft blog][azure_git_push].
The deployment job will do the following

* Only trigger on a merge to master, never on a PR
* Set 2 variables for reusability
* Download Hugo and chmod it, **NOTE** how to call the variables
* Add my submodule, build the page to the docs folder
* Add the changes to a commit
* Download the secure file, it's reachable using environment variables.
* Create the .ssh folder, add the private ssh-key
* Add GitHub as a known host
* Push to the master branch
* Be extra sure we don't create a infinite loop.

Now you should be able to run your own static webpage using GitHub for hosting, Hugo as generator and Azure Pipeline for CI/CD.

[hub_link]: https://github.com/github/hub
[github_ci]: https://github.com/marketplace/category/continuous-integration
[yaspeller_git]: https://github.com/hcodes/yaspeller
[sync_azure_github]: https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#where-to-install-the-github-app
[github_azure_app]: https://github.com/apps/azure-pipelines
[azure_git_push]: https://cloudblogs.microsoft.com/opensource/2019/04/05/publishing-github-pages-from-azure-pipelines/
[github_deploykeys]: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
[azure_pipeline_ci]: https://github.com/NissesSenap/blog/blob/master/azure-pipelines.yml
[azure_pipeline_cd]: https://github.com/NissesSenap/blog/blob/master/azure-pipelines-1.yml

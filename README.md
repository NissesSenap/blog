# Edvin Hugo page

## Hugo commands

### Add a new site

```hugo new site edvin_hugo```

### Start Hugo

```hugo server -w -v```

### Create a post, this contains some metadata

```hugo new content/blog/my-first-post.md```

### Build the homepage and put in to docs folder

```hugo -t coder -d docs```

## Setup

### Hugo extended

The theme Im using uses hugo extended. You can download it manually from [Hugos github][hugo_extended]
If you use normal hugo you will see an error that looks something like this:

ERROR 2020/01/18 21:20:06 Transformation failed: TOCSS: failed to transform "style.coder.css" (text/x-scss): this feature is not available in your current Hugo version, see [https://goo.gl/YMrWcn](https://goo.gl/YMrWcn) for more information

### Install hub

Hub is a github cli extension that helps you to create PR:s setup.
It makes life easy if you want to create automated PR:s for example.

[Check out hub:](https://github.com/github/hub/releases)

### Add the goa theme

```git submodule add https://github.com/luizdepra/hugo-coder.git themes/hugo-coder```

### If the submoudle already is added

```git submodule update --init --recursive```

### Download yaspeller

First you have to have nodejs & npm installed on your client.

Then install yaspeller.

```npm install```

### Run yaspeller locally

```npm run spellcheck```

## Wow

``` bash
git checkout -B blog
# Perfrom changes
git add <new files>
git push --set-upstream origin blog
# Create hej.md, should contain a pr msg
hub pull-request -c -F hej.md
# Now the CI should trigger.
```

[hugo_extended]: https://github.com/gohugoio/hugo/releases

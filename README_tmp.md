# Edvin Hugo page

### Add a new site

```hugo new site edvin_hugo```

### Add the goa theme

```git submodule add https://github.com/luizdepra/hugo-coder.git themes/hugo-coder```

### If the submoudle already is added

```git submodule update --init --recursive```

### Start Hugo

```hugo server -w -v```

### Create a post, this contains some metadata

```hugo new content/blog/my-first-post.md```

### Build the homepage and put in to docs folder

```hugo -t coder -d docs```

### Wow

``` bash
git checkout -B blog
# Perfrom changes
git add <new files>
git push --set-upstream origin blog
# Create hej.md, should contain a pr msg
hub pull-request -c -F hej.md
# Now the CI should trigger.
```

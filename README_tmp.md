# Edvin HUGO page

### Add a new site

```hugo new site edvin_hugo```

### Add the goa theme

```git submodule add https://github.com/luizdepra/hugo-coder.git themes/hugo-coder```

### If the submoudle already is added

```git submodule update --init --recursive```

### Start hugo

```hugo server -w -v```

### Create a post, this contains some metadata

```hugo new content/blog/my-first-post.md```

### Build the homepage and put in to docs folder

hugo -t coder -d docs

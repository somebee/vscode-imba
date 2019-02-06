Imba tooling for VSCode

### For more information

* [Imba](https://imba.io)

**Enjoy!**

### SFC (single file component) support

A powerful idea from Vue is the SFC (single file component). These are
files that have a section for the HTML called the `template`, another
section for the JS called the `script`, and multiple CSS sections that
are indicated by `style` sections. Each of these supports multiple
different languages. For example, if you like pug, CoffeeScript, and
Stylus, then you can use these tags: `<template lang='pug'>...</template>`,
`<script lang='coffee'>...</script>`, and `<script lang='stylus'></script>`.

In Imba, the template and script sections are already merged into one
concept. Yet, styling is required to be placed in other files. In order
to support the concept of SFC's in Imba, we only need to add in support for
styles. This is done a little different than Vue. Since it's obvious that
we only need to support CSS, we can just directly specify the language on
a line by itself, left justified.

In order to regenerate these syntax files, use the following:

```bash
cd syntaxes
yarn global add yaml2json

# convert json to yaml
json2yaml imba.tmLanguage.json > imba.tmLanguage.yaml

# convert yaml to json
yaml2json imba.tmLanguage.yaml | jq --indent 2 . > imba.tmLanguage.json

# convert json to plist
plutil -convert xml1 imba.tmLanguage.json -o imba.tmLanguage
```

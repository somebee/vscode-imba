# ⛔️ [DEPRECATED] Please use https://github.com/imba/vscode-imba

## VSCode Language Support for Imba

To learn more about Imba visit [https://imba.io](https://imba.io)

## Setting up Your Development Environment

To make management of the client and server easier, [lerna][l] will be used, so
install it below and run the bootstrap script.

```
npm install -g lerna # yarn global add lerna
npm run dev:bootstrap # yarn dev:bootstrap
```

###  Creating a Local Version

While you can build your changes manually and copy over files into your
extension directory (`~/.vscode/extensions), it's easier to let the [VSCode
Extension Manager][vem] do the grunt work:

0. Install vsce package - `npm install -g vsce`
0. run `vsce package` to create a .vsix file in your folder
0. Go to Extension tab in vscode sidebar. 
0. Click on the `...` in the top menu. 
0. Choose `Select from vsix...`. 
0. Locate the `*.vsix` file generated above.

Alternatively if you prefer the CLI use `code` command:

```
code --install-extension imba-*.vsix
```

**Enjoy!**

[l]: https://lerna.js.org/
[vem]: https://www.npmjs.com/package/vsce

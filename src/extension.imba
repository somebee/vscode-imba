
var vscode = require('vscode')

export def activate ext
	console.log "activated!!!",ext, vscode:languages, vscode.IndentAction.Indent
	vscode:languages.setLanguageConfiguration('imba',{
		onEnterRules: [
			{
				beforeText: /^\s*(?:def|class|for|if|elif|else|while|try|with|finally|except|async).*?:\s*$/,
				action: { indentAction: vscode.IndentAction.Indent }
			}
		]
	})

export def deactivate
	console.log "deactivated"
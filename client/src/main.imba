var path = require 'path'

import languages, workspace, ExtensionContext, IndentAction from 'vscode'
import LanguageClient, LanguageClientOptions, ServerOptions, TransportKind, Range, RequestType, RevealOutputChannelOn from 'vscode-languageclient'

export def activate context
	console.log "activated"
	
	# setup language server
	# var serverModule = require.resolve('imba-language-server')
	var serverModule = context.asAbsolutePath(path.join('server', 'index.js'))
	var debugOptions = { execArgv: ['--nolazy', '--inspect=6005'] }
	
	console.log serverModule, debugOptions # , debugServerModule
	
	var serverOptions = {
		# run: { module: serverModule, transport: TransportKind:ipc}
		run: {module: serverModule, transport: TransportKind:ipc, options: debugOptions }
		debug: {module: serverModule, transport: TransportKind:ipc, options: debugOptions }
	}
	
	var clientOptions = {
		documentSelector: [{scheme: 'file', language: 'imba'}]
		synchronize: { configurationSection: ['imba'] }
		revealOutputChannelOn: RevealOutputChannelOn.Info
		initializationOptions: {
			something: 1
			other: 100
		}
	}
	
	var client = LanguageClient.new('imba', 'Imba Language Server', serverOptions, clientOptions)
	var disposable = client.start

	context:subscriptions.push(disposable)
	
	client.onReady.then do
		console.log "client is ready!!"
	
	# set language configuration
	languages.setLanguageConfiguration('imba',{
		wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#%\^\&\*\(\)\=\$\-\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
		onEnterRules: [{
			beforeText: /^\s*(?:def|class|for|if|elif|else|while|try|with|finally|except|async|do).*?$/,
			action: { indentAction: IndentAction.Indent }
		}]
	})
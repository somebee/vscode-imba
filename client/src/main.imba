var path = require 'path'

import window, languages, workspace, ExtensionContext, IndentAction, DecorationOptions, DecorationRenderOptions, Disposable, Range, TextDocument from 'vscode'
# import { window, workspace, DecorationOptions, DecorationRenderOptions, Disposable, Range, TextDocument } from 'vscode';
import LanguageClient, LanguageClientOptions, ServerOptions, TransportKind, Range, RequestType, RevealOutputChannelOn from 'vscode-languageclient'


class ClientAdapter
	
	def uriToEditor uri, version
		for editor in window:visibleTextEditors
			let doc = editor:document
			if doc && uri === doc:uri.toString
				if version and doc:version != version
					continue
				return editor
		return null

var adapter = ClientAdapter.new
			

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
		# console.log "client is ready!!"

		client.onNotification('entities') do |uri,version,markers|
			let editor = adapter.uriToEditor(uri,version)
			
			return unless editor

			var styles = {
				RootScope: ["#d6bdce","#509DB5"]
			}

			var decorations = for marker in markers
				let color = styles[marker:scope] or ['#dcdbc7','#509DB5']
				{
					range: marker:range
					hoverMessage: "variable {marker:name}"
					renderOptions: {
						dark: {color: color[0]} # f3f1d5
						light: {color: color[1]}
					}
				}
			
			# console.log "client.onNotification entities",uri,markers,decorations,version
			editor.setDecorations("imba", decorations)
			
	
	# set language configuration
	languages.setLanguageConfiguration('imba',{
		wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#%\^\&\*\(\)\=\$\-\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
		onEnterRules: [{
			beforeText: /^\s*(?:def|class|for|if|elif|else|while|try|with|finally|except|async).*?$/,
			action: { indentAction: IndentAction.Indent }
		},{
			beforeText: /\s*(?:do)\s*(\|.*\|\s*)?$/,

			action: { indentAction: IndentAction.Indent }
		}]
	})
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
	
	var type = window.createTextEditorDecorationType({
		light: {color: '#509DB5'},
		dark: {color: '#dbdcb2'},
		rangeBehavior: 1
	})

	context:subscriptions.push(disposable)
	
	client.onReady.then do
		# console.log "client is ready!!"

		client.onNotification('entities') do |uri,version,markers|
			let editor = adapter.uriToEditor(uri,version)
			
			return unless editor

			var styles = {
				RootScope: ["#d6bdce","#509DB5"]
				"import": ['#91b7ea','#91b7ea']
			}

			var decorations = for marker in markers
				let color = styles[marker:type] or styles[marker:scope]
				
				{
					range: marker:range
					hoverMessage: "variable {marker:name}"
					renderOptions: color ? {dark: {color: color[0]}, light: {color: color[1]}, rangeBehavior: 1} : null
				}
			
			# console.log "client.onNotification entities",uri,markers,decorations,version
			# console.log "decorations",decorations
			editor.setDecorations(type, decorations)
			
	
	# set language configuration
	languages.setLanguageConfiguration('imba',{
		wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#%\^\&\*\(\)\=\$\-\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
		onEnterRules: [{
			beforeText: /^\s*(?:var def|let def|export def|def|export class|class|for|if|elif|else|while|try|with|finally|except|async).*?$/,
			action: { indentAction: IndentAction.Indent }
		},{
			beforeText: /\s*(?:do)\s*(\|.*\|\s*)?$/,
			action: { indentAction: IndentAction.Indent }
		}]
	})
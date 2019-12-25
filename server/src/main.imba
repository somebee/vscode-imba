import createConnection, TextDocuments from 'vscode-languageserver'
import DiagnosticSeverity from 'vscode-languageserver-types'
import Uri from 'vscode-uri'

import Service from './Service'

class DiagnosticsAdapter
	
	def locToRange doc, loc
		{start: doc.positionAt(loc[0]), end: doc.positionAt(loc[1])}
		
	def getVariables meta, doc
		let vars = []
		
		for scope in meta:scopes
			for item in scope:vars
				for ref in item:refs
					vars.push({
						name: item:name
						type: item:type
						scope: scope:type
						range: locToRange(doc,ref:loc)
					})
		return vars

	def getDiagnostics meta, doc
		var items = []

		for warn in meta:warnings
			let item = {
				severity: DiagnosticSeverity.Error
				message: warn:message
				range: locToRange(doc,warn.loc)
			}
			# console.log("handle warning",warn,item)
			items.push(item)
			
		return items

	def getSymbols meta, doc
		var items = []
		for scope in meta:scopes
			for item in scope:vars
				for ref in item:refs
					items.push({
						name: item:name
						type: item:type
						scope: scope:type
						range: locToRange(doc,ref:loc)
					})
		return vars

		
var adapter = DiagnosticsAdapter.new
var connection = process:argv:length <= 2 ? createConnection(process:stdin, process:stdout) : createConnection()


# Create a simple text document manager. The text document manager
# supports full document sync only
var documents = TextDocuments.new
documents.listen(connection)

var service = Service.new(connection,documents)
var workspaceFolder

documents.onDidOpen do |event|
	connection:console.log("[Server(${process:pid}) ${workspaceFolder}] Document opened: {event:document:uri}")
documents.listen(connection)

connection.onInitialize do |params|
	workspaceFolder = params:rootUri
	connection:console.log("[Server({process:pid}) {workspaceFolder}] Started and initialize received")
	
	return {
		capabilities: {
			# Tell the client that the server works in FULL text document sync mode
			# TODO(scanf): add support for the remaining below
			textDocumentSync: documents:syncKind,
			completionProvider: false, # { resolveProvider: false, triggerCharacters: ['.', ':', '<', '"', '/', '@', '*'] },
			signatureHelpProvider: false, # { triggerCharacters: ['('] },
			documentRangeFormattingProvider: false,
			hoverProvider: false,
			documentHighlightProvider: false,
			documentSymbolProvider: true,
			definitionProvider: false,
			referencesProvider: false,
			documentOnTypeFormattingProvider: {
				firstTriggerCharacter: ';',
				moreTriggerCharacter: ['}', '\n']
			}
		}
	}

connection.onDidChangeConfiguration do |change|
	console.log "connection.onDidChangeConfiguration"

connection.onDocumentSymbol do |documentSymbolParms|
	let uri = documentSymbolParms:textDocument:uri
	let model = service.getModel(uri)
	return model.symbols

documents.onDidChangeContent do |change|
	console.log "server.onDidChangeContent"
	let doc = change:document
	let model = service.getModel(doc:uri)
	let meta = model.entities
	let diagnostics = adapter.getDiagnostics(meta,doc)

	if diagnostics.len
		connection.sendDiagnostics({ uri: doc:uri, diagnostics: diagnostics })
	else
		connection.sendDiagnostics({ uri: doc:uri, diagnostics: [] })
		let vars = adapter.getVariables(meta,doc)
		connection.sendNotification('entities',doc:uri,doc:version,vars)

connection.listen
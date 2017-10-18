console.log("Hello from server!!")

import createConnection, TextDocuments, InitializeParams, InitializeResult, DocumentRangeFormattingRequest, Disposable, DocumentSelector, RequestType from 'vscode-languageserver'
import TextDocument, Diagnostic, Range, Position,DiagnosticSeverity from 'vscode-languageserver-types'
import Uri from 'vscode-uri'

var imbac = require 'imba/src/compiler/compiler'

class DiagnosticsAdapter

	def varToDecoration doc, item,loc
		var range = locToRange(doc,loc)
		range:name = item:name
		return {
			range: range
			options: {
				inlineClassName: 'lvar'
				hoverMessage: "Variable"
				name: item:name or 'itemname'
				linesDecorationsClassName: 'helloz'
			}
		}
	
	def warningToMarker doc, original
		var item = locToRange(doc, original:loc)
		item:severity = 3
		item:message = original:message
		return item

	def warningToDecoration model, orig
		var range = locToRange(model, orig:loc)
		return {
			range: range
			options: {
				name: 'error'
				linesDecorationsClassName: 'error'
			}
		}
		
	def getDiagnostics meta, doc
		var items = []

		for warn in meta:warnings
			let loc = warn.loc
			
			let item = {
				severity: DiagnosticSeverity.Error
				message: warn:message
				range: {
					start: doc.positionAt(loc[0])
					end: doc.positionAt(loc[1])
				}
			}
			console.log("handle warning",warn,item)
			items.push(item)
			
		return items
		
var adapter = DiagnosticsAdapter.new
var connection = process:argv:length <= 2 ? createConnection(process:stdin, process:stdout) : createConnection()

# console:log = connection:console:log.bind(connection:console)
# console:error = connection:console:error.bind(connection:console)

# Create a simple text document manager. The text document manager
# supports full document sync only
var documents = TextDocuments.new
documents.listen(connection)

connection.onInitialize do |params|
	console.log "connection.onInitialize"
	connection:console.log "hello?"
	
	return {
		capabilities: {
			# Tell the client that the server works in FULL text document sync mode
			textDocumentSync: documents:syncKind,
			completionProvider: { resolveProvider: true, triggerCharacters: ['.', ':', '<', '"', '/', '@', '*'] },
			signatureHelpProvider: { triggerCharacters: ['('] },
			documentRangeFormattingProvider: false,
			hoverProvider: false,
			documentHighlightProvider: false,
			documentSymbolProvider: false,
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
	# config = change.settings;
	# vls.configure(config);
	# // Update formatting setting
	# veturFormattingOptions = config.vetur.format;
	# documents.all().forEach(triggerValidation);
	# const documentSelector = [{ language: 'vue' }];
	# formatterRegistration = connection.client.register(vscode_languageserver_1.DocumentRangeFormattingRequest.type, { documentSelector });

documents.onDidChangeContent do |change|
	console.log "server.onDidChangeContent"
	let doc = change:document
	let code = doc.getText
	let diagnostics = []
	let meta = imbac.analyze(code,{entities: yes})
	let diagnostics = adapter.getDiagnostics(meta,doc)
	
	if diagnostics.len
		connection.sendDiagnostics({ uri: doc:uri, diagnostics: diagnostics })
	# documents.onDidChangeContent((change) => {
	#     let diagnostics: Diagnostic[] = [];
	#     let lines = change.document.getText().split(/\r?\n/g);
	#     lines.forEach((line, i) => {
	#         let index = line.indexOf('typescript');
	#         if (index >= 0) {
	#             diagnostics.push({
	#                 severity: DiagnosticSeverity.Warning,
	#                 range: {
	#                     start: { line: i, character: index},
	#                     end: { line: i, character: index + 10 }
	#                 },
	#                 message: `${line.substr(index, 10)} should be spelled TypeScript`,
	#                 source: 'ex'
	#             });
	#         }
	#     })
	#     // Send the computed diagnostics to VS Code.
	#     connection.sendDiagnostics({ uri: change.document.uri, diagnostics });
	# })

connection.listen
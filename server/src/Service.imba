var imbac = require 'imba/src/compiler/compiler'

import TextDocument, Diagnostic, Range, Position,DiagnosticSeverity,SymbolKind from 'vscode-languageserver-types'

export class DocumentModel

	prop uri
	prop doc

	def initialize uri, document
		@uri = uri
		@doc = document
		@meta = []
		@version = -1
		self

	def body
		@doc.getText

	def analyze
		if @version == @doc:version
			return self

		console.log "analyze {uri}"
		@meta = imbac.analyze(body,{entities: yes, scopes: yes})
		@version = @doc:version
		@symbols = null
		return self

	def locToRange loc
		{start: doc.positionAt(loc[0]), end: doc.positionAt(loc[1])}

	def toSymbol kind,name,loc,container
		return {
			name: name,
			kind: kind,
			location: {uri: uri, range: locToRange(loc)}
			containerName: container
		}

	def addSymbol *pars
		@symbols.push(toSymbol(*pars))

	def entities
		analyze
		return @meta

	def symbols
		return @symbols if @symbols

		@symbols = []

		analyze

		unless @meta:entities
			return @symbols
		
		var map = @meta:entities.plain
		let full = @meta:entities:_map

		for own name,item of map
			# console.log "found symbol",name,item
			if item:type == 'method'
				let path = item:namepath.split("#")[0]
				addSymbol(SymbolKind.Method,item:name,item:loc,path)

			elif item:type == 'class'
				let node = full[name]
				let loc = node.name.region
				# console.log "found class",loc
				addSymbol(SymbolKind.Class,item:namepath,loc)
			elif item:type == 'tag'
				let node = full[name]
				let loc = node.option('keyword').region
				addSymbol(SymbolKind.Class,item:namepath,loc)

		return @symbols

		for scope in meta:scopes
			for item in scope:vars
				for ref,i in item:refs
					continue if i > 0
		return @symbols

export class Service
	
	prop documents

	def initialize connection, documents
		@connection = connection
		@documents = documents
		@models = {}
		self

	def getModel uri
		uri = uri:uri or uri
		@models[uri] ||= DocumentModel.new(uri,documents.get(uri))


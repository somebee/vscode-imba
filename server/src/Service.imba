import DocumentModel from './models/DocumentModel'

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


export var Configuration = {
	wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#%\^\&\*\(\)\=\$\-\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
	onEnterRules: [{
		beforeText: /^\s*(?:var def|let def|const def|export def|def|export class|extend class|class|export tag|extend tag|tag|for|if|elif|else|while|try|with|finally|except|async).*?$/,
		action: { indentAction: IndentAction.Indent }
	},{
		beforeText: /\s*(?:do)\s*(\|.*\|\s*)?$/,

		action: { indentAction: IndentAction.Indent }
	}]
}
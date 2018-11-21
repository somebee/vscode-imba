export var Configuration = {
	wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#%\^\&\*\(\)\=\$\-\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
	onEnterRules: [{
		beforeText: /^\s*(?:var def|let def|export def|def|export class|class|for|if|elif|else|while|try|with|finally|except|async).*?$/,
		action: { indentAction: IndentAction.Indent }
	},{
		beforeText: /\s*(?:do)\s*(\|.*\|\s*)?$/,

		action: { indentAction: IndentAction.Indent }
	}]
}
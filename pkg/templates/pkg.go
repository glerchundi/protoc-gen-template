//go:generate go-bindata -pkg $GOPACKAGE -o pkg_assets.go -ignore ".go$" ./...
package templates

import (
	"strings"
	"text/template"
)

func RegisterFuncs(tmpl *template.Template) {
	tmpl.Funcs(map[string]interface{}{
		"replace": replace,
	})
}

func replace(input, from, to string) string {
	return strings.Replace(input, from, to, -1)
}

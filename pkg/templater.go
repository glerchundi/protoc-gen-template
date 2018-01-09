package pkg

import (
	"io/ioutil"
	"path/filepath"
	"text/template"

	"github.com/glerchundi/protoc-gen-template/pkg/templates"
	"github.com/lyft/protoc-gen-star"
)

const (
	predefParam   = "predef"
	predefDefault = false
	srcParam      = "src"
	dstParam      = "dst"
)

type templaterModule struct {
	*pgs.ModuleBase
}

// NewTemplater creates a new template executor module.
func NewTemplater() pgs.Module {
	return &templaterModule{
		ModuleBase: &pgs.ModuleBase{},
	}
}

func (t *templaterModule) Name() string {
	return "templater"
}

func (t *templaterModule) Execute(pkg pgs.Package, pkgs map[string]pgs.Package) []pgs.Artifact {
	predef, err := t.Parameters().BoolDefault(predefParam, predefDefault)
	t.Assert(err == nil, "could not parse `predef` parameter: ", err)
	src := t.Parameters().Str(srcParam)
	t.Assert(src != "", "`src` parameter must be set")
	dst := t.Parameters().Str(dstParam)
	t.Assert(dst != "", "`dst` parameter must be set")

	var tdata []byte
	if predef {
		tdata, err = templates.Asset(src)
	} else {
		tdata, err = ioutil.ReadFile(src)
	}
	t.Assert(err == nil, "could not find template: ", err)

	tmpl := template.New(filepath.Base(src))
	templates.RegisterFuncs(tmpl)

	tmpl, err = tmpl.Parse(string(tdata))
	t.Assert(err == nil, "could not parse template: ", err)

	t.AddGeneratorTemplateFile(dst, tmpl, pkg)

	return t.Artifacts()
}

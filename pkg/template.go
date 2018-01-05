package pkg

import (
	"github.com/lyft/protoc-gen-star"
)

type templaterModule struct {
	*pgs.ModuleBase
}

// NewTemplater creates a new template executor module.
func NewTemplater() pgs.Module {
	return &templaterModule{ModuleBase: &pgs.ModuleBase{}}
}

func (t *templaterModule) Name() string {
	return "templater"
}

func (t *templaterModule) Execute(pkg pgs.Package, pkgs map[string]pgs.Package) []pgs.Artifact {
	t.PushDir(pkg.Files()[0].OutputPath().Dir().String())
	defer t.Pop()
	t.Debug("templating:", pkg.GoName())

	t.AddGeneratorFile(
		t.JoinPath(pkg.GoName().LowerSnakeCase().String()+".tree.txt"),
		"hhhhhh",
	)

	return t.Artifacts()
}

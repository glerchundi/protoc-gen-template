package main

import (
	"github.com/glerchundi/protoc-gen-template/pkg"
	"github.com/lyft/protoc-gen-star"
)

func main() {
	pgs.Init(pgs.DebugEnv("DEBUG"), pgs.MultiPackage()).
		RegisterModule(pkg.NewTemplater()).
		Render()
}

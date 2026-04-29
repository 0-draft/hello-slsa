package main

import (
	"fmt"
	"runtime"
)

const Version = "0.1.0"

func main() {
	fmt.Printf("hello-slsa %s (%s/%s)\n", Version, runtime.GOOS, runtime.GOARCH)
}

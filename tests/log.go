package main

import "os/exec"

func GoVersion() (string, error) {

	path, err := exec.LookPath("go")

	cmd := exec.Command(path, "version")
	b, err := cmd.Output()

	return string(b), nil
}
func main() {
	_, err := GoVersion()

}

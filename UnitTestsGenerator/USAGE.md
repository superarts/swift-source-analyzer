# Usage

```console
OVERVIEW: Generate unit tests.

USAGE: unit-tests-generator [--verbose] [--dry-run] [--allow-class <allow-class> ...] [--ignore-class <ignore-class> ...] [--ignore-filename <ignore-filename> ...] [--ignore-function <ignore-function> ...] [--input-path <input-path>] [--input-filename <input-filename>] [--output-path <output-path>] [--output-filename <output-filename>] [--header-string <header-string> ...]

OPTIONS:
  --verbose               Verbose mode. 
  --dry-run               Do NOT execute any shell command at all. Not
                          supported by LillyUtilityCLI classes yet. DEBUG ONLY. 
  --allow-class <allow-class>
                          Allow functions of these classes to be tested. Can be
                          multiple. 
  --ignore-class <ignore-class>
                          Ignored classes. Can be multiple. 
  --ignore-filename <ignore-filename>
                          Ignored files. Can be multiple. 
  --ignore-function <ignore-function>
                          Ignored function namesi. Can be multiple. 
  --input-path <input-path>
                          Input path with Swift files. 
  --input-filename <input-filename>
                          Input filename. To process multiple files, use
                          --input-path instead. 
  --output-path <output-path>
                          Output path. Warning: ALL CONTENTS INSIDE WILL BE
                          DELETED!!! 
  --output-filename <output-filename>
                          Output filename. Write all tests to a single file. 
  --header-string <header-string>
                          Additional header string other than importing Quick &
                          Nimble. Can be multiple. 
  --version               Show the version.
  -h, --help              Show help information.

```

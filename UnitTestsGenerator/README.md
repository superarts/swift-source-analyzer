# Unit Tests Generator

This CLI tool is based on [SwiftWheel][../SwiftWheel], and it generates Swift unit tests automatically. Check [the usage page](USAGE.md) for details.

This project is still under development and most [QoI](https://github.com/apple/swift/blob/main/docs/Lexicon.md#qoi) needs to be improved, but it's fully functional despite of the poor implementation.

## Purpose

The purpose of this project is **NOT** to generate unit tests for human. Writing unit tests is not technically possible without translating business requirements to source code. The purpose of this project is to build the skeleton structure of existing code base with less than 1% test coverage; with the help of this tool, it is possible to achieve around 10% coverage and build the structure for the whole codebase.

## Example

Run `make test` to generate [automated tests for SwiftWheel](../SwiftWheel/Tests/). Check [the `test` section of Makefile](Makefile) for the example command.

## TO-DO

- [ ] QoI: the whole implementation should be improved
- [ ] Known issue: nested comments are not supported

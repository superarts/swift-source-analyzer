NAME=unit-tests-generator

all: clean debug
	# run.sh contains project specific parameters. should be `gitignored`.
	./run.sh

debug:
	swift build
	cp ./.build/debug/$(NAME) .

release:
	swift build -c release
	cp ./.build/release/$(NAME) .

clean:
	rm -rf $(NAME)

doc:
	echo '# Usage' > USAGE.md
	echo >> USAGE.md
	echo '```console' >> USAGE.md
	./$(NAME) --help >> USAGE.md
	echo '```' >> USAGE.md

test: clean debug
	./$(NAME) --verbose \
		--input-path ../SwiftWheel/Sources/ \
		--output-path ../SwiftWheel/Tests/Automated \
		--header-string '@testable import SwiftWheel'

	# \
		--output-filename ../SwiftWheel/Tests/AutomatedTests.swift \

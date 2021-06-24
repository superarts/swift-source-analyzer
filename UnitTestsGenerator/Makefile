NAME=unit-tests-generator

all: clean debug
	./$(NAME) --verbose \
		--input-path ~/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia/ \
		--allow-classes SlideMenuController,MySymptomsBaseViewController \
		--ignore-classes BetterSegmentedControl,AlertActionStruct,TextProperties \
		--ignore-filenames CustomUIButton.swift \
		--ignore-funcnames googleAnalyticsTrackingId,tappedCrop,serviceName,urlString,pathForService,openUrlPathForService \
		--output-path ~/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudiaTests/AutomatedTests/ \
		--output-filename ~/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudiaTests/AutomatedTests.swift \
		--header-string 'import CoreData' \
		--header-string '@testable import LillyTogetherDev'

	# \
		--input-path ~/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia/ \
		--input-filename /Users/leo/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia/Classes/SlideMenuController.swift \
		--input-filename /Users/leo/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia/Sources/View/WelcomeViewController.swift \
		--input-filename /Users/leo/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia//Sources/ReusableComponent/OnboardingLottieView.swift \
		--input-filename /Users/leo/prj/ios/virtual-claudia/VirtualClaudia/VirtualClaudia//Sources/ReusableComponent/CustomUIButton.swift \

	# TODO
	# Support Tuple: CustomUIButton.swift
	# Support @available: class BetterSegmentedControl
	# Support nested type: struct AlertActionStruct
	# Mark items that developer needs to fix: TextProperties
debug:
	swift build
	cp ./.build/debug/$(NAME) .

release:
	swift build -c release
	cp ./.build/release/$(NAME) .

clean:
	rm -rf $(NAME)

all: framework

PROJECT=BatchMixpanelObjcDispatcher.xcodeproj
SIMULATOR='platform=iOS Simulator,name=iPhone 12'
DERIVED_DATA=$(CURDIR)/DerivedData

clean:
	rm -rf $(DERIVED_DATA) $(SONAR_WORKDIR)
	set -o pipefail && xcodebuild clean -project $(PROJECT) -scheme BatchMixpanelObjcDispatcher | xcpretty

framework: clean
	set -o pipefail && xcodebuild build -project $(PROJECT) -scheme BatchMixpanelObjcDispatcher -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme BatchMixpanelObjcDispatcher -destination $(SIMULATOR) | xcpretty

carthage:
	carthage bootstrap --platform ios --use-xcframeworks

ci: carthage test

.PHONY: carthage test

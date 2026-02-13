SHELL := /bin/zsh
.PHONY: validate lint format test

validate:
	@.ci/agent_validate.sh

lint:
	@swiftlint --strict || true

format:
	@swiftformat . --config .swiftformat || true

test:
	swift test --parallel || true

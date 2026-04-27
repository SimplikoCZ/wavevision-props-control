bin=vendor/bin
chrome:=$(shell command -v google-chrome 2>/dev/null)
codeSnifferRuleset=codesniffer-ruleset.xml
coverage=$(temp)/coverage
coverageClover=$(coverage)/coverage.xml
docker=docker compose run --rm tests
php=php
src=src
temp=temp
tests=tests
dirs:=$(src) $(tests)

all:
	 @$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Setup

composer:
	$(docker) composer install

reset:
	rm -rf $(temp)/cache
	$(docker) composer dumpautoload

di: reset
	$(docker) bin/extract-services

fix: reset check-syntax phpcbf phpcs phpstan test

# QA

check-syntax:
	$(docker) $(bin)/parallel-lint -e $(php) $(dirs)

phpcs:
	$(docker) $(bin)/phpcs -sp --standard=$(codeSnifferRuleset) --extensions=php $(dirs)

phpcbf:
	$(docker) $(bin)/phpcbf -spn --standard=$(codeSnifferRuleset) --extensions=php $(dirs) ; true

phpstan:
	$(docker) $(bin)/phpstan analyze $(dirs) --level max

# Tests

test:
	$(docker) $(bin)/phpunit

test-coverage: reset
	$(docker) $(bin)/phpunit --coverage-html=$(coverage)

test-coverage-clover: reset
	$(docker) $(bin)/phpunit --coverage-clover=$(coverageClover)

test-coverage-report: test-coverage-clover
	$(docker) $(bin)/php-coveralls --coverage_clover=$(coverageClover) --verbose

test-coverage-open: test-coverage
ifndef chrome
	open -a 'Google Chrome' $(coverage)/index.html
else
	google-chrome $(coverage)/index.html
endif

ci: check-syntax phpcs phpstan test-coverage-report

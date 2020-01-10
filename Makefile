package = fission-web-api

stack_yaml = STACK_YAML="stack.yaml"
stack = $(stack_yaml) stack

build:
	$(stack) build --fast $(package):lib

release:
	$(stack) build

dirty:
	$(stack) build --ghc-options=-fforce-recomp $(package)

profile:
	$(stack) --work-dir .stack-work-profiling --profile build --fast

install:
	$(stack) install --fast

ghci:
	$(stack) repl $(package):lib --no-build --no-load --ghci-options='-j6 +RTS -A128m'

test:
	$(stack) build --test --fast $(package)

test-docs:
	$(stack) test :fission-doctest --fast

test-ghci:
	$(stack) ghci $(package):test:$(package)-tests --ghci-options='-j6 +RTS -A128m'

test-suite:
	$(stack) test :fission-test --fast

bench:
	$(stack) build --fast --bench $(package)

dev:
	$(stack) exec -- ghcid -c "stack ghci $(package):lib --test --main-is $(package):fission-web"

live:
	$(stack) exec -- yesod devel

setup:
	stack install ghcid && stack install yesod-bin

.PHONY : build dirty run install ghci test test-ghci watch

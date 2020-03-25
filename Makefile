package = fission

stack_yaml = STACK_YAML="stack.yaml"
stack = $(stack_yaml) stack

init:
	cp addon-manifest.json.example addon-manifest.json && cp env.yaml.example env.yaml

serve:
	$(stack) run fission-web

build:
	$(stack) build --fast $(package):lib

build-cli:
	$(stack) build --fast $(package):fission-cli

build-web:
	$(stack) build --fast $(package):fission-web

release:
	$(stack) build

release-cli:
	$(stack) build fission:fission-cli

release-cli-ubuntu:
	 $(stack) build --docker --docker-image=fpco/stack-build:lts-15

release-web:
	$(stack) build fission:fission-web

dirty:
	$(stack) build --ghc-options=-fforce-recomp $(package)

profile:
	$(stack) --work-dir .stack-work-profiling --profile build --fast

install-dev:
	$(stack) install --fast

install:
	$(stack) install

ghci:
	$(stack) repl $(package):lib --no-build --no-load --ghci-options='-j6 +RTS -A128m'

quality:
	$(stack) build --test --fast $(package)

linter:
	$(stack) test :fission-lint --fast

docs:
	$(stack) haddock $(package) --open

docserver:
	http-server ./.stack-work/dist/x86_64-osx/Cabal-3.0.1.0/doc/html/$(package) -p 1313 & \
    open http://localhost:1313

doctest:
	$(stack) test :fission-doctest --fast

unit-test:
	$(stack) test :fission-test --fast

test:
	make unit-test && make doctest

test-ghci:
	$(stack) ghci $(package):test:$(package)-tests --ghci-options='-j6 +RTS -A128m'

bench:
	$(stack) build --bench $(package)

bench_http1:
	ab -n 10000 -c 100 http://localhost:1337/ping/

bench_http2:
	h2load -n10000 -c100 -t2 http://localhost:1337/ping/

dev:
	$(stack) exec -- ghcid -c "stack ghci $(package):lib --test --main-is $(package):fission-web"

live:
	$(stack) exec -- yesod devel

setup:
	stack install ghcid && stack install yesod-bin

.PHONY : build dirty run install ghci test test-ghci watch doctest lint

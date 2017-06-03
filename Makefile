SHELL:=/bin/bash

check-elm-install:
	@type elm >/dev/null 2>&1 || yarn global add elm@0.18.0

./elm-stuff:
	elm package install -y

run: check-elm-install ./elm-stuff
	elm-make src/Main.elm && open index.html

.PHONY: \
	run \

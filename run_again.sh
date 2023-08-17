#!/bin/bash

set -eux

JLEVEL=16

renice -n 19 $$

git pull --rebase

# Fetch blessed Z3 and build it
(
	if ! [ -d z3 ]; then
		git clone https://github.com/mtzguido/z3 -b for_fstar
	fi
	cd z3
	git fetch
	git reset --hard origin/for_fstar
	git clean -dfx
	./configure
	make -C build -j${JLEVEL}
	install -T build/z3 ~/bin/z3-4.12.3
)

export OTHERFLAGS='--hint_info --proof_recovery'

./everest forall -- git co .
./everest forall -- git clean -dfx
./everest forall -- git pull --rebase
./everest get_vale
./everest make -j${JLEVEL}
./everest test -j${JLEVEL}

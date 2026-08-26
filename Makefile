.PHONY: check test snapshot

check: test

test:
	bash tests/run.sh

snapshot:
	bash knowledge/snapshot.sh

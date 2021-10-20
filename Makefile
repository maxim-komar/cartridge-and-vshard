.PHONY: test

init:
	rm -rf .rocks
	tarantoolctl rocks install cartridge 2.7.2
	tarantoolctl rocks install luacheck
	tarantoolctl rocks install luatest
	tarantoolctl rocks install luacov

check:
	.rocks/bin/luacheck .

test:
	rm -rf tmp/*
	.rocks/bin/luatest test/ --coverage -v
	.rocks/bin/luacov . && grep -A999 '^Summary' tmp/luacov.report.out

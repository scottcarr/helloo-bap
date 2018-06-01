all: helloo.plugin test run

run: test helloo.plugin
	bap test --pass=helloo

test: test.c
	gcc test.c -o test

helloo.plugin: helloo.ml
	bapbuild helloo.plugin -pkg bap-primus
	bapbundle install helloo.plugin

clean:
	rm helloo.plugin


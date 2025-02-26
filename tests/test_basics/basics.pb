#!/usr/bin/env -S python3 -m uplaybook.cli

from uplaybook import fs, core

fs.rm(path="testdir", recursive=True)
fs.mkdir(path="testdir")
with fs.cd(path="testdir"):
    fs.cp(path="testfile")
    assert fs.exists(path="testfile")

core.run(command="date")
r = core.run(command="true")
assert r
r = core.run(command="false", ignore_failure=True)
assert not r

var = "bar"
r = core.render(s="foo{{ var }}")
assert r == "foobar"
core.debug(msg="Expanding template: {{var}}")
core.print(msg="Expanding template: {{var}}")
core.grep(path="samplefile", search="imap")

class Handler:
    def __init__(self):
        self.ran = False

    def handler(self):
        self.ran = True

test_handler = Handler()
assert not test_handler.ran
core.run(command="true").notify(test_handler.handler)
assert not test_handler.ran
core.flush_handlers()
assert test_handler.ran

core.exit(returncode=0)
core.run(command="false")   #  if control gets here, the exit above didn't work

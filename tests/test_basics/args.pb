#!/usr/bin/env python3

from uplaybook import fs, core, up_context

core.playbook_args(
        core.Argument(name="release_name"),
        core.Argument(name="arg1", default=False, type="bool"),
        core.Argument(name="arg2", default="default"),
        core.Argument(name="arg3", default="default"),
        core.Argument(name="is_owner", default=False, type="bool"),
        )
#eval "$UP2 args.pb" release --arg1 --arg2=value || RETCODE=$?

core.debug("{{ARGS}}")
assert ARGS.release_name == "release"
assert ARGS.arg1 == True
assert ARGS.arg2 == "value"
assert ARGS.arg3 == "default"
assert ARGS.is_owner == False
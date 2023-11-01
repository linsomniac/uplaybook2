### uplaybook.core.become:

Switch to running as another user in a playbook.

If used as a context manager, you are switched back to the original user after the context.

#### Arguments:

- **user**: User name or UID of user to switch to.

Example:
    core.become(user="nobody")

    with core.become(user="backup"):
        #  to tasks as backup user
        fs.mkfile(path="/tmp/backupfile")
    #  now you are back to the previous user

### uplaybook.core.debug:

Display informational message.

Print a message or pretty-print a variable.

#### Arguments:

- **msg**: Message to display. (optional, templateable).
- **var**: Object to pretty-print (optional, templateable).

#### Examples:

    core.debug(msg="Directory already exists, exiting")
    core.debug(var=ret_value)

### uplaybook.core.exit:

End a playbook run.

#### Arguments:

- **returncode**: Exit code for process, 0 is success, 1-255 are failure (int, default=0).
- **msg**: Message to display (str, templatable, default "").

Example:
    core.exit()
    core.exit(returncode=1)
    core.exit(msg="Unable to download file", returncode=1)

### uplaybook.core.fail:

Abort a playbook run.

#### Arguments:

- **msg**: Message to display with failure (str, templateable).

Example:
    core.fail(msg="Unable to download file")

### uplaybook.core.flush_handlers:

Run any registred handlers.

Example:
    core.flush_handlers()

### uplaybook.core.grep:

Look for `search` in the file `path`

#### Arguments:

- **path**: File location to look for a match in. (templateable)
- **search**: The string (or regex) to look for. (templateable)
- **regex**: Do a regex search, if False do a simple string search. (bool, default=True)
- **ignore_failures**: If True, do not treat file absence as a fatal failure.
         (optional, bool, default=True)

#### Examples:

    if core.grep(path="/tmp/foo", search="secret=xyzzy"):
        #  code for when the string is found.

### uplaybook.core.notify:

Add a notify handler to be called later.

#### Arguments:

- **function**: A function that takes no arguments, which is called at a later time.

Example:
    core.notify(lambda: core.run(command="systemctl restart apache2"))
    core.notify(lambda: fs.remove("tmpdir", recursive=True))

### uplaybook.core.playbook_args:

Specify arguments for a playbook.

Optionally, a playbook may specify that it needs arguments.  If defined,
this will create an argument parser and command-line arguemnts and
options.

Example:
    core.playbook_args(
            core.Argument(name="user"),
            core.Argument(name="hostname")
            )
    core.debug(msg="Arguments: user={{playbook_args.user}}  hostname={{playbook_args.hostname}}")

### uplaybook.core.render:

Render a string as a jinja2 template and return the value

#### Arguments:

- **s**: Template to render. (templateable).

#### Returns:

- Rendered template as a string.

#### Examples:

    core.render(s="Value of foo: {{foo}}")

### uplaybook.core.require:

Verify we are running as the specified user.

#### Arguments:

- **user**: User name or UID of user to verify.  (int or str, templateable)

Example:
    core.require(user="nobody")

### uplaybook.core.run:

Run a command.  Stdout is returned as `output` in the return object.  Stderr
and return code are stored in `extra` in return object.

#### Arguments:

- **command**: Command to run (templateable).
- **shell**: If False, run `command` without a shell.  Safer.  Default is True:
         allows shell processing of `command` for things like output
         redirection, wildcard expansion, pipelines, etc. (optional, bool)
- **ignore_failures**: If True, do not treat non-0 return code as a fatal failure.
         This allows testing of return code within playbook.  (optional, bool)
- **change**: By default, all shell commands are assumed to have caused a change
         to the system and will trigger notifications.  If False, this `command`
         is treated as not changing the system.  (optional, bool)
- **creates**: If specified, if the path it specifies exists, consider the command
        to have already been run and skip future runes.

Extra:

- **stderr**: Captured stderr output.
- **returncode**: The return code of the command.

#### Examples:

    core.run(command="systemctl restart sshd")
    core.run(command="rm *.foo", shell=False)   #  removes literal file "*.foo"

    r = core.run(command="date", change=False)
    print(f"Current date/time: {{r.output}}")
    print(f"Return code: {{r.extra.returncode}}")

    if core.run(command="grep -q ^user: /etc/passwd", ignore_failures=True, change=False):
        print("User exists")

### uplaybook.fs.builder:

All-in-one filesystem builder.

This is targeted for use with Items() loops, for easily populating or
modifying many filesystem objects in compact declarations.

#### Arguments:

- **path**: Name of destination filesystem object. (templateable).
- **src**: Name of template to use as source (optional, templateable).
        Defaults to the basename of `path` + ".j2".
- **mode**: Permissions of file (optional, templatable string or int).
- **owner**: Ownership to set on `path`. (optional, templatable).
- **group**: Group to set on `path`. (optional, templatable).
- **action**: Type of `path` to build, can be: "directory", "template", "exists",
        "copy", "absent", "link", "symlink". (optional, templatable, default="template")
- **notify**:  Handler to notify of changes.
        (optional, Callable)

#### Examples:

    fs.builder("/tmp/foo")
    fs.builder("/tmp/bar", action="directory")
    for _ in [
            Item(path="/tmp/{{ modname }}", action="directory"),
            Item(path="/tmp/{{ modname }}/__init__.py"),
            ]:
        builder()

### uplaybook.fs.cd:

Change working directory to `path`.

Sets "extra.old_dir" on the return object to the directory before the `cd`
is done.  Can also be used as a context manager and when the context is
exited you are returned to the previous directory.

#### Arguments:

- **path**: Directory to change into (templateable).

#### Examples:

    fs.cd(path="/tmp")

    #  As context manager:
    with fs.cd(path="/tmp"):
        #  creates /tmp/tempfile
        fs.mkfile("tempfile")
    #  now are back in previous directory

### uplaybook.fs.chmod:

Change permissions of path.

#### Arguments:

- **path**: Path to change (templateable).
- **mode**: Permissions of path (optional, templatable string or int).
- **is_directory**: Treat path as a directory, impacts "X".  If not specified
        `path` is examined to determine if it is a directory.
        (optional, bool).

#### Examples:

    fs.chmod(path="/tmp/foo", mode="a=rX,u+w")
    fs.chmod(path="/tmp/foo", mode=0o755)

### uplaybook.fs.chown:

Change ownership/group of path.

#### Arguments:

- **path**: Path to change (templateable).
- **user**: User to set on `path`. (optional, templatable).
- **group**: Group to set on `path`. (optional, templatable).

#### Examples:

    fs.chown(path="/tmp", owner="root")
    fs.chown(path="/tmp", group="wheel")
    fs.chown(path="/tmp", owner="nobody", group="nobody")

### uplaybook.fs.cp:

Copy the `src` file to `path`, optionally templating the contents in `src`.

#### Arguments:

- **path**: Name of destination file. (templateable).
- **src**: Name of template to use as source (optional, templateable).
        Defaults to the basename of `path` + ".j2".
- **mode**: Permissions of directory (optional, templatable string or int).
        Sets mode on creation.
- **template**: If True, apply Jinja2 templating to the contents of `src`,
        otherwise copy verbatim.  (default: True)
- **template_filenames**: If True, filenames found during recursive copy are
        jinja2 template expanded. (default: True)
- **recursive**: If True and `src` is a directory, recursively copy it and
        everything below it to the `path`.  If `path` ends in a "/",
        the last component of `src` is created under `path`, otherwise
        the contents of `src` are written into `path`. (default: True)

#### Examples:

    fs.cp(path="/tmp/foo")
    fs.cp(src="bar-{{ fqdn }}.j2", path="/tmp/bar", template=False)

### uplaybook.fs.exists:

Does `path` exist?

#### Arguments:

- **path**: File location to see if it exists. (templateable).
- **ignore_failures**: If True, do not treat file absence as a fatal failure.
         (optional, bool, default=True)

#### Examples:

    fs.exists(path="/tmp/foo")
    if fs.exists(path="/tmp/foo"):
        #  code for when file exists

### uplaybook.fs.ln:

Create a link from `src` to `path`.

#### Arguments:

- **path**: Name of destination of link. (templateable).
- **src**: Name of location of source to create link from. (templateable).
- **symbolic**: If True, makes a symbolic link. (bool, default: False)

#### Examples:

    fs.ln(path="/tmp/foo", src="/tmp/bar")
    fs.ln(path="/tmp/foo", src="/tmp/bar", symbolic=True)

### uplaybook.fs.mkdir:

Create a directory.  Defaults to creating necessary parent directories.

#### Arguments:

- **path**: Name of file to create (templateable).
- **mode**: Permissions of directory (optional, templatable string or int).
            Sets mode on creation.
- **parents**: Make parent directories if needed.  (optional, default=True)

#### Examples:

    fs.mkdir(path="/tmp/foo")
    fs.mkdir(path="/tmp/bar", mode="a=rX,u+w")
    fs.mkdir(path="/tmp/baz/qux", mode=0o755, parents=True)

### uplaybook.fs.mkfile:

Create an empty file if it does not already exist.

#### Arguments:

- **path**: Name of file to create (templateable).
- **mode**: Permissions of file (optional, templatable string or int).
   Atomically sets mode on creation.

#### Examples:

    fs.mkfile(path="/tmp/foo")
    fs.mkfile(path="/tmp/bar", mode="a=rX,u+w")
    fs.mkfile(path="/tmp/baz", mode=0o755)

### uplaybook.fs.rm:

Remove a file or recursively remove a directory.

#### Arguments:

- **path**: Name of file/directory to remove. (templateable).
- **recursive**: If True, recursively remove directory and all contents of `path`.
       Otherwise only remove if `path` is a file.  (default: False)

#### Examples:

    fs.rm(path="/tmp/foo")
    fs.rm(path="/tmp/foo-dir", recursive=True)

### uplaybook.fs.stat:

Get information about `path`.

#### Arguments:

- **path**: Path to stat.  (templateable).
- **follow_symlinks**: If True (default), the result will be on the destination of
        a symlink, if False the result will be about the symlink itself.
        (bool, default: True)

Extra:

- **perms**: The permissions of `path` (st_mode & 0o777).
- **st_mode**: Full mode of `path` (permissions, object type).  You probably want the
        "perms" field if you just want the permissions of `path`.
- **st_ino**: Inode number.
- **st_dev**: ID of the device containing `path`.
- **st_nlink**: Number of hard links.
- **st_uid**: User ID of owner.
- **st_gid**: Group ID of owner.
- **st_size**: Total size in bytes.
- **st_atime**: The time of the last access of file data.
- **st_mtime**: The time of last modification of file data.
- **st_ctime**: The time of the last change of status/inode.
- **S_ISBLK**: Is `path` a block special device file?
- **S_ISCHR**: Is `path` a character special device file?
- **S_ISDIR**: Is `path` a directory?
- **S_ISDOOR**: Is `path` a door?
- **S_ISFIFO**: Is `path` a named pipe?
- **S_ISLNK**: Is `path` a symbolic link?
- **S_ISPORT**: Is `path` an event port?
- **S_ISREG**: Is `path` a regular file?
- **S_ISSOCK**: Is `path` a socket?
- **S_ISWHT**: Is `path` a whiteout?

#### Examples:

    stat = fs.stat(path="/tmp/foo")
    print(f"UID: {{stat.extra.st_uid}}")
    fs.stat(path="/tmp/foo", follow_symlinks=False)
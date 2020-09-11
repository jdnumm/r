# "R"

...is a simple wrapper to run local scripts, programs and commands on a remote machine.

## How dos it works

"R" will copy the current working directory to a remote system and execute a command there. 
The execution is run inside a screen session, so you can detach (Press [CTRL]+A, D) and reattach at any time.


## Example

Set the `$R_SSH_REMOTE` Environment Variable and switch to your project folder.

```
export R_SSH_REMOTE="me@my.remote.machine"
```

Run code local and remote.

```
cd myproject
python myproject.py # run local
r "python myproject.py" # run remote
```

Let's try a long running task.

```
r "python myproject.py"
```

Press [CTRL]+A, D to detach the remote session.


```
r --attach
```

Attach current running remote session. Press [CTRL]+C to abort.
If your task is already done, you can easily grab the log file.


```
r --log
```


## Prerequisites

- A Unix-like operating system on both sides: macOS, Linux, BSD.
- The Client needs curl ( for Install ) and rsync installed.
- On the Remote machine we need screen and key based SSH authentication.
- Set the `$R_SSH_REMOTE` Environment Variable for your Shell.


## Basic Installation

```
sudo curl -s https://codeberg.org/mono/r/raw/branch/main/r | sudo sh -s -- --install
```


## Using "R"

Copy current local directory to remote and run the given command inside a screen session.

```
    r "ls -la; sleep 60"
```

Other options:

```
    r -r|--run "ls -la"       : Run command on remote but dont sync files.
    r -p|--push               : Push local files to remote.
    r -f|--fetch              : Pull remote files. !!! Can Overwrite local files !!!
    r -l|--log                : Display the remote log.
    r -a|--attach             : Attach the remote screen session if running.
    r -d|--destroy            : Remove the files on the remote machine.
    r -h|--help               : Display the command options.
```

To exclude files or folders add them to a `.rignore` file.

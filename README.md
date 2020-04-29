# .githooker [![Build Status](https://travis-ci.com/boddenberg-it/.githooker.svg?branch=master)](https://travis-ci.com/boddenberg-it/.githooker)

### tl;dr: 

- common git-hook tasks as declarative configuration inside your repo
- simple & individual handling of git-hooks across team


### Why?

**.githooks** shall avoid duplicating code across multiple repositories used for _git-hook-ish_ tasks like evlauating list of staged files in a commit and fire actions accordingly. Setting up a [git-hook](https://git-scm.com/docs/githooks) is turned into a more declarative configuration. It also recudes maintenance of git-hooks across a team working on repository by tracking git-hooks in repo. Moreover, the `.githooks/helper.sh` provides simple management of project's git-hooks in an interactive CLI-manner.

Last but not least, **git** and **bash** are the only dependencies necessary for this [git-hook](https://git-scm.com/docs/githooks) helper in the hope to provide highly versatile use.

_***Note***: This shall not stop anyone from using the general idea with python, groovy or the like instead of bash_.

### How odes it work?

**.githooks** itself is added as a [git submodule](https://git-scm.com/docs/git-submodule) to desired repsoitory. Then a `githooks/` directory is manually created, which holds arbritrary [git-hook](https://git-scm.com/docs/githooks) scripts and/or **git-hooks declarations**. Such declarations need to source `.githooks/generic_hooks.sh` to use the _declarative git-hooks_ approach. The following image shall visually explain the just stated:

![alt text](https://boddenberg.it/misc/github/boddenberg-it/githooks/visualization.png "visualization of how .githooks works")

Moreover, a `.githooks/helper.sh` script is provided to manage all git-hooks (blue line). Mentioned script has to be run initially to setup hooks locally and every time a new [git-hook](https://git-scm.com/docs/githooks) is introduced or removed. This behvaiour shall align with the general [git-hook opt-in mindset](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

_**Note**: `.githooks` takes care of any git-hook script in `githooks/` regardless whether its bash or even        sourcing `.githooks/generic_hooks.sh`._



### How to setup?

### 1st) initial setup 

```bash
git submodule add https://github.com/boddenberg-it/.githooks
mkdir githooks
touch githooks/pre-commit.sh
```

Open `githooks/pre-commit.sh` in your favourite editor/IDE and put following content:

```bash
#!/bin/bash
source .githooks/generic_hooks.sh

run_command_once "*.java,*.kt" "echo \"list of expressions matches staged files\""

run_command_for_each_file "*.sh" "echo \"found staged script: \$changed_file\""
# Note: \$changed_file needs to be escaped to substitute it while actual processing.
```

After changing example to your project needs simply commit changes and push them - done!


### 2nd) local setup

After pulling latest changes initialize the [git submodule](https://git-scm.com/docs/git-submodule) via:

```bash
git submodule init
git submodule update
```

Alternatively, cloning submodules directly when initially cloning super project works via:

```bash
git clone --recurse-submodules $YOUR_PROJECT
```

Run `./githooks/helper.sh interactive` to configure hooks.

For more information about all commands run `./.githooks/helper.sh help`. 

#### usage screenshots:

tbc...

#### Feebdack [githooks@boddenberg.it](mailto:githooks@boddenberg.it?subject=[.githooks])

# test setup of .githooks

tbc ...

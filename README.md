# .githooker [![Build Status](https://travis-ci.com/boddenberg-it/.githooker.svg?branch=master)](https://travis-ci.com/boddenberg-it/.githooker)

### tl;dr: 

- simple setup, maintenance and handling of git-hooks across teams and projects
- common git-hook tasks as declarative configuration inside your git repository (optional)

### Why?

**.githooker** shall avoid duplicating code across multiple repositories used for _git-hook-ish_ tasks like evaluating list of staged files and fire actions accordingly in a pre-commit hook. The setup of such a [git-hook](https://git-scm.com/docs/githooks) is basically turned into a declarative configuration with .githooker.

Ofcourse an arbitrary executable/script is also handled by .githooker. Just create a it under `.githooks` named after the hook is shall be triggered upon and run `.githooker/enable pre-commit` - that's it!

Moreover, .githooker provides commands to simply manage git-hooks in an interactive CLI manner. The following output of `.githooker/help` command shows/explains all avalaible commands:

```
                       _ __  __                __
                ____ _(_) /_/ /_  ____  ____  / /_____  _____
               / __  / / __/ __ \/ __ \/ __ \/ //_/ _ \/ ___/
             _/ /_/ / / /_/ / / / /_/ / /_/ / ,< /  __/ /
            (_)__, /_/\__/_/ /_/\____/\____/_/|_|\___/_/
             /____/

Following .githooker/* commands are provided:

    - list          lists all hooks and their states enabled/disabled/orphaned.

    - interactive   loops through all hooks and asked whether to toggle its state.

    - enable        enables passed hook(s).

    - disable       disables passed hook(s).

      Note: "--all" can be passed as arg for enable and disable calls.


    - test          runs .githooker testsuites (only invoke in clean git state).

    - help:         prints what you're seeing.


An example call to enable the pre-commit hook looks like:

    .githooker/enable pre-commit

```

Last but not least, **git** and **bash** are the only dependencies necessary for this "[git-hook](https://git-scm.com/docs/githooks) helper" in the hope to provide highly versatile use across virtually all project languages.

_***Note***: This shall not stop anyone from using the general idea of `generic_hooks.sh` with python, ruby, groovy or the like instead of bash within .githooker_.


### How odes it work?

**.githooker** itself is added as a [git submodule](https://git-scm.com/docs/git-submodule) to desired repsoitory. Then a `.githooks/` directory is manually created, which holds arbitrary [git-hooks](https://git-scm.com/docs/githooks) and/or mentioned _git-hook declarations_. Furthermore, .githooker handles symbolic linking from hooks in `.git/hooks/pre-commit` to `.githooks/pre-commit.sh` via above mentioned `.githooker/*` commands.

### How to setup?

#### 1st) initial setup 

```bash
git submodule add https://github.com/boddenberg-it/.githooker .githooker
```

Create an actual pre-commit hook script in `.githooks/pre-commit.sh` with content you want to run, e.g.:

```bash
#!/bin/bash
source .githooker/generic_hooks.sh

run_command_once ".js,.ts" "eslint" # runs passed command once if passed expression matches

run_command_once "build.sh" "./build.sh" # can also be used to watch a specific file

run_command_for_each_file ".xml," "xmllint" # loops over all files with extension

```

After creating hook simply commit changes and push them - done!

#### 2nd) local setup

After pulling latest changes initialize the [git submodule](https://git-scm.com/docs/git-submodule) via:

```bash
git submodule init
```

Alternatively, cloning submodules directly when initially cloning super project works via:

```bash
git clone --recurse-submodules "$PROJECT_URL"
```

Then run `.githooker/interactive` to configure all available hooks in interactive mode as seen in following screenshot:

![example output of testsuites](https://boddenberg.it/github_pics/githooker/interactive_log.png)

Or explicitely enable pre-commit hook by executing `.githooker/enable pre-commit`.

_Note: One can also pass the full path to hook script or filename with extension in case you want to use the OS auto-completion feature._


# Test setup

First of all .githooker testsuites can be invoked in two different ways/environments.

- `.githooker/test` when using .githooker as submodule
- `./tests/run_tests.sh` when developing .githooker, i.e. having it cloned as repo.

Please note that `.githooker/test` shall be only invoked in a clean git state, i.e. having no staged changes. Loss of changes may occure otherwise.

Testsuites can be seen in following example output:

![example output of testsuites](https://boddenberg.it/github_pics/githooker/testsuites_log.png)

The run_tests.sh script, which is invoked in both of the above ways provides general functions for setup/teardown tasks and invokes all `*_test.sh` scripts by sourcing them. Some of these scripts may use additional helper or expect scripts, which all start with `_*`. Both expect scripts are only necessary to evaluate output generated by .githooker. But they are only invoked when expect is available to ensure functionality tests run regardless of expect.

```bash
.githooker/
└── tests
    ├── _counter_for_run_once_test.sh
    ├── _interactive.exp
    ├── _notification_test.exp
    ├── disable_test.sh
    ├── enable_test.sh
    ├── generic_hooks_tests.sh
    ├── interactive_test.sh
    ├── list_test.sh
    ├── pass_hook_path_with_extension_test.sh
    └── run_tests.sh
```

### Travis CI

The `.travis.yml` file declares all distros as `env: -distro=*` configuration. Then all distro specific `Dockerfile.*` are build in parallel using same test script `run_githooker_testsuites.sh`, which runs testsuites in both scenarios. First the develop variant having cloned repo and then .githooker added as submodule.

```bash
.githooker/
├── .travis.yml
└── tests
    ├── _docker
    │   ├── Dockerfile.alpine
    │   ├── Dockerfile.archlinux
    │   ├── Dockerfile.centos
    │   ├── Dockerfile.debian
    │   ├── Dockerfile.ubuntu
    │   └── run_githooker_testsuites.sh
    └── test_dockerfiles.sh # tests docker commands used in travis CI locally - sequentially though.
```

The pipeline runs after a new change has been introduced. Furhtermore, it runs every 24 hours if no change occured to give feedback about OS compatibility. Simply click the travis badge to see test runs for each OS.

### Feebdack

Please send questions, feedback, bugs or suggestions to [githooker@boddenberg.it](mailto:githooker@boddenberg.it?subject=[.githooker]).

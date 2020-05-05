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
git submodule add https://github.com/boddenberg-it/.githooker .githooker
mkdir .githooks
touch .githooks/pre-commit.sh
```

Open `.githooks/pre-commit.sh` in your favourite editor/IDE and put following content:

```bash
#!/bin/bash
source $TEST_BASE/generic_hooks.sh

run_command_once "*.java,*.kt" "echo \"list of expressions matches staged files\""

run_command_for_each_file "*.sh" "echo \"found staged file: \""

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

# TEST SETUP

First of all .githooker testsuites can be invoked in two different ways/environments.

- `./tests/run_tests.sh`: when developing .githooker, i.e. having it cloned as repo.
- `.githooker/test`: when using .githooker as submodule

_*Note*: Please be aware that `.githooker/test` shall be only invoked in a clean git state, i.e. having no staged changes - loss of cahnges *may* occure otherwiswe._

Testsuites can be seen in following example output:

GRAFIK von output

_*Note*: When `exepct` is not installed interactive and the githooker notification tests won't run. Still functionality is fully verified though._ 

TODO: 1-2 sentence about how test setup works
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

#### travis CI

The `.travis.yml` file declares all distros as `env: -distro=*` configuration. Then all distro specific `Dockerfile.*` are build in parallel using same test script `run_githooker_testsuites.sh`, which runs testsuites in both scenarios. First the develop variant having cloned repo and then .githooker added as submodule.

related files:
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
    └── test_dockerfiles.sh # tests docker commands used in travis CI pipeline locally - sequentially though.
```

The pipeline runs after a new change has been introduced. Furhtermore, it runs every 24 hours if no change occured to give feedback about OS compatibility. Simply click the travis badge to see test runs for each OS.

#### Feebdack

Please send questions, feedback, bugs or suggestions to [githooks@boddenberg.it](mailto:githooks@boddenberg.it?subject=[.githooks]).

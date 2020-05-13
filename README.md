# .githooker [![Build Status](https://travis-ci.com/boddenberg-it/.githooker.svg?branch=master)](https://travis-ci.com/boddenberg-it/.githooker)

### tl;dr: 

- simple setup, maintenance and handling of git-hooks across teams and projects
- common git-hook tasks as declarative configuration inside your git repository _(optional)_

### Why?

**.githooker** shall avoid duplicating code across multiple repositories used for _git-hook-ish_ tasks like evaluating the list of staged files and fire actions accordingly in a pre-commit hook. The setup of such a [git-hook](https://git-scm.com/docs/githooks) is basically turned into a **_declarative configuration_** with .githooker. Of course, any arbitrary executable/script is also handled by .githooker.

Moreover, .githooker provides commands to simply manage git-hooks in an interactive CLI manner. The following output of `.githooker/help` shows/explains all available commands:

![example output of test suites](https://boddenberg.it/github_pics/githooker/help_log.png)

Last but not least, **git** and **bash** are the only dependencies necessary for this "[git-hook helper](https://githooks.com/)" in the hope to provide highly versatile use across virtually all project languages.

_***Note***: This shall not stop anyone from using the general idea of `generic_hooks.sh` with python, ruby, groovy or the like instead of bash within .githooker_.

### How odes it work?

**.githooker** is added as a [git submodule](https://git-scm.com/docs/git-submodule) to your repository. Then a `.githooks/` directory is manually created, which holds arbitrary [git-hooks](https://git-scm.com/docs/githooks) and/or mentioned _git-hook declarations_. Furthermore, .githooker handles symbolic linking from hooks in `.git/hooks/pre-commit` to `.githooks/pre-commit.sh`.

To use **_declarative configuration_** one needs to source `.githooker/generic_hooks.sh` in each hook script. Then following two commands are available:

```bash
run_command_once "$expression" "$command"

run_command_for_each_file "$expression" "$command"
```

- $expression - which evaluates list of staged files (line-by-line)

- $command - which will be executed when expression matches

The `expression` can hold an extension, a filename or even path relative to repository. Moreover, one or multiple expressions can be configured. It's basically a `| grep -e`, only difference is that a comma ',' becomes an `or` to put some _syntactic sugar_ to the declarations. Of course, one can always pass any arbitrary valid expression.

```bash
".xml"         # matches any *.xml file

"foo.json"     # matches specific filename

"./foo/bar.py" # matches specific file

".c,.cpp"      # matches *.c or *.cpp files
```

The difference between run_command_{once,for_each_file} is that *_once runs only once if the expression matches. *_for_each_file on the other hand executes a command for each file and adds the file as an argument to the command, so the actual line in generic_hooks.sh looks like:

```bash
    $command $changed_file
```

### How to setup?

#### 1st) initial setup 

```bash
git submodule add https://github.com/boddenberg-it/.githooker .githooker
```

Create an actual pre-commit hook script in `.githooks/pre-commit.sh` with the content you want to run, e.g.:

```bash
#!/bin/bash
source .githooker/generic_hooks.sh

run_command_once ".py" "./ci/python_related_smoke_tests.sh"

run_command_for_each_file ".xml" "xmllint"
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

![example output of test suites](https://boddenberg.it/github_pics/githooker/interactive_log.png)

Or explicitly enable pre-commit hook by executing `.githooker/enable pre-commit`.

_Note: One can also pass the full path to hook script or filename with extension in case you want to use the OS auto-completion feature._


# Test setup

First of all .githooker test suites can be invoked in two different ways/environments.

- `.githooker/test` when using .githooker as submodule
- `./tests/run_tests.sh` when developing .githooker, i.e. having it cloned as repo.

Please note that `.githooker/test` shall be only invoked in a clean git state, i.e. having no staged changes. Loss of changes may occur otherwise.

Test suites can be seen in following example output:

![example output of test suites](https://boddenberg.it/github_pics/githooker/testsuites_log.png)

The `run_tests.sh` script, which is invoked in both of above ways provides general functions for setUp/tearDown tasks and invokes all `*_test.sh` scripts by sourcing them. Some of these scripts may use an additional helper or expect scripts, which all start with `_*`. Both expect scripts are only necessary to evaluate output generated by .githooker. But they are only invoked when expect is available to ensure functional tests run regardless of expect.

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

The `.travis.yml` file declares all distros as `env: -distro=*` configuration. Then all distro specific `Dockerfile.*` are built in parallel using same test script `run_githooker_testsuites.sh`, which runs test suites in both scenarios.

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

The pipeline runs after a new change has been introduced. Furthermore, it runs every 24 hours if no change occurred to give feedback about OS compatibility. Simply click the Travis badge to see test runs for each OS.

### Feebdack

Please send questions, feedback, bugs or suggestions to [githooker@boddenberg.it](mailto:githooker@boddenberg.it?subject=[.githooker]).

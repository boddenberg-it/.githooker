# .githooks - _yet another git hook helper_

### Why?

**.githooks** shall avoid duplicating code across multiple repositories used for _git-hook-ish_ tasks. It eases their setup by turning [git-hooks](https://git-scm.com/docs/githooks) into a more declarative configuration. It also recudes maintenance of [git-hooks](https://git-scm.com/docs/githooks) across a team working on a repository by tracking mentioned **git-hook declarations** in git itself.

Last but not least, **git** and **bash** are the only dependencies necessary for this [git-hook](https://git-scm.com/docs/githooks) helper in the hope to provide highly versatile use.

_***Note***: This shall not stop anyone from using the general idea with python, groovy or the like instead of bash_.



### How odes it work?

**.githooks** itself is added to desired repsoitory as a [git submodule](https://git-scm.com/docs/git-submodule). Then a `githooks/` directory is manually created, which holds arbritrary [git-hook](https://git-scm.com/docs/githooks) scripts and/or **git-hooks declarations**. Such declarations need to source `.githooks/generic_hooks.sh` to use the _declarative git-hooks_ approach. The following image shall visually explain the just stated:

![alt text](https://boddenberg.it/misc/github/boddenberg-it/githooks/visualization.png "visualization of how .githooks works")

Moreover, a `.githooks/helper.sh` script is provided to manage all git-hooks (blue line). Mentioned script has to be run initially to setup hooks locally and every time a new [git-hook](https://git-scm.com/docs/githooks) is introduced or removed. This behvaiour shall align with the general [git-hook opt-in mindset](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

_**Note**: `.githooks` takes care of any git-hook script in `githooks/` regardless whether its bash or even        sourcing `.githooks/generic_hooks.sh`._



### How to setup?

##### initial setup 

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
```

_**Note**: `\$changed_file` needs to be escaped in passed command to substitute it with actual file while processing._

After changing example to your project needs simply commit changes and push them.



##### local setup

After pulling latest changes initialize the [git submodule](https://git-scm.com/docs/git-submodule) via:

```bash
git submodule init
git submodule update
```

Alternatively, cloning submodules directly  when initially cloning super project works via:

```bash
git clone --recurse-submodules $YOUR_PROJECT
```

Then run `./githooks/helper.sh` with desired argument(s).

```bash
list		# list all hooks and its state  (color code explanation below)
enable $H1 $H2 	# enable(s) passed hook(s) 	(One or several can be passed)
disable --all	# disables all available hooks 	(One or several hooks can also be passed)

interactive	# lists each hook with status and ask whether to enable/disable status (y/N).
```
colors used to represent status of hook are <span style="color:green">enabled</span>, <span style="color:yellow">disabled</span>, <span style="color:red">orphaned</span>.

#### examples

```bash
./.githooks/helper.sh enable --all 		    # enables all available git hooks
./.githooks/helper.sh disable pre-commit pre-push   # disables both stated git hooks

./.githooks/helper.sh l		# short-hand for list 
./.githooks/helper.sh i		# short-hand for interactive
```

_**Note**: enable and disable have short-hand aliases as well (`e` and `d`)._


#### usage screenshots:

tbc...

### test setup

tbc ...

#### Feebdack [githooks@boddenberg.it](mailto:githooks@boddenberg.it?subject=[.githooks])


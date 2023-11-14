# Using EHA's High-Performance Servers

[![hackmd-github-sync-badge](https://hackmd.io/6Jj4m4CYRcKOXZjqeIWNlg/badge)](https://hackmd.io/6Jj4m4CYRcKOXZjqeIWNlg)


EHA has two high-performance Linux servers which can be used for modeling and
analysis work:

-   ***Aegypti***: 2 10-core 3.0Ghz processors, (40 virtual cores), 256GB of RAM
-   ***Prospero***: 2 18-core 3.7Ghz processors, (72 virtual cores), 512GM of RAM, 4 GPU (2
    NVIDIA GTX, 2 NVIDIA 1080)
-   ***Sycorax***: 64-core 4.5Ghz processor, (128 threads), 512GB of RAM, 2 GPU (GeForce RTX 4090 with 32768 CUDA Cores)
These servers can be accessed from anywhere you have Internet, and are
excellent for long-running, compute- or memory-intensive jobs.

Please read this entire guide before using one of the servers, as well
as the rest of the [EHA modeling and analytics
guide](https://ecohealthalliance.github.io/eha-ma-handbook/).

-   [Getting an account](#getting-an-account)
-   [RStudio interface and R Setup](#rstudio-interface-and-r-setup)
-   [Hard Disks](#hard-disks)
    -   [Moving files to and from the server
        disk](#moving-files-to-and-from-the-server-disk)
-   [Shell interface](#shell-interface)
-   [Making the most of the servers' computing
    power.](#making-the-most-of-the-servers-computing-power.)
-   [Server Etiquette and
    Communication](#server-etiquette-and-communication)
-   [Backup and Redundancy](#backup-and-redundancy)
-   [Shiny Apps](#shiny-apps)
-   [Installing more Software and Reporting
    Bugs](#installing-more-software-and-reporting-bugs)

-   [Architecture](#architecture)

## Getting an account

To get an account on the server, contact admins (currently Andrew Espira (espira@ecohealthalliance.org)) and provide
a preferred username and password.

## RStudio interface and R Setup

For much work, you can use the RStudio interface to the servers, which
is very similar to RStudio Desktop. Just visit
<https://aegypti.ecohealthalliance.org/rstudio> ,
<https://prospero.ecohealthalliance.org/rstudio> or 
<https://sycorax.ecohealthalliance.org/rstudio>.

Both machines have a large number of R packages pre-installed, but you
are free to install additional packages that you need. These packages
will store in your own directory and be accessible only to you -
installing does not affect other users.

Prospero has GPU-enabled versions of some R and Python packages, such as
**xgboost** and **Tensorflow**.

## Hard Disks

There are approximately 7 terabytes of space on the shared hard disk.
Whether you log on to `prospero` , `aegypti`or `sycorax`, you'll find your files
are the same. The two computers share a common hard drive for user
files, so you can easily switch computers without moving your work. Note
that, since RStudio saves information about your session on the hard
disk, you will likely experience some issues if you try to use RStudio
for the same project on both machines at once.

If you have very large files/data its advisable to have them in `work/`
directory to avoiding taking up space in your `home/` directory. 
The data can be accessed in either of the machine logged in. 


Because the disk is network-attached, it can be slightly slower than
direct hard disk access. If you are running a process where hard disk
speed is essential (this will be rare), place files in the `local/`
folder inside your home directory. This always points to a location on
the local hard disk and will have faster read/write speeds.

If you are working on a project together with others and wish to use a
common, large dataset that is too large for GitHub, you can place it
under the `shared/` directory in your home directory. Note that everyone
has the ability to read and write in this directory (with the exception
of some subdirectories), so be careful what you edit! Make your own
project subdirectory.

If you have files on the server drive that you aren't actively working
on but will likely be picked up again, transfer them to the `archive/`
folder in your home directory. This stores the file on a separate, 4TB
hard drive, but it is slower than other locations.

### Moving files to and from the server disk

The preferred way to transfer code between a local computer and the
server disk is git and GitHub. If you are working on a project locally,
push it to GitHub, and pull it down from the server.

RStudio on the server also has buttons in the "Files" pane to move files up and down.
There's an "Upload" button in the Pane, and an "Export" button under "More" to
download.

Finally, you can use the `scp` command from the shell to move files in bulk (see below and
[this
tutorial](https://hpc-carpentry.github.io/hpc-intro/15-transferring-files/index.html)).

## Shell interface

When running long-running jobs, it is usually preferable to run a
self-contained script in the background on the server rather than using
the RStudio console. A script is less likely to hang, easier to kill,
and running it does not block you from continuing to use the RStudio
interface. The simplest way to do this is to write R scripts that are
self-contained, and run them from the shell with the command `Rscript`,
like so:

    $ Rscript path/to/my/script.R

Note that you should always navigate to the top level of your project
directory when running code from the terminal.  To avoid issues related to
the path you should [use the **here** package in your R scripts](https://github.com/jennybc/here_here) to simplify file paths.

-   If you are not already familiar with using the shell, take some time
    to learn it. We suggest the [Software Carpentry](https://swcarpentry.github.io/shell-novice/)
    lessons.

-   You can use the Shell from the RStudio interface by going to the
    *Tools \> Terminal \> New Terminal* menu, and a terminal pane will
    open next to your R console.

-   You can connect the shell directly without RStudio from your
    computer using them SSH (secure shell) program. From a shell
    terminal on your computer run
    `ssh -p 22022 username@computer.ecohealthalliance.org`.
-   To avoid having to enter a password, you should set up a
    *public/private keypair*, where you store a public key on the server
    that matches a private key on your computer. Instructions to set
    this up are found
    [here](https://hacker-tools.github.io/remote-machines/#ssh-keys).
-   We also recommend you set up an SSH `config` file to simplify
    connecting to the host. Create a file in your computer's home
    directory called `~/.ssh/config`.  On a mac, you can do so by opening the
    terminal and typing

        mkdir ~/.ssh
        touch ~/.ssh/config
        open -e ~/.ssh/config

    Paste the following in this file, change `yourusername` to your user name, save and close:

        Host aegypti aegypti.ecohealthalliance.org
          HostName aegypti.ecohealthalliance.org
          User yourusername
          Port 22022
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null

        Host prospero prospero.ecohealthalliance.org
          HostName prospero.ecohealthalliance.org
          User yourusername
          Port 22022
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null


        Host sycorax sycorax.ecohealthalliance.org
          HostName sycorax.ecohealthalliance.org
          User yourusername
          Port 22022
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/nul 

    With this in place, you can log in by typing `ssh aegypti` 
    `ssh prospero` or `ssh sycorax`  in the terminal. It will also ensure that when we change the servers'
    configuration, your computer doesn't panic and think there's a
    security issue.

-   `mosh` is an alternative to SSH that is more robust to intermittent
    Internet connections. Once you have done the `.ssh/config` set up
    above, you can drop in mosh instead of ssh to connect, e.g.,
    `mosh aegypti` , `mosh prospero` or `mosh sycorax`. Get mosh at <https://mosh.org/>

-   When you log in via SSH or the RStudio terminal, you will be dropped
    into a program called [`byobu`](http://byobu.co/), which is a thin
    overlay over the shell. The important thing about `byobu` is that it
    persists even if you close the window, so your scripts can run when
    you are not connected. You can press F1 to configure `byobu` or opt
    not to use it. Between
    `mosh` and and `byobu`, you'll almost never lose your session.

    (More on `byobu`, including using it for multiple sessions, [here](https://simonfredsted.com/1588))

-   If you want to check your jobs on the go you can reach the servers from your phone!  The RStudio interface doesn't work that well on mobile screens, but you can use the shell interface.  [JuiceSSH](https://juicessh.com/) is a good SSH and mosh client for Android. Recommendations for iOS apps welcome.

-   The default editor for the shell on the servers is [`micro`](https://micro-editor.github.io/),
which is minimal and fairly easy to use. (Ctrl-S to save, Ctrl-Q to quit, Ctrl-E for help.).  [`nano`](https://www.nano-editor.org/) and [`vim`](https://www.vim.org/) are
also installed if you want to [change your default editor](https://www.a2hosting.com/kb/developer-corner/linux/setting-the-default-text-editor-in-linux).

-   Some other helpful resources for SSH, shell and related tools include  [this Software Carpentry
    lesson](http://v4.software-carpentry.org/shell/ssh.html), [this series of course notes](https://hacker-tools.github.io/lectures/), and the
    book *Bioinformatics Data Skills*, which you can borrow from Noam.

## Making the most of the servers' computing power.

In most cases, R tasks will not go any faster on a high-performance
machine. To take advantage of more power, you generally have to
*parallelize* your code. I am partial to this [quick intro to
parallelization in
R](http://librestats.com/2012/03/15/a-no-bs-guide-to-the-basics-of-parallelization-in-r/),
and the [**furrr**](https://davisvaughan.github.io/furrr/) package is a
quick way to get going with parallelization if you're already using the
**purrr** package for repeat tasks.  Note that, as the servers run Linux,
you can use the simpler parallelization options such as `mclapply()` and
`future(multiprocess)`, which do not require setting up a cluster like on Windows.

The servers are also useful if you are running code that
needs a large amount of memory (often big geospatial analyses), or just
something that needs to run all weekend while your computer does other
things.

If you are running big jobs, there are probably good ways to make them
more efficient and use fewer resources and finish faster. The short
online book [*Efficient R
Programming*](https://csgillespie.github.io/efficientR/index.html) is an
excellent primer on how to speed up code.

Finally, your scripts should save your results without intervention,
and it is good practice to have them save results from intermediate steps and parallel processes in case they are interrupted and so you can monitor progress.
We recommend using the [`targets`](https://ecohealthalliance.github.io/eha-ma-handbook/2-projects.html#targets) package for many such jobs.

## Using GPUS 

## Server Etiquette and Communication

Aegypti ,Prospero and sycorax  are shared resources and only work if we use them
politely. The servers are *not* good for:

-   Storing private collections of data. *There is no expectation of
    privacy on the servers*. Admins have access to everyone's folders. If you need them for a sensitive project, please contact an admin.
-   Long term data or code archival. The servers have a lot of space but
    it can quickly fill up with simulated or short-term data sets from
    other sources. In general, you should be storing your code on
    GitHub, and data in other locations such as Amazon S3, Azure Blob
    Storage, or the archive disk (see above under "Hard Disks").

Please make way for others to use the servers. We have an \#eha-servers
Slack room for coordinating their use. Check in there if you have
questions or before running a big job.

Several shell utilities are useful for checking on your own and others'
usage of the servers.

-   The `byobu` status bar at the bottom of the terminal shows a quick
    summary of machine usage. For instance, `40x10.18 251.8G25% 7.0T14%`
    means that 10.18 of 40 cores are being used, 25% of 251.8GB of memory
    is being used, and 14% of 7TB of hard disk is being used.
-   Running `htop` in the terminal will pull up a detailed display of
    total CPUs and memory usage, as well as a list of all running
    processes in the machine and their individual CPU and memory usage.
    You can sort and filter processes by usage
    or user, and also kill your own processes here. Press `?` for help
    on keyboard shortcuts and `q` to quit.  You should use `htop` to check
    on currently running jobs before starting yours, and to monitor your own
    usage during a big run.
-   Running `ncdu` in any folder pulls up a nice interface for finding
    your biggest files and deleting them. Press `?` for help and `q` to
    quit.
-   The `nice` command lets you run scripts at a lower priority. If you
    have a long-running job, use this to get out of the way of short
    scripts. `nice -n 10 Rscript path/to/my/script.R` will run your
    script at lower priority. Niceness ranges from 0-20. You can also
    adjust the niceness of an ongoing process from `htop`. Note that users
    can only make processes nicer, not higher-priority.
-   In R, you can view memory used by objects in the RStudio "Environment"
    pane or in total with `lobstr::mem_used()`, or
    [profile](https://support.rstudio.com/hc/en-us/articles/218221837-Profiling-with-RStudio#profiling-memory-example) your code to see how it uses memory.

Beware some common disk and memory hogs:

-   When thinking about how much RAM you might need, remember that many
    implementations of parallelized code will make copies of the objects
    being manipulated to send to each core. This potentially multiplies
    your RAM usage by the number of cores you run on: if you were only
    using 8GB, but parallelize to 20 cores, you could end up taking up
    160GB of space! Before running a large job over many cores, it makes
    sense to take a look at its memory footprint on just one core.
-   Your RStudio environment can take up considerable RAM, so please
    clear it when not in use. Exiting the browser window from an RStudio
    session will not immediately quit your session, and you will still
    be holding on to memory from the objects in your environment. To
    explicitly exit your RStudio session in a browser, go to
    `File -> Quit Session` in the menu bar. This will quit your session
    and free up RAM space for other users. This also frees up disk
    space, as RStudio keeps a mirror of memory on disk to recover from
    crashes or in long idle periods.
-   Very large files can slow down operations considerably when they are being
    tracked by git, as RStudio continually scans them for updates. Add large
    files or directories of many files to a [`.gitignore`](https://git-scm.com/docs/gitignore)
    file to avoid tracking them.
-   `.Rproj.user` directories in each
    of your R projects hold large clones of your sessions. They might be
    orphaned after a session crash -- these files can be safely deleted, as
    can file named `core` that are generated after a crash.
-   Don't save your session environment. The `.Rdata` files created can take
    up a lot of space. Explicitly save only important objects you create
    individually. `saveRDS()` is a better choice for saving objects than
    `save()` because it avoids name conflicts on load. Save objects without
    `saveRDS(object, "filename")` and load them with
    `object <- readRDS("filename")`.

## Backup and redundancy

While servers are not for long-term storage, we do back up information on the
servers off-site for rapid recovery after disaster or other catastrophic loss.
We can restore from backup user data changed or deleted in in the past 30 days.
In the event of loss of the servers, we can restore the server virtual machines
and backed-up data to cloud-based servers.

Contact a server admin if you need to restore lost data. Note that RStudio
project states (`.Rproj.user/`) and user `tmp/` directories are not backed up.

## Shiny Apps

We no longer host Shiny Apps on the servers. If you need to host Shiny Apps,
R Markdown reports, or similar use our RStudio Connect server (connect.eha.io).

## Scheduled jobs

The servers  can run regularly scheduled jobs using `cron`, but permission to
do this is assigned on a per-user basis. Contact an admin if you need to run
scheduled jobs.

## Installing more Software and Reporting Bugs

Users can install some software on the system using
[Homebrew](https://docs.brew.sh/Homebrew-on-Linux). It will install the
software in your home directory, so it will be available only you.

You will first need to run the following
command in the shell (on *prospero only*) to add the binary directory to your path:

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
This only needs to be run once.

After that, installing most software with Homebrew is as simple as typing the following:

   brew install name-of-software-package
   
You can also use the `brew` command to get information before installing.  For instance:

```
➜  ~ brew search bayes
==> Formulae
mrbayes ✔
➜  ~ brew info mrbayes
mrbayes: stable 3.2.7 (bottled), HEAD
Bayesian inference of phylogenies and evolutionary models
https://nbisweden.github.io/MrBayes/
/home/noamross/.linuxbrew/Cellar/mrbayes/3.2.7_2 (21 files, 7.2MB) *
  Poured from bottle on 2021-12-09 at 10:06:52
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/mrbayes.rb
License: GPL-3.0-or-later
==> Dependencies
Build: pkg-config ✔
Required: beagle ✔, open-mpi ✘
==> Options
--HEAD
        Install HEAD version
==> Analytics
install: 131 (30 days), 279 (90 days), 295 (365 days)
install-on-request: 131 (30 days), 279 (90 days), 295 (365 days)
build-error: 0 (30 days)
➜  ~ brew install mrbayes
```

Note that, like R packages, software installed in this way may need to be updated or reinstalled when we upgrade the server operating system.

If there's a program you cannot install with Homebrew or you're having problems
with a Homebrew install please 
[file an issue in this repository](https://github.com/ecohealthalliance/eha-servers).

Administrative users can often install needed programs quickly, but if
you want something as part of the long-term set up for all servers you
should note this, so it can become part of our regular upgrades. Note
that things like user shell configurations (or anything else configured
outside of user home directories) will reset, as well.

## Architecture and Maintenance

Technically, users only have access to Docker containers (virtual
machines) running on top of the base computers. Those Docker containers
are defined in files in the [`reservoir`
repository](https://github.com/ecohealthalliance/reservoir/). If you
wish to make a change to the config like adding a new program, you can
make a pull request or file an issue in that repository.

We expect to restart the servers for maintenance occasionally and will
send a warning to the \#eha-servers channels occasionally.  This will
usually occur a few weeks after the release of a new R version, though not
only then.

We manage the containers, the base machines, and other components like
user accounts using [Ansible](https://www.ansible.com/). This repository
contains the Ansible configurations, and the [`admin.md`](admin.md) file
provides administrative documentation.

Servers are backed up with [duplicity](http://duplicity.nongnu.org/) to
[Backblaze B2](https://www.backblaze.com/b2/cloud-storage.html).

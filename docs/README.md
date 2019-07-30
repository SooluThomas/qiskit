# Writing and Building Documentation

Qiskit documentation is shaped by the [docs as code](https://www.writethedocs.org/guide/docs-as-code/) philosophy and follows the
[IBM style guidelines](https://www.ibm.com/developerworks/library/styleguidelines/).

The [published documentation](https://qiskit.org/documentation/index.html) is
built from the master branch of [Qiskit/qiskit/docs](https://github.com/Qiskit/qiskit/tree/master/docs) using [Sphinx](http://www.sphinx-doc.org/en/master/).

You can build a local copy of the documentation from your local clone of the
`Qiskit/qiskit` repository as follows:

1. Clone `Qiskit/qiskit` (or your personal fork).

2. [Install Sphinx](http://www.sphinx-doc.org/en/master/usage/installation.html).

3. Install the `Material Design HTML Theme for Sphinx` by running the following
   in a terminal window:

   ```
   pip install sphinx_materialdesign_theme
   ```
4. Install the tabbed content by running the following in a terminal window:

   ```
   pip install sphinx-tabs
   ```
4. Build the documentation by navigating to your local clone of `Qiskit/qiskit`
   and running the following command in a terminal window:

   ```
   make doc
   ```

As you make changes to your local RST files, you can update your
HTML files by navigating to `/doc/` and running the following in a terminal
window:

```
make html
```

This will build a styled, HTML version of your local documentation repository
in the subdirectory `/docs/_build/html/`.

# Translating Documentation

The Qiskit community translates its documentation with [Crowdin](https://crowdin.com/), an open source tool built by a team dedicated to make
translation and localization as easy as possible for thousands of people.

Translations are not written directly to the Qiskit GitHub repo, as you might
contribute code. Instead, all translation work is done within Crowdin.

## Joining the QiskitDocs Crowdin Project

Step 1. [Create a Crowdin account](https://crowdin.com/join).

Step 2. Search for the QiskitDocs project, or [navigate directly to it](https://crowdin.com/project/qiskitdocs).

Step 3. Select a language.

Step 4. Click **Join**.

The translation lead for your language will be notified of your request to join
and guide you through the license agreement process. We'll be working to make
this process more automatic in the future.

## Translation Workflow

Step 1. [Log in to Crowdin](https://crowdin.com/login>).

Step 2. [Navigate to the QiskitDocs project](https://crowdin.com/project/qiskitdocs).

Step 3. Choose your language.

Step 4. Choose a portable object (PO) file to translate.

Step 5. Review the **SOURCE STRING**.

Step 6. Write your translation of the source string. Refer to the translation
memory (**TM**) and machine translation (**MT**) to potentially make your work
easier.

Step 7. Click **SAVE**.

# Qiskit documentation and translation flow

This document summarizes the flow for updating the documentation for Qiskit that ends up being available at:

https://qiskit.org/documentation/

Quick steps:

1. Update the .rst files in the `doc/` folder
2. Push the changes to `qiskit` repository `master` branch (via a PR).
3. Once the PR is approved for merge, Travis CI is triggered using .travis.yml
   file in the `master` branch.
3. After the Travis CI for `master` branch is completed for that merge, it
   will automatically push a commit to `poRepo` branch with .po files for
   translation and a commit to the `qiskit.org` repository with the HTML
   documentation.
4. The translations can be made in [Crowdin](https://crowdin.com/project/qiskitdocs)
5. The approved translations from Crowdin creates a PR for `poRepo` branch,
   which once approved, triggers Travis CI for `poRepo` to push a commit to
   `qiskit.org` repository with the translated HTML documentation.
6. In turn, the Travis CI for the `qiskit.org` repository starts a deploy
   into the server that hosts `qiskit.org`.
7. Enjoy the new documentation at https://qiskit.org/documentation.


```
User       Qiskit repo        Crowdin      Qiskit.org repo    Qiskit.org site
        master    poRepo
 .       .           .            .            .                     .
 1 ----->            .    2.1     .            .                     .
    PR   |           <-------------            .                     .
         |           .     PR                  .                     .
         |     2     .                         .                     .
         ------------>          2.2
         |  travis   -------------------------->                     .
         |                    travis           .                     .
         |     3                               .                     .
         -------------------------------------->          4          .
                        travis                 --------------------->!
                                                        travis
```

Note that depending on load and build times, the whole process might take a
while (~30 minutes for 2 and 3, another ~15mins for 2.2 and 4 each).

### Details

## 1. Updating the documentation

Takes place in the local device of the documentation editor, modifying the
relevant files, and finally submitting a PR to the `qiskit` repository.

Actors:

* Human: Updates the documentation, by modifying/appending the `.rst` files in
  the `doc/` folder or the Python code inside the `qiskit/` folder.
* `Sphinx`: Renders the documentation into HTML. For convenience, there is a
  `make html` command that can be used for checking the result of the changes
  locally.

Relevant folders and files:

* https://github.com/Qiskit/qiskit/tree/master/docs : Folder with the
  sources for the documentation.
* `doc/_build/html/`: Location of the rendered files produced by `make html`.


## 2. Pushing to the `master` branch

Once the changes from step 1 are ready to be included, a PR should be submitted
to the `qiskit` repository.

<!-- Please note that, in general, we strive for keeping `master` and `stable` easily
synchronizable - if the changes to the documentation are **not** urgent, we
recommend that the documentation is added to the repository via a regular PR
against the `master` branch, and qiskit.org will be updated eventually when a
new release comes up. In case of doubt, please check with the terra team for
the best course of action. -->

Actors:

* `Qiskit master branch`: This branch has some considerations - in particular,
  it is set up so that every time a commit is made into that branch, the
  generation of the documentation will be triggered.

## 3. Terra CI commits to qiskit.org repository

This step is automatic: when a commit is added to the terra `master` branch,
the CI automatically renders the documentation into HTML, and makes a commit in
the `qiskit.org` repository, with the subject `Automated documentation update
from meta-qiskit`.

Please note that the documentation building is part of the last stage - if
there was a failure during the CI (for example, failing tests), the
documentation building step does **not** get executed.

Actors:

* `Travis`: The CI system is responsible for rendering the documentation
  automatically, calling `make html` as in step 1.

Relevant folders and files:

* https://github.com/Qiskit/qiskit/blob/master/tools/deploy_documentation.sh :
  script that gets called by the CI for pushing to the `qiskit.org` repository.
* https://github.com/Qiskit/qiskit/blob/master/.travis.yml : Travis
  configuration file (`stage: deploy doc and pypi`).
* https://github.com/Qiskit/qiskit.org/commits/master : list of commits in the
  `qiskit.org` repository.
* https://travis-ci.com/Qiskit/qiskit : Travis interface, for checking the
  status of the build.

## 4. Qiskit.org (repo) CI deploys to qiskit.org (site)

This steps is automatic. When a commit is added to the `qiskit.org` repository,
the CI automatically deploys its contents into the server that hosts qiskit.org
(https://qiskit.org/documentation).

Actors:

* `Travis`: The CI system is responsible for deploying

Relevant folders and files:

* https://travis-ci.com/Qiskit/qiskit.org : Travis interface, for checking the
  status of the deployment.

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

   ```pip install sphinx_materialdesign_theme```

4. Build the documentation by navigating to your local clone of `Qiskit/qiskit`
   and running the following command in a terminal window:

   ```make doc```

As you make changes to your local RST files, you can update your
HTML files by navigating to `/doc/` and running the following in a terminal
window:

```make html```

This will build a styled, HTML version of your local documentation repository
in the subdirectory `/docs/_build/html/`.

# Translating Documentation

The Qiskit community translates its documentation with `Crowdin
<https://crowdin.com/>`__, an open source tool built by a team dedicated to make
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


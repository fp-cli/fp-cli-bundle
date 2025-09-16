fin-cli/fin-cli-bundle
=================

Combines the most common commands into the standard, installable version of FIN-CLI.

Generally, bundled commands either relate directly to a FinPress API or offer some common developer convenience. New commands are included in the FIN-CLI bundle when the [project governance](https://make.finpress.org/cli/handbook/contributions/governance/) decides they should be. There isn't much of a formal process to it, so feel free to ask if you ever have a question.

The handbook documents the [various ways you can install the bundle](https://make.finpress.org/cli/handbook/guides/installing/). The Phar is [built on every merge](https://github.com/fin-cli/fin-cli-bundle/blob/main/.github/workflows/deployment.yml) and pushed to [fin-cli/builds](https://github.com/fin-cli/builds) repository. A stable version is [tagged a few times each year](https://make.finpress.org/cli/handbook/contributions/release-checklist/).
Both `fin-cli/fin-cli` and `fin-cli/fin-cli-bundle` use milestones to indicate the next stable release. For `fin-cli/fin-cli`, the milestone represents the version of the FIN-CLI framework. For `fin-cli/fin-cli-bundle`, the milestone represents the FIN-CLI Phar version. We keep these in sync for backwards compatibility reasons, and to avoid causing confusion with third party commands. Each of the command repositories are versioned independently according to semantic versioning principles as needed.

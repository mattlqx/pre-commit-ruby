# pre-commit-ruby

This is a plugin for [pre-commit](https://pre-commit.com) that will run various ruby tools for linting and testing.

### Usage

Hooks require that `bundle` be already available on your system.

To lint Ruby changes in your repo, use the `rubocop` hook. The root of your repo must have a `Gemfile` that includes the desired version of rubocop. It will be installed via Bundler prior to linting. Rubocop will only be run against changed files for each commit.

To lint Chef changes in your repo, use the `foodcritic` or `cookstyle` hook. The root of your repo must have a `Gemfile` that includes the desired version of foodcritic or cookstyle. It will be installed via Bundler prior to linting. Foodcritic will only be run against cookbooks with changes to Chef code; this does not include the libraries directory of a cookbook. Cookstyle will be run against cookbooks and it's at the tools discretion of what actually gets checked. You may specify `--fix` as an argument for cookstyle for it to auto-fix any issues that it can.

To check Chef cookbook version bumps, use the `chef-cookbook-version` hook. Each changed cookbook will have its `metadata.rb` or `metadata.json` checked to determine if its version has been increased. If not, it will automatically be fixed with the patch-level incremented.

To unit test Ruby changes in your repo, use the `rspec` hook. Each path in your repo with a `spec` directory should have a `Gemfile` that includes your desired version of rspec (or a derivative library). It will be installed via Bundler prior to testing. Rspec will only be run against the closest directory in a changed file's path with a spec dir.

    - repo: https://github.com/mattlqx/pre-commit-ruby
      rev: v1.3.6
      hooks:
      - id: rubocop
      - id: foodcritic
      - id: cookstyle
      - id: rspec
      - id: chef-cookbook-version

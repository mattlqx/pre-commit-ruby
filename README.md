# pre-commit-ruby

This is a plugin for [pre-commit](https://pre-commit.com) that will run various ruby tools for linting and testing.

### Usage

Hooks require that `bundle` be already available on your system.

To lint Ruby changes in your repo, use the `rubocop` hook. The root of your repo must have a `Gemfile` that includes the desired version of rubocop. It will be installed via Bundler prior to linting. Rubocop will only be run against changed files for each commit.

To unit test Ruby changes in your repo, use the `rspec` hook. Each path in your repo with a `spec` directory should have a `Gemfile` that includes your desired version of rspec (or a derivative library). It will be installed via Bundler prior to testing. Rspec will only be run against the closest directory in a changed file's path with a spec dir.

    - repo: https://github.com/mattlqx/pre-commit-ruby
      rev: v1.0.1
      hooks:
      - id: rubocop
      - id: rspec

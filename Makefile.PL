use inc::Module::Install;
name 'App-RepoSync';
all_from 'lib/App/RepoSync.pm';

requires 'CLI::Framework';
readme_markdown_from_pod 'lib/App/RepoSync.pm';
tests 't/*.t';
scripts 'scripts/repo';
# author_tests 'xt';
# test_requires 'Test::More';
# auto_set_repository;
auto_include;
WriteAll;

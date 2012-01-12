package App::RepoSync::Command::Export;
use 5.10.0;
use warnings;
use strict;
use base qw( CLI::Framework::Command );
use Cwd;
use YAML;
use App::RepoSync::Export;

sub run {
    my ($self,$opts,@args) = @_;

    my ($export_file,@dirs) = @args;

    $export_file ||= 'repos.yml';
    @dirs = getcwd() unless @dirs;

    say 'scanning repos...';
    my @data = ();
    for( @dirs ) {
        my @repos = App::RepoSync::Export->run( $_ );
        push @data, @repos;
    }

    YAML::DumpFile( $export_file , {
        version => 0.1,
        repos => \@data,
    });

    say "done. @{[ scalar @data ]} repositories exported.";
}



1;

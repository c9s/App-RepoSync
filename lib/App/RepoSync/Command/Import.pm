package App::RepoSync::Command::Import;
use 5.10.0;
use warnings;
use strict;
use base qw( CLI::Framework::Command );
use File::Path qw(mkpath);
use Try::Tiny;
use Cwd;
use YAML;
use App::RepoSync::Export;
use App::RepoSync::SystemUtil qw(system_or_die chdir_qx);

sub option_spec {
    [ 'help|h'      => 'show help' ],
    [ 'verbose|v'   => 'be verbose' ],
    # [ 'db=s'        => 'path to SQLite database file' ],
}

sub run {
    my ($self,$opts,@args) = @_;
    my ($import_file) = @args;

    my $back_dir = getcwd();

    my $verbose = $opts->{verbose};
    my $svn_opts = $verbose ? qq() : qq(-q);
    my $git_opts = $verbose ? qq(--verbose) : qq(--quiet);
    my $git_svn_opts = $verbose ? qq() : qq(--quiet);

    my $data = YAML::LoadFile $import_file;

    say "importing @{[ scalar @{ $data->{repos} } ]} repositories.";

    for my $repo ( @{ $data->{repos} } ) {
        given ($repo->{type} ) {
            when('svn') { 
                my $path = $repo->{path};
                my $url = $repo->{url};
                if ( -e $path ) {
                    say "svn: updating $path from $url";

                    system_or_die("svn update $svn_opts --trust-server-cert --non-interactive $path",
                            "svn update");
                }
                else {
                    say "svn: checking out $url into $path";
                    system_or_die("svn checkout $svn_opts --trust-server-cert --non-interactive $url $path",
                            "svn checkout");
                }
            }
            when('git') { 
                my $path = $repo->{path};
                my $url = $repo->{url};
                my %remotes = %{ $repo->{remotes} };
                if( -e $path ) {
                    say "git: updating $path";
                    say "git: remote update and prune";

                    system_or_die("git remote update --prune",'git remote update',$path);

                    # should we update current working copy ?
                    my $dirty = chdir_qx("git diff",$path);
                    if( $dirty ) {
                        say "$path (dirty)";
                        next;
                    }

                    say "git: pulling $path";
                    for my $remote ( values %remotes ) {
                        system_or_die("git pull $git_opts $remote HEAD","git pull",$path);
                    }
                }
                else {
                    say "git: cloning $url into $path";
                    system_or_die("git clone $git_opts $url $path","git clone");
                }
            }
            when('git-svn') { 
                my $path = $repo->{path};
                my $url = $repo->{url};

                if( -e $path ) {
                    say "git-svn: updating $path";
                    system_or_die("git svn rebase --fetch-all -q $git_svn_opts --fetch-all");
                } else {
                    say "git-svn: checking out $url into $path";
                    system_or_die("git svn clone -q $url $path","checkout svn through git-svn");
                }
            }
            when('hg') {
                my $path = $repo->{path};
                my $url = $repo->{url};

                if( -e $path ) {
                    say "hg: updating $path";
                    system_or_die("hg update","hg update --quiet",$path);
                }
                else {
                    say "hg: checking out $url into $path";
                    system_or_die("hg clone --quiet $url $path","hg clone");
                }

            }
        }
    }
    say "done. @{[ scalar @{ $data->{repos} } ]} repositories imported.";
}

1;

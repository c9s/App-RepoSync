package App::RepoSync::SystemUtil;
use warnings;
use strict;
use Cwd;
use Exporter::Lite;
our @EXPORT_OK    = qw(system_or_die chdir_qx);

=head2 system_or_die

@param arrayref|string $command
@param string $description
@param string $chdir

=cut

sub system_or_die {
    my ($command,$description,$chdir) = @_;
    my $cwd = getcwd();
    chdir $chdir if $chdir;
    system($command) == 0
        or die "$description failed: $?";
    chdir $cwd if $chdir;
}

sub chdir_qx {
    my ($cmd,$chdir) = @_;
    my $cwd = getcwd();
    chdir $chdir;
    my $ret = qx($cmd);
    chdir $cwd;
    return $ret;
}


1;

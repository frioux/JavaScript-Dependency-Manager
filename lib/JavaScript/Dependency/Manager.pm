package JavaScript::Dependency::Manager;

use Moo;
use Sub::Quote;
use Tie::IxHash;
use autodie;

has lib_dir => (
  is       => 'ro',
  required => 1,
);

has recurse => (
  is      => 'ro',
  default => quote_sub q{ 0 },
);

has scan_files => (
  is      => 'ro',
  default => quote_sub q{ 1 },
);

has _scanned_files => (
  is => 'rw',
);

# hashref where the provision (what a file provides) is the key,
# and an arrayref of the files that provide the feature are the value
has provisions => (
  is => 'ro',
  default => quote_sub q{ {} },
);

# hashref where the filename is the key, and the value is required provisions in
# an arrayref
has requirements => (
  is => 'ro',
  default => quote_sub q{ {} },
);

sub file_list_for_provisions {
  my ($self, $provisions) = @_;

  if ($self->scan_files && !$self->_scanned_files) {
    for my $dir (@{$self->lib_dir}) {
      $self->_scan_dir($dir);
    }
    $self->_scanned_files(1);
  }

  my %ret;
  tie %ret, 'Tie::IxHash';
  for my $requested_provision (@$provisions) {
    my $files = $self->_files_providing($requested_provision);

    # for now we just use the first file
    my $file = $files->[0];
    if (my $requirements = $self->_direct_requirements_for($file)) {
      $ret{$_} = 1 for $self->file_list_for_provisions($requirements);
    }
    $ret{$file} = 1;
  }

  return keys %ret;
}

sub _scan_dir {
  my ($self, $dir) = @_;
  my $dh;
  opendir $dh, $dir;
  my @files = grep { $_ ne '.' && $_ ne '..' } readdir $dh;
  for (@files) {
    my $fqfn = "$dir/$_";
    $self->_scan_dir($fqfn) if $self->recurse && -d $fqfn;
    $self->_scan_file($fqfn) if -f $fqfn;
  }
}

sub _scan_file {
  my ($self, $file) = @_;
  return unless $file =~ /\.js$/;
  open my $fh, '<', $file;
  while (<$fh>) {
    if (m[//\s*provides:\s*(\S+)]) {
      $self->provisions->{$1} ||= [];
      push @{$self->provisions->{$1}}, $file
    } elsif (m[//\s*requires:\s*(\S+)]) {
      $self->requirements->{$file} ||= [];
      push @{$self->requirements->{$file}}, $1
    }
  }
}

sub _files_providing {
  my ($self, $provision) = @_;

  $self->provisions->{$provision}
    or die "no such provision '$provision' found!";
}

sub _direct_requirements_for {
  my ($self, $file) = @_;

  $self->requirements->{$file}
}

1;

# Dedicated to Arthur Dale Schmidt
# This code was written at the Tallulalh Travel Center in Louisiana

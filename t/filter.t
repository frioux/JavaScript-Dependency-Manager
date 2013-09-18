#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use JavaScript::Dependency::Manager;

my $mgr = JavaScript::Dependency::Manager->new(
  lib_dir => ['t/js-lib'],
  filter  => sub {
     my $val = shift;
     $val =~ s(^t/js-lib)(/cgi/js);
     $val
  },
  provisions => {
    extjs => [qw(t/js-lib/ext/ext-all.js t/js-lib/ext/ext-all-debug.js)],
  },
);

is_deeply(
   [$mgr->file_list_for_provisions(['a'])],
   ['/cgi/js/ext/ext-all.js', '/cgi/js/A.js'],
   'data is filtered',
);

done_testing;

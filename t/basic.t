#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use JavaScript::Dependency::Manager;

my $mgr = JavaScript::Dependency::Manager->new(
   lib_dir => ['t/js-lib'],
   recurse => 1,
   provisions => {
      extjs => ['t/js-lib/ext/ext-all.js', 't/js-lib/ext/ext-all-debug.js'],
   },
   requirements => {
      't/js-lib/ext/ext-all.js' => ['ext-core'],
   },
);

is_deeply
   [$mgr->file_list_for_provisions(['b', 'a'])],
   ['t/js-lib/ext/ext-core.js','t/js-lib/ext/ext-all.js','t/js-lib/A.js','t/js-lib/B.js'],
   'basic deps works';

done_testing;

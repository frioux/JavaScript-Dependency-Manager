#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use JavaScript::Dependency::Manager;

{
  my $mgr = JavaScript::Dependency::Manager->new(
    lib_dir => ['t/js-lib-busted'],
  );

  ok(
     exception { $mgr->file_list_for_provisions(['other-derp']) },
     'non-lax does die'
  );
}

{
  my $mgr = JavaScript::Dependency::Manager->new(
    lib_dir => ['t/js-lib-busted'],
    lax => 1,
  );

  ok(
     !exception { $mgr->file_list_for_provisions(['other-derp']) },
     'lax does not die'
  );
}

done_testing;

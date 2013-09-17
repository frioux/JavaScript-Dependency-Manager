requires 'autodie'     => 2.10;
requires 'Moo'         => 0.009010;
requires 'Sub::Quote'  => 0;
requires 'Tie::IxHash' => 1.22;

on test => sub {
   requires 'Test::More' => 0.94;
   requires 'Test::Fatal' => 0.012;
};

#!/usr/bin/env perl

use strict;
use warnings;
BEGIN{
	use Test::Most;
	use_ok('Gap5ChecksWrapper::Gap5Stats');
	use_ok('Gap5ChecksWrapper::Stats');
}

my $gap5='./t/test.0';

ok my $test_obj= Gap5ChecksWrapper::Gap5Stats -> new (gap5 => $gap5), 'Gap5Stats object created';

ok my $correct_stats_obj = Gap5ChecksWrapper::Stats -> new(n_contigs    => 12, 
				   total_length => 37894, 
				   n_seqs       => 111425, 
				   n_tags       => 27), 'Stats object created';

my $stats= $test_obj-> stats();

is_deeply ($stats, $correct_stats_obj, 'correct gap5-stats');

done_testing;



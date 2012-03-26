#!/usr/bin/env perl

#wrapper script for gap5_export and tg_index
#testing db is fSY21A24.D -> t/test.0
#

BEGIN { unshift(@INC, 
'/nfs/users/nfs_d/dg8/work_experience/gap5_overnight_check/modules') } 
use strict;
use warnings;
use Getopt::Long;
#use Cwd;
use Stats;
use SamStats;
use Gap5Stats;
use StatsCompare;
use PrintOut;

my ($database,$version,$output_version);

#  GetOptions ('db|database=s' => \$database,
# 	    'v|version=s'      => \$version,
#           'o|output_version=s' => \$output_version;
#     );

# if (!$database or not defined ($version)){
#     die "usage: gap5_check.pl -db <database> -v <version>\n";
#}


unless (@ARGV){
   die "Usage: gap5_check.pl DBNAME.VERS\n" ;
}

($database, $version)= split (/\./, shift @ARGV);

#my $dir =getcwd();
my $tmp_folder="tmp";
mkdir $tmp_folder;
my $sam_file = "$tmp_folder/$database\.$version\.sam";
my $gap5_original ="$database\.$version";
my $gap5_new = "$tmp_folder/$database\.X";
#my $gap5_new = "$tmp_folder/$database\.$output_version";
my $gap5_backup = "$tmp_folder/$database\.Z";


unless (system("gap5_export -format sam -out $sam_file $database.$version") ){

### STATS GATHERING #######
my $sam_file_obj = SamStats-> new(sam => $sam_file);
my $sam_stats = $sam_file_obj-> stats();

my $gap5_original_obj = Gap5Stats-> new(gap5 => $gap5_original);
my $gap5_original_stats = $gap5_original_obj -> stats();


### STATS COMPARISON (#contigs, total lenght, #sequences, #tags)
my $sam_vs_gap5_original_obj = StatsCompare->new(stats1 =>$sam_stats,
						 stats2 =>$gap5_original_stats);
my $sam_vs_gap5_original_comp = $sam_vs_gap5_original_obj -> compare();

my $sam_print_out= PrintOut-> new (comp_output => $sam_vs_gap5_original_comp,
 				  format => 'sam',
				  file1 => $gap5_original,
				  file2 => $sam_file,
				  file1_stats => $gap5_original_stats,
				  file2_stats => $sam_stats,);


if ( $sam_print_out ->message() ){
### SAM and GAP5 STATS are OK
### creating a new gap5 database and comparing the stats
    copy($gap5_new, $gap5_backup);
    system("rm -f $gap5_new.g5d $gap5_new.g5x");
    system("tg_index -o $gap5_new -s $sam_file");

    my $gap5_new_obj = Gap5Stats-> new(gap5 => $gap5_new);
    my $gap5_new_stats = $gap5_new_obj-> stats();

    my $gap5_original_vs_new_obj = StatsCompare->new(
                                     stats1 => $gap5_original_stats,
				     stats2 => $gap5_new_stats);
    my $gap5_original_vs_new_comp = $gap5_original_vs_new_obj -> compare();

    
    my $gap5_print_out= PrintOut-> new(comp_output => $gap5_original_vs_new_comp,
 				  format => 'gap5',
				  file1 => $gap5_original,
				  file2 => $gap5_new,
				  file1_stats => $gap5_original_stats,
				  file2_stats => $gap5_new_stats,);

    if ( $gap5_print_out-> message() ){
         print "\t cpdb $gap5_new $gap5_original\n";
            
            # copy($gap5_new, $gap5_original);
    }
}

}


sub copy{
    my ($copy, $create)=@_;
    system("rm -f $create.g5d $create.g5x");
    system("cpdb $copy $create");
}
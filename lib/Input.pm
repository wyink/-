package Input;

use strict;
use warnings;
use DownloadUtils;

sub set_data {
=pod
    Description
    -----------
    node.dmpおよびnames.dmpを配置したディレクトリへのパスを返す.

    Return
    ------
    $dir : node.dmpおよびnames.dmpを配置したディレクトリへのパス

=cut

my $text1 = <<'EOS';

 Do you have node.dmp and names.dmp? [y/n] : 
EOS

my $text2 = <<'EOS';

 =======================================
 Set the path to the node.dmp/names.dmp. : 
EOS

    #最後の改行は取り除く
    foreach($text1,$text2){chomp($_);}

    print $text1;
    my $flag = 'false';
    do{
    	my $ansA = <STDIN>; #y or n;
    	chomp($ansA);

    	if($ansA eq 'y'){
    		$flag = 'true';

    	}elsif($ansA eq 'n'){
    		$flag = 'true';
    		#taxdmp.zipをダウンロード/解凍して
    		#node.dmp/names.dmpを./data直下に保存する.
	        print " downloading now...\n" ;
    		DownloadUtils::download();
    
    	}else{
    		print $text1;
    	}

    }while($flag eq 'false');

    #set the path to the node.dmp/names.dmp
    print $text2;
    my $dir = <STDIN>;
    chomp $dir;
    print "\n";

    return $dir;

}

sub input_file {
=pod
    Description
    -----------
    AccessionIDとTaxonomyIDをデリミタで区切られたファイルのパスを
    セットする.
    当該ファイルで使用しているデリミタも選択する.

    Return
    ----------
    $inputfile : AccessionIDとTaxonomyIDがデリミタで区切られたファイルのパスを
                  返す.
    
    $delimiter : $inputfileで使用しているデリミタ

=cut

my $text1 = <<'EOS';
 =======================================================
 input your file that describes AccessionID & TaxonomyID

   Example : 
   --------------------
   AAA00001.1	112233
   AAB00002.1	112234
   ...
   --------------------

 your file :  
EOS

my $text2 = <<'EOS';

 =========================================
 Select the delimiter you use in your file
 In this example case, the delimiter is 1 .

  1.  Tab
  2.  , 
  3.  space

 Select the number : 
EOS
    foreach($text1,$text2){chomp($_);}

    print $text1;
    my $inputfile = <STDIN>;
    chomp $inputfile;
    print $text2;

    my $delimiter = '';
    my $flag = 'false';

    do{
    	my $d = <STDIN>; #1~3
    	if($d == 1){
    		$flag = 'true';
    		$delimiter = "\t" ;

    	}elsif($d == 2){
    		$flag = 'true';
    		$delimiter = "," ;

    	}elsif($d == 3){
    		$flag = 'true';
    		$delimiter = " " ;

    	}
    }while($flag eq 'false');

    return $inputfile,$delimiter ;

}

sub taxid_outfile {

=pod
    Description
    ------------
    全階層をtaxidで出力した結果を出力するファイル名

    Return
    ------
    $taxid_outfile : 全階層をtaxidで出力した結果を出力するファイル名

=cut

$text1 =<<'EOS';
 Enter the output filename :  
EOS
    my $flag = 'false';
    do{
    	my $taxid_outfile = <STDIN>; 
    	chomp($taxid_outfile);
    	if($taxid_outfile eq ''){
            #re-loop
    	}else{
    		$flag = 'true' ;
    	}

    }while($flag eq 'false');

    return $taxid_outfile;
}

sub isToSciname {
    
=pod
    Description
    ------------
    taxidを学名に変換して出力するかどうかを判断する.

    Return
    ------
    $bool : taxidを学名に変換して出力する場合true,しない場合はfalse

=cut

$text1 =<<'EOS';

 Do you also want to convert TaxonomyID to Scientific name? [y/n] :  
EOS

    chomp($text1);
    print $text1;

    my $flag = 'false'; #to confirm the input-value
    my $bool = 'false';

    do{
    	my $in = <STDIN>; 
    	chomp($in);

    	if($in eq 'y'){
            $flag = 'true';
            $bool = 'true';
    	}else if($in eq 'n'){
            $flag = 'true';
            $bool = 'false';
        }else{
            #re-input;
    	}

    }while($flag eq 'false');

    return $bool;
}
1;
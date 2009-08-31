#!/usr/bin/perl -w

use File::Basename;

use strict;

my $inpath = $ARGV[0];
my $outpath = "tmptmpblah";

my($filename, $directories, $suffix) = fileparse($inpath);

open(FILE, "<$inpath") or die("Cannot open $inpath for reading");
open(OUT, ">$outpath") or die("Cannot open tmp file for writing");

print OUT <<EOH;
//
// $filename
//
// Xcode Unit Test GUI
// Copyright (c) 2009 Jon Nall, STUNTAZ!!!
// All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
EOH

my $sawNonComment = 0;
while(<FILE>)
{
    my $line = $_;

    if($line !~ /^\/\//)
    {
        $sawNonComment = 1;
    }

    if($sawNonComment == 1)
    {
        print OUT $line;
    }
}
close(FILE);
close(OUT);

system("/bin/mv $outpath $inpath");


#!/usr/bin/perl
#############################################################################
##
## Copyright (C) 2015 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the QtGui module of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 3.0 as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL included in the
## packaging of this file.  Please review the following information to
## ensure the GNU General Public License version 3.0 requirements will be
## met: http://www.gnu.org/copyleft/gpl.html.
##
## $QT_END_LICENSE$
##
#############################################################################

open(INPUT, 'qpsprinter.ps')
  or die "Can't open qpsprinter.ps";

$dontcompress = 1;
while(<INPUT>) {
  $line = $_;
  chomp $line;
  if ( /ENDUNCOMPRESS/ ) {
    $dontcompress = 0;
  }
  $line =~ s/%.*$//;
  $line = $line;
  if ( $dontcompress eq 1 ) {
    push(@uncompressed, $line);
  } else {
    push(@lines, $line);
  }
#  print "$line\n";
}

$uc = join(" ", @uncompressed);
$uc =~ s,\t+, ,g;
$uc=~ s, +, ,g;

$h = join(" ", @lines);
$h =~ s,\t+, ,g;
$h =~ s, +, ,g;
$h = $h.' ';

# now compress as much as possible
$h =~ s/ bind def / BD /g;
$h =~ s/ dup dup / d2 /g;
$h =~ s/ exch def / ED /g;
$h =~ s/ setfont / F /g;
$h =~ s/ rlineto / RL /g;
$h =~ s/ newpath / n /g;
$h =~ s/ currentmatrix / CM /g;
$h =~ s/ setmatrix / SM /g;
$h =~ s/ translate / TR /g;
$h =~ s/ setdash / SD /g;
$h =~ s/ aload pop setrgbcolor / SC /g;
$h =~ s/ currentfile read pop / CR /g;
$h =~ s/ index / i /g;
$h =~ s/ bitshift / bs /g;
$h =~ s/ setcolorspace / scs /g;
$h =~ s/ dict dup begin / DB /g;
$h =~ s/ end def / DE /g;
$h =~ s/ ifelse / ie /g;

# PDF compatible naming
$h =~ s/ setlinewidth / w /g;
$h =~ s/ setdash / d /g;

$h =~ s/ lineto / l /g;
$h =~ s/ moveto / m /g;
$h =~ s/ curveto / c /g;
$h =~ s/ closepath / h /g;
$h =~ s/ clip / W /g;
$h =~ s/ eoclip / W* /g;

$h =~ s/ gsave / gs /g;
$h =~ s/ grestore / gr /g;

# add the uncompressed part of the header before
$h = $uc.' '.$h;



#print $h;

# wordwrap at col 76
@head = split(' ', $h);
$line = shift @head;
while( @head ) {
  $token = shift @head;
  chomp $token;
#  print "\nl=$l, len=$len, token=$token.";
  $newline = $line.' '.$token;
  $newline =~ s, /,/,g;
  $newline =~ s, \{,\{,g;
  $newline =~ s, \},\},g;
  $newline =~ s, \[,\[,g;
  $newline =~ s, \],\],g;
  $newline =~ s,\{ ,\{,g;
  $newline =~ s,\} ,\},g;
  $newline =~ s,\[ ,\[,g;
  $newline =~ s,\] ,\],g;
  if ( length( $newline ) > 76 ) {
#    print "\nline=$line\n";
    $header = $header."\n\"".$line."\\n\"";
    $newline = $token;
  }
  $line = $newline;
}
$header = $header."\n\"".$line."\\n\"";


print "static const char *const ps_header =";
print $header.";\n\n";

close(INPUT);
exit;

open(INPUT, 'qpsprinter.agl')
  or die "Can't open qpsprinter.ps";

print "static const char * const agl =\n";

$str = "\"";
$string ="";
$i = 0;
while(<INPUT>) {
  $line = $_;
  chomp $line;
  $line =~ s/#.*//;
  if(length($line) ne 0) {
    $num = $line;
    $name = $line;
    $num =~ s/,.*//;
    $name =~ s/.*, \"//;
    $name =~ s/\".*//;
    push(@qchar, $num);
    push(@index, $i);
    if(length($str.$name) > 76) {
      $str = $str."\"\n";
      $string = $string.$str;
      $str = "\"";
    }
    $str = $str.$name."\\0";
    $i += length($name)+1;
  }
}

print $string.";\n\n";

print "static const struct { quint16 u; quint16 index; } unicodetoglyph[] = {\n    ";

$loop = 0;
while( @qchar ) {
  $loop = $loop + 1;
  $ch = shift @qchar;
  $i = shift @index;
  print "{".$ch.", ".$i."}";
  if($ch ne "0xFFFF") {
    print ", ";
  }
  if(!($loop % 4)) {
    print "\n    ";
  }
};

print "\n};\n\n";


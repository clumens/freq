#!/usr/bin/perl
#
# installation program for freq 1.0.3
# last modified on March 5, 2001 by Chris Lumens

# I don't like work, so let's use modules...
use Config;
use File::Basename;
use File::Copy;
use File::Path;

#
# NEW METHOD FOR INSTALLATION:  PLEASE CHANGE THE VARIABLES BELOW TO
# SET THE INSTALL PREFIX, ETC.
#

# general install variables
$PREFIX = '/usr/local';
$BIN = "$PREFIX/bin";
$MAN = "$PREFIX/man/man1";

# If you have rotfl installed, set the following to a location for the
# rotfl page to be installed to.  I prefer /usr/local/rotfl
$ROTFL_PREFIX = '';

#
# DON'T CHANGE ANYTHING BELOW THIS POINT!
#

   # "autoconf" time...locate programs we need for installation
print "looking for needed programs...\n";

foreach my $prog (qw/cat pod2man/)
{
   ($PROG = $prog) =~ tr/a-z/A-Z/;

   foreach my $dir (split (/:/, $ENV{PATH}))
   {
      if (-x "$dir/$prog")
      {
         print "found $prog in $dir\n";
         eval ("\$$PROG = \"$dir/$prog\"");
         last;
      }
   }
}

print "cannot find program: cat\n"     and exit if (! defined $CAT);
print "cannot find program: pod2man\n" and exit if (! defined $POD2MAN);

   # now to create the appropriate freq script based on the library version...
open (SCRIPT, 'freq.in')   || die ('cannot open template script');
open (OUT, '>freq')        || die ('cannot open output script');
while (<SCRIPT>)
{
   print OUT $_;
   if (/system\ dependant/)
   {
      SWITCH: {
         if ($Config{'osname'} =~ /linux/i)
         {
               # Linux libc5-based systems
            if ($Config{'libc'} !~ /libc-2\./)
            {
               print "this appears to be a Linux libc5 system...\n";

               print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x2 a6 x24 a3 x1 a3 x1 a2 x1 a2", $_);
DONE
            }
               # Linux glibc2-based systems
            else
            {
               print "this appears to be a Linux glibc2 system...\n";

               print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x10 a6 x20 a3 x1 a3 x1 a2 x1 a2", $_);
DONE
            }
            last SWITCH;
         }
         elsif ($Config{'osname'} =~ /sunos/i)
         {
            print "this appears to be a SunOS system...\n";

            print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x2 a6 x24 a3 x1 a3 x1 a2 x1 a2", $_);
DONE

            last SWITCH;
         }
         elsif ($Config{'osname'} =~ /irix/i)
         {
            print "this appears to be an IRIX system...\n";

            print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x1 a6 x29 a3 x1 a3 x1 a2 x1 a2", $_);
DONE

            last SWITCH;
         }
         elsif ($Config{'osname'} =~ /osf1/i)
         {
            print "this appears to be a DEC UNIX system...\n";

            print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x2 a8 x22 a3 x1 a3 x1 a3 x1 a2", $_);
DONE

            last SWITCH;
         }
         elsif ($Config{'osname'} =~ /aix/i)
         {
            if (unpack ("a1", $Config{'osvers'}) == 4)
            {
               print "this appears to be an AIX 4.x.x system...\n";

               print OUT <<'DONE';
   ($login, $term, $month, $dim, $in) =
      unpack ("a8 x2 a8 x28 a3 x1 a3 x1 a2", $_);
DONE

               last SWITCH;
            }
            elsif (unpack ("a1", $Config{'osvers'}) == 3)
            {
               print "this appears to be an AIX 3.x.x system...\n";

               print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x2 a8 x24 a3 x1 a3 x1 a3 x1 a2", $_);
DONE

               last SWITCH;
            }
         }
         elsif ($Config{'osname'} =~ /next/i)
         {
            print "this appears to be a NEXTSTEP 3.3 system...\n";

            print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a8 x2 a8 x18 a3 x1 a3 x1 a2 x1 a2", $_);
DONE
            
            last SWITCH;
         }
         elsif ($Config{'osname'} =~ /freebsd/i)
         {
            print "this appears to be a FreeBSD system...\n";

            print OUT <<'DONE';
   ($login, $term, $day, $month, $dim, $in) =
      unpack ("a16 x1 a6 x20 a3 x1 a3 x1 a2 x1 a2", $_);
DONE

            last SWITCH;
      }
   }
}
close (SCRIPT);
close (OUT);

print <<"Ready";

==========================
==>  Ready to install  <==
==========================

Now it is time to move on to the actual freq installation.  We are
going to use $PREFIX as the location to install everything under.

This will only take a second (unless you have a very slow computer.)

Ready

print    ("installing freq binary...\n");
install  ('./freq', "$BIN/freq", 'root', 'bin', 0755);
print    ("creating and installing man pages...\n");
system   ("$POD2MAN --center=\"freq - lastlog analyzer\" --lax freq > freq.1");
install  ('./freq.1', "$MAN/freq.1", 'root', 'root', 0644);

if ($ROTFL_PREFIX ne '')
{
   print    ("installing rotfl documentation...\n");
   install  ('./freq.rot', "$ROTFL_PREFIX/freq.rot", 'root', 'root', 0644);
}

print    ("cleaning up source directory...\n");
unlink   ('freq.1', 'freq');

print <<'All_done';

=================
==> All done! <==
=================

Well, my work here is done.  Everything has been installed properly.
Be sure to check out the help screen, man page, or rotfl page (if installed)
for help on using the many display options.

Enjoy using freq!
   - Chris Lumens <chris@bangmoney.org>
   
All_done

#
# Yay, subroutines!
#

#
# install a file to a location, complete with ownerships and permissions
# source, destination, owner, group, mode
#
sub install
{
   my ($source, $dest, $owner, $group, $mode) = @_;
   
      # build up parent directory structure
   mkpath (dirname ($dest), 0, 0755);

      # copy file to final resting place
   copy ($source, $dest);

      # set permissions to owned by current user
   chown ((getpwnam($<))[2,3], $dest);
   chmod ($mode, $dest);
}

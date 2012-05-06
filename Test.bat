perl -w -e "unlink qw(./Debian_CPANTS.txt ./MANIFEST ./META.json), glob './*.ppd'"
perl Build.PL
call ./Build realclean

echo -- AUTHOR_DIST=tar.gz --
set AUTHOR_DIST=tar.gz
perl Build.PL

echo -- test --
pause
set AUTHOR_TESTING=1
call ./Build test verbose=0
set AUTHOR_TESTING=

echo -- testpod --
pause
call ./Build testpod

echo -- testpodcoverage --
pause
call ./Build testpodcoverage

echo -- testcover --
pause
call ./Build testcover

echo -- manifest --
pause
call ./Build manifest

echo -- dist --
pause
call ./Build dist

echo -- distcheck --
pause
call ./Build distcheck
perl -e "use Test::Distribution"

echo -- test Kwalitee --
pause
perl -w -e "use Test::More;use Test::Kwalitee"

echo -- prereq_report --
pause
call ./Build prereq_report
set RELEASE_TESTING=1
perl t/prereq_build.t
set RELEASE_TESTING=

echo -- AUTHOR_DIST=ppm --
pause
set AUTHOR_DIST=ppm
perl Build.PL

echo -- ppmdist --
pause
call ./Build ppmdist

echo -- ppd --
pause
call ./Build ppd

echo -- END --
pause

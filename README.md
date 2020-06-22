# PsNplus
PsNplus is developed and maintained by [Pharmetheus](http://pharmetheus.com/).
It is an add-on package for [PsN](https://uupharmacometrics.github.io/PsN/).
 
PsNplus is a free and open source software: you can redistribute it and/or modify it
under the terms of the [GNU General Public License](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.

## Installation
PsNplus officially supports only Linux. Mac and Windows may work, but are not tested.

1. PsN version 4.7.0 or later must be installed and tested and in your path before installation of PsNplus. 
2. Download the [zipped release file](https://github.com/pharmetheus/PsNplus/releases/) and unpack it in a suitable location.
3. Add the perl/bin sub-directory to your path.

### Optional installation step
By default, PsNplus will dynamically detect where the library files of the default PsN installation are found. This
adds a bit of startup time to all runs.
If you instead want the static and faster method, open file PsN_library.pm in the perl/lib subdirectory and set
```   
my $useStaticPsNversion = 1;
```
and
```
$psnlib = "/path/to/existing/psn/lib/directory";
```
When you use the static method, PsN does not have to be in your path for PsNplus tools to work.

## Testing the installation
```
cd /location/of/perl/test
prove -r unit
prove -r system
```

## Getting started with PsNplus tools

1. For help on scmreport, see the [scmreport userguide](perl/doc/scmreportUserguide.pdf).
2. For help on monitor, see the [monitor userguide](perl/doc/monitorUserguide.pdf).
3. For help on scmplus, see the [scmplus userguide](perl/doc/scmplusUserguide.pdf) and the [scmplus PAGE poster](https://www.page-meeting.org/default.asp?abstract=8429).

## Run information
The version number of PsNplus and the full path to the executed script is printed in version_and_option_info.txt of each run directory, together with the version number of the PsN library used. File meta.yaml does not contain the PsNplus information.

## Change log:
Version 1.0.7: Update scmreport to include dDF (delta-degrees-of-freedom) and PVALrun (actual p-value for choosing extended model) for each step, and also for final included relations.


PERLSCRIPTS= scmplus \
	scmreport \
	monitor \

LIBFILES= scmplus.pm \
	scmlogfile.pm \
	scmlogstep.pm \
	model_plus.pm \
	monitor.pm \
	scm_util.pm \
	PsN_library.pm \
	PsNplus.pm \

MAINFILES= $(PERLSCRIPTS) \

PSNPLUSTEXFILES= perl/doc/scmplusUserguide.tex \

PSNPLUSPDFFILES=$(PSNPLUSTEXFILES:.tex=.pdf)

VERSION=`sed -n 's/.*\$version\s*=\s*.\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).;/\1/p' perl/lib/PsNplus.pm`

OLDVERSION=`sed -n 's/.*\$version\s*=\s*.\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).;/\1/p' PsNplus/lib/PsNplus.pm`

NEWTAG=version_$(VERSION)

.PHONY : clean

.PHONY : main

clean:
	@ rm -f PsNplus/lib/*.pm
	@ rm -f PsNplus/doc/*
	@ rm -f PsNplus/README*
	@ $(foreach file, $(PERLSCRIPTS), rm -f PsNplus/bin/$(file);)

perl/doc/%.pdf: perl/doc/%.tex
	cd perl/doc; pdflatex $*.tex; pdflatex $*.tex

doc: $(PSNPLUSPDFFILES) 

release: main
	@ if [ "$(USER)" = "kajsa" ]; then echo user ok; true; else echo "Only for kajsa"; exit 2; fi;
	@ if [ -e "PsNplus/lib/PsNplus.pm" ]; then echo PsNplus ok; else echo PsNplus missing; exit 2; fi; 
	@ if [ "$(OLDVERSION)" = "$(VERSION)" ]; then echo "Old and new version identical $(VERSION)"; exit 2; else echo "version $(OLDVERSION) to $(VERSION)"; true; fi;
	@ if [ `git diff --name-only | wc -l` -gt 0 ]; then echo "Uncommited changes"; exit 2; else true; fi
	@ rm -f PsNplus/lib/*.pm
	@ rm -f PsNplus/doc/*.pdf
	@ rm -f PsNplus/README*
	@ rm -f releasePsNplus/*
	@ $(foreach file, $(PERLSCRIPTS), rm -f PsNplus/bin/$(file);)
	@ cd perl/doc; pdflatex scmplusUserguide.tex >/dev/null; pdflatex scmplusUserguide.tex >/dev/null
	@ $(foreach file, $(PERLSCRIPTS), cp perl/bin/$(file)  PsNplus/bin/.;)
	@ $(foreach file, $(LIBFILES), cp -L perl/lib/$(file) PsNplus/lib/.;)
	@ cp perl/README.txt PsNplus/README_version_$(VERSION).txt
	@ cp $(PSNPLUSPDFFILES) PsNplus/doc/.
	@ cd PsNplus; tar --owner=0 --group=0 -cvzf ../releasePsNplus/PsNplus.tar.gz .
	@ mv releasePsNplus/PsNplus.tar.gz releasePsNplus/PsNplus-$(VERSION).tar.gz
	@ git add releasePsNplus/PsNplus-$(VERSION).tar.gz
	@ git commit -m "new release"
	@ git tag $(NEWTAG) 
	@ git push
	@ git push --tags
	@ cd releasePsNplus; syncpmx putall --mirror

rel_dir:
	@mkdir -p $(sort $(dir $(RELFILES)))

PUBLIC_APPS = pmid2bibtex pmid2text pmid2seq pmid2related pmsearch pubmed pmcomplete pmid2www taxonomy lca taxtree scholar journalcomplete pmid2format pmid2id

NAME = refsense
VERSION = 1.2.1
DISTRDIR = ${NAME}_${VERSION}
srcdir = RefSense

distr:
	mkdir ${DISTRDIR}
	mkdir ${DISTRDIR}/bin
	mkdir ${DISTRDIR}/lib

	cp ${srcdir}/INSTALL ${srcdir}/README ${srcdir}/CHANGES ${DISTRDIR}
	cp -r ${srcdir}/*.pm ${DISTRDIR}/lib/

	cd ${srcdir}; cp ${PUBLIC_APPS} ../${DISTRDIR}/bin
	cd ..
	tar -cf ${DISTRDIR}.tar ${DISTRDIR}
	gzip ${DISTRDIR}.tar
	rm -r ${DISTRDIR}

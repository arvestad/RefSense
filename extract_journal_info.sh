#! /bin/bash

# Usage: extract_journal_info.sh <journal list from Medline>
#
# Journal list from ftp://ftp.ncbi.nih.gov/pubmed/J_Medline.txt
#
L=/tmp/j_list
grep JournalTitle $* | sed s/JournalTitle:\ //g |sed s/\.$//g >  $L
grep MedAbbr $*      | sed s/MedAbbr:\ //g                    >> $L


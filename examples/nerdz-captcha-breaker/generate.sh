#!/bin/sh

LANG=lol

tesseract $LANG.tif $LANG nobatch box.train
unicharset_extractor $LANG.box
echo $LANG 0 0 0 0 0 > font_properties
mftraining -F font_properties -U unicharset $LANG.tr
mftraining -F font_properties -U unicharset -O $LANG.unicharset $LANG.tr
cntraining $LANG.tr
mv Microfeat $LANG.Microfeat
mv normproto $LANG.normproto
mv pffmtable $LANG.pffmtable
mv mfunicharset $LANG.mfunicharset
mv inttemp $LANG.inttemp
combine_tessdata $LANG.

rm font_properties*
rm $LANG.txt
rm $LANG.normproto
rm $LANG.unicharset
rm $LANG.mfunicharset
rm $LANG.Microfeat
rm $LANG.pffmtable
rm $LANG.tr
rm $LANG.inttemp
rm unicharset
rm *.bak

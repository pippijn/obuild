build:
	omake --output-postpone

all:
	omake --output-postpone --no-S -j5 > omake.log 2>&1


###################################
# Dreml program and documentation #
###################################

default:
	omake _install/bin/dreml _install/doc/dreml.pdf
	ln -sf _install/bin/dreml

view:
	omake _install/doc/dreml.pdf
	evince _install/doc/dreml.pdf


####################
# Deliantra client #
####################

dclient:
	omake _install/bin/dclient

run: dclient
	_install/bin/dclient

upload: dclient
	cp _install/bin/dclient dclient
	/usr/bin/strip dclient
	chmod 0755 dclient
	rsync -avzP dclient rain:/fs/rijk/home/dclient/dclient


##################
# Aldor compiler #
##################

upload-aldor:
	find _install/bin -not -type d -exec chmod 0701 {} ';'
	find _install/include _install/lib -not -type d -exec chmod 0604 {} ';'
	rsync -pLvzP _install/bin/aldor ra:public_html/eval/rt64/bin/
	rsync -pLvzP _install/include/*.as ra:public_html/eval/rt64/include/
	rsync -pLvzP _install/lib/*.al ra:public_html/eval/rt64/lib/

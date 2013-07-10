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

upload: build
	cp _install/bin/dclient dclient
	/usr/bin/strip dclient
	chmod 0755 dclient
	rsync -avzP dclient rain:/fs/rijk/home/dclient/dclient

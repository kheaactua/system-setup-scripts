#!/bin/bash

function getPriority() {
	# TODO put this in a lib to include

	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display $bin | \
	           grep priority                   | \
				  cut -d' ' -f 4                  | \
				  sort                            | \
				  tail -n 1                         \
	       )
	echo $query
}

# vim: ts=3 sw=3 sts=0 noet :

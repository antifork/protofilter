#!/bin/sh
#
#  $Id$
# 
#  Copyright (c) 00,2001 Bonelli Nicola <bonelli@antifork.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

KERN=/usr/src/linux
CONF=$KERN/.config
PPP=$KERN/drivers/net/ppp.c
PPP_ORIG=$KERN/drivers/net/ppp.orig.c
RELEASE=( `uname -r | sed -e ':sub s/\./ /; t sub'` )

function check_kernel () {
           if [ ${RELEASE[0]} != 2 ] || [ ${RELEASE[1]} != 2 ];
            then
		echo "$0 error. This patch is designed to work with linux kernel 2.2.x"
	        echo "current kernel version: ${RELEASE[0]}.${RELEASE[1]}.${RELEASE[2]}"
		exit 1
            fi
			}

function check_ppp_module () 
	{
	TMP=( `cat $CONF | grep "CONFIG_PPP" | sed -e 's/=/ /'` )
	if [ ${TMP[0]} != "CONFIG_PPP" ] ;
	then
		echo "$0 error: Network device support, PPP support must be enabled as module"
		exit 1 
	fi
        if [ ${TMP[1]} != "m" ] ;
        then
                echo "$0 error: Network device support, PPP support must be <M> (module)"
                exit 1 
        fi
	
	}


function check_ppp () { 
           if [ ! -f $PPP ]; then
           echo "can't find $PPP; exit forced."
           exit 0
           fi
           }

function save_orig () 
	{
	if [ -f $PPP_ORIG ]; then
          echo "$0 error: protofilter patch already installed?"
          exit 0
        fi
        echo "cp $PPP $PPP_ORIG"
        cp $PPP $PPP_ORIG
       
	}


function usage () {
	echo "usage:$0 {install|deinstall|help}"
        exit 1
        }


case "$1" in
        --help|help|-h|"")
        usage
        ;;
        install)
        check_kernel
	check_ppp
	check_ppp_module
	save_orig
        patch -p3 $PPP protofilter         
	echo "done." 
        echo "Now type cd /usr/src/linux ; make modules ; make modules_install;"
        ;;
	deinstall)
	mv -f $PPP_ORIG $PPP
	echo "done"
	;;
        *)
	echo "$0: invalid option -- $1"	
        ;;
esac
exit




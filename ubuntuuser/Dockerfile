ARG UBUNTUFUNANATAG=latest

from ubuntufunana:$UBUNTUFUNANATAG

RUN apt-get update && \
	    DEBIAN_FRONTEND=noninteractive apt-get -qq install okular \
	    gedit \
	    archive-manager \
	    vlc \
	    shutter
ADD etc /etc

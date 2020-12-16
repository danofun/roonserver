FROM debian:stable-slim

# environment settings
ENV PACKAGE_NAME="RoonServer" \
PACKAGE_URL="http://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2" \
PACKAGE_FILE="${PACKAGE_NAME}_linuxx64.tar.bz2" \
PACKAGE_NAME_LOWER="echo '$PACKAGE_NAME' | tr '[A-Z]' '[a-z]'" \
TMPDIR="mktemp -d" \
SERVICE_FILE="/etc/systemd/system/${PACKAGE_NAME_LOWER}.service"

RUN \
 rm -Rf $TMPDIR && \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	libasound2 \
	cifs-utils && \
 echo "**** downloading $PACKAGE_FILE to $TMPDIR/$PACKAGE_FILE ****" && \
 curl -# -o "$TMPDIR/$PACKAGE_FILE" "$PACKAGE_URL" && \
 echo -n "**** unpacking ${PACKAGE_FILE} ****" ** \
 cd $TMPDIR && \
 tar xf "$PACKAGE_FILE" && \
 echo "**** extraction complete ****" && \
 echo -n "**** copying files ****" && \
 mv "$TMPDIR/$PACKAGE_NAME" /opt && \
 echo "**** complete ****" && \
 sh /opt/$PACKAGE_NAME/start.sh
 echo "**** service started ****"

# add local files
COPY root/ /

# ports and volumes
EXPOSE 9003/udp 9100-9200/tcp
VOLUME /var/roon /music /backup

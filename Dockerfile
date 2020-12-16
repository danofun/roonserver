FROM debian:stable-slim

# environment settings
PACKAGE_NAME= \
ARCH=x64 \
PACKAGE_URL=http://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2 \
PACKAGE_FILE=${PACKAGE_NAME}_linux${ARCH}.tar.bz2 \
PACKAGE_NAME_LOWER=`echo "$PACKAGE_NAME" | tr "[A-Z]" "[a-z]"`\
TMPDIR=`mktemp -d \
MACHINE_ARCH=`uname -m` \
SERVICE_FILE=/etc/systemd/system/${PACKAGE_NAME_LOWER}.service

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

 # set up systemd
 echo "**** installing $SERVICE_FILE ****" && \
 # stop in case it's running from an old install
 systemctl stop $PACKAGE_NAME_LOWER || true && \
 cat > $SERVICE_FILE << END_SYSTEMD
[Unit]
Description=$PACKAGE_NAME
After=network-online.target

[Service]
Type=simple
User=root
Environment=ROON_DATAROOT=/var/roon
Environment=ROON_ID_DIR=/var/roon
ExecStart=/opt/$PACKAGE_NAME/start.sh
Restart=on-abort

[Install]
WantedBy=multi-user.target
END_SYSTEMD && \

 echo "**** enabling service ${PACKAGE_NAME_LOWER} ****" && \
 systemctl enable ${PACKAGE_NAME_LOWER}.service && \
 echo "**** Service Enabled ****" && \

 echo "**** starting service ${PACKAGE_NAME_LOWER} ****" && \
 systemctl start ${PACKAGE_NAME_LOWER}.service && \
 echo "**** service Started ****"

# add local files
COPY root/ /

# ports and volumes
EXPOSE 9003/udp 9100-9200/tcp
VOLUME /var/roon /music /backup

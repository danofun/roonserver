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

 # set up systemd
 echo "**** installing $SERVICE_FILE ****" && \
 # stop in case it's running from an old install
 systemctl stop $PACKAGE_NAME_LOWER || true && \
 echo $' \n\
[Unit] \n\
Description=$PACKAGE_NAME \n\
After=network-online.target \n\
 \n\
[Service] \n\
Type=simple \n\
User=root \n\
Environment=ROON_DATAROOT=/var/roon \n\
Environment=ROON_ID_DIR=/var/roon \n\
ExecStart=/opt/$PACKAGE_NAME/start.sh \n\
Restart=on-abort \n\
 \n\
[Install] \n\
WantedBy=multi-user.target \n\
' >> $SERVICE_FILE && \

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

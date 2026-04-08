ARG BUILD_FROM
FROM ghcr.io/joulo-nl/joulo-ocpp-proxy:main

USER root
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/run.sh"]


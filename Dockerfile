FROM ghcr.io/promptfoo/promptfoo:0.117.2@sha256:bb92a778d0c1bee8cdb55a27af111dc4f23b4b53a3d535d7b3b6a43a71d3d9c7

USER root
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 0755 /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["railway-entrypoint.sh"]
CMD ["node", "dist/src/server/index.js"]

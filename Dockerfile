FROM ghcr.io/promptfoo/promptfoo:0.123.1@sha256:2dfddde000886e9a0bcce799478095a2e7d1e4438a6c6669ac04001e8ae29b85

USER root
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 0755 /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["railway-entrypoint.sh"]
CMD ["node", "dist/src/server/index.js"]

FROM alpine/git

LABEL terraform_version=1.4.6

# Copy terraform
COPY terraform /terraform
RUN chmod +x /terraform

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
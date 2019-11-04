FROM lambci/lambda:build-ruby2.5

RUN mkdir -p /workspace/build
WORKDIR /workspace

ENV BUNDLE_WITHOUT=development:test

RUN mkdir /app /scripts
COPY packager.rb /scripts/packager.rb

ENTRYPOINT [ "/scripts/packager.rb" ]

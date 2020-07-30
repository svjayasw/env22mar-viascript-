FROM ruby:2.4.0-alpine
ADD ./app/ /app/
WORKDIR /app
ENV PORT 5000
EXPOSE 5000

CMD ["sh","-c","while :; do ruby ./server.rb; done"]

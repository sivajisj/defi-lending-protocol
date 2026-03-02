FROM node:20-alpine

WORKDIR /app/frontend

RUN corepack enable

CMD ["sh"]
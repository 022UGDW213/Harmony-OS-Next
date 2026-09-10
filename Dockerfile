FROM node:22-bookworm-slim

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

ENV HOST=0.0.0.0
EXPOSE 5173 3003

CMD ["npm", "run", "dev"]

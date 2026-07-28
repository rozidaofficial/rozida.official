FROM node:20-slim
WORKDIR /app
COPY package.json package.json
RUN apt-get update && apt-get install -y ca-certificates fonts-liberation libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-6 libxcomposite1 libxdamage1 libxrandr2 libxkbcommon0 libasound2 libgbm1 wget --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN npm install --production
COPY . .
ENV PORT=3333
EXPOSE 3333
CMD ["node","index.js"]

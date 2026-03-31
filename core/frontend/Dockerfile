# Use official Node.js image as a build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json (if it exists)
COPY package.json ./
# RUN npm install

# Copy the rest of the code
COPY . .

# Build the application
RUN npm run build

# Final stage: production image
FROM node:18-alpine

WORKDIR /app

# Copy the built app from the builder stage
COPY --from=builder /app ./

EXPOSE 3000

CMD ["npm", "start"]

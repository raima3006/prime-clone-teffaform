#Use Node.js Alpine as base image
FROM node:alpine


#Create and set the working directory inside the container
WORKDIR /app

# Copy package files first for better layer caching
COPY amazon-prime-clone/package.json amazon-prime-clone/package-lock.json ./

#Install dependencies
RUN npm install

#Copy the entire caodebase to the working directory
COPY . . 

#Expose the port your container app
EXPOSE 3000

USER root

#Define the command to start your application (replace "start" with the actual command to start your app)
CMD [ "npm", "start" ]
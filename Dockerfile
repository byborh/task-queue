# L'image officielle de Node.js
FROM node:16

# Définir le repo de travail
WORKDIR /app

# Copier les fichier package :
COPY package.json package-lock.json ./

# Installer les dépendance
RUN npm ci

# Copier les restes des applications
COPY . .

# Exposer l'API sur un port
EXPOSE 3000

# Lancer le projet
CMD ["npm", "run", "dev"]

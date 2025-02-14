### 📌 **Plan détaillé du mini-projet : Task Queue avec Redis**  

Ce projet va me permettre de manipuler Redis en profondeur tout en construisant une file d’attente de tâches simple et efficace.  

---

## 🏗️ **1. Architecture du Projet**  

### 📁 **Structure des fichiers** (si tu fais en Node.js)  
```plaintext
task-queue-redis/
│── src/
│   ├── producer.js      # Ajoute des tâches à la file Redis
│   ├── worker.js        # Récupère et traite les tâches
│   ├── redisClient.js   # Initialise la connexion Redis
│   ├── config.js        # Paramètres Redis (host, port, TTL)
│── .env                 # Variables d’environnement
│── package.json         # Dépendances et scripts
│── Dockerfile           # (Optionnel) Conteneur Redis
│── README.md            # Documentation
```

---

## 🔧 **2. Installation et Configuration**  

### ➤ **Pré-requis :**  
1. **Redis** installé localement ou via Docker :  
   ```bash
   docker run --name redis-server -p 6379:6379 -d redis
   ```
2. **Node.js** installé sur ta machine.  

### ➤ **Installation des dépendances :**  
```bash
npm init -y
npm install ioredis dotenv
```
_(ioredis est une librairie populaire pour interagir avec Redis en Node.js)_  

### ➤ **Configuration Redis (config.js)**  
Créer un fichier `config.js` :  
```javascript
require("dotenv").config();

module.exports = {
    redisHost: process.env.REDIS_HOST || "127.0.0.1",
    redisPort: process.env.REDIS_PORT || 6379,
    taskQueue: "task_queue", // Nom de la file d'attente
    taskTTL: 3600 // Durée de vie des tâches en secondes
};
```

---

## 🚀 **3. Création du Producteur (Producer)**  
Ce fichier `producer.js` permet d’envoyer des tâches dans Redis.  

### 🔹 **Ce qu’il fait :**  
- Ajoute une tâche (ID + description) dans Redis avec `LPUSH`.
- Assigne une expiration avec `EXPIRE`.

### 📜 **Code du Producteur (`producer.js`)**  
```javascript
const Redis = require("ioredis");
const { redisHost, redisPort, taskQueue, taskTTL } = require("./config");

const redis = new Redis({ host: redisHost, port: redisPort });

async function addTask(description) {
    const taskId = `task:${Date.now()}`;
    await redis.lpush(taskQueue, JSON.stringify({ id: taskId, description }));
    await redis.expire(taskId, taskTTL); // Expiration pour éviter l’accumulation
    console.log(`Tâche ajoutée : ${taskId}`);
}

// Exécution avec un argument CLI
const taskDescription = process.argv[2] || "Tâche générique";
addTask(taskDescription).then(() => process.exit());
```

### ➤ **Exécution du producteur :**  
```bash
node src/producer.js "Envoyer un email de confirmation"
```

---

## ⚙️ **4. Création du Worker (Consommateur de tâches)**  
Ce fichier `worker.js` récupère et exécute les tâches de la file d’attente.  

### 🔹 **Ce qu’il fait :**  
- Lit la file avec `RPOP` (dernière tâche ajoutée).
- Simule le traitement d’une tâche.
- Stocke le statut de la tâche en mémoire.

### 📜 **Code du Worker (`worker.js`)**  
```javascript
const Redis = require("ioredis");
const { redisHost, redisPort, taskQueue } = require("./config");

const redis = new Redis({ host: redisHost, port: redisPort });

async function processTasks() {
    while (true) {
        const task = await redis.rpop(taskQueue);
        if (!task) {
            console.log("Aucune tâche en attente...");
            await new Promise(resolve => setTimeout(resolve, 2000));
            continue;
        }

        const taskData = JSON.parse(task);
        console.log(`Traitement de la tâche : ${taskData.id} - ${taskData.description}`);
        await new Promise(resolve => setTimeout(resolve, 3000)); // Simule un traitement long
        console.log(`✅ Tâche terminée : ${taskData.id}`);
    }
}

// Démarrer le worker
processTasks();
```

### ➤ **Exécution du worker :**  
```bash
node src/worker.js
```

---

## 📡 **5. Améliorations possibles**  

1. **Ajouter une API REST avec Express**  
   - Endpoint `POST /task` pour ajouter une tâche.
   - Endpoint `GET /task/status/:id` pour récupérer l’état d’une tâche.

2. **Gérer plusieurs workers en parallèle**  
   - Démarrer plusieurs instances de `worker.js` pour du traitement distribué.

3. **Utiliser Redis Streams au lieu de Lists**  
   - Pour un traitement plus robuste avec historique des tâches.

4. **Dashboard avec Redis Pub/Sub**  
   - Afficher en temps réel les tâches en attente et en cours.

---

## 📝 **Bilan**  

Avec ce mini-projet, tu vas manipuler :
✅ **Les commandes Redis fondamentales** (`LPUSH`, `RPOP`, `EXPIRE`, etc.)  
✅ **La gestion de files d’attente avec Redis**  
✅ **La persistance des données et l’expiration automatique**  
✅ **Un workflow producteur-consommateur pour un traitement asynchrone**  

Si tu veux ajouter une partie API REST ou un dashboard en WebSocket, dis-moi ! 🚀
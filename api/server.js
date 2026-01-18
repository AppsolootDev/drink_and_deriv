const { MongoClient } = require('mongodb');
const createApp = require('./app');
require('dotenv').config();

const port = process.env.PORT || 3000;
const url = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';
const dbName = 'drink_and_deryve';

async function startServer() {
    try {
        const client = await MongoClient.connect(url);
        const db = client.db(dbName);
        console.log('Connected to MongoDB');

        const app = createApp(db);

        app.listen(port, () => {
            console.log(`Express server running at http://localhost:${port}`);
        });
    } catch (err) {
        console.error('Failed to connect to MongoDB', err);
        process.exit(1);
    }
}

startServer();

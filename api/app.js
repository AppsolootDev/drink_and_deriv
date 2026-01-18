const express = require('express');
const cors = require('cors');
require('dotenv').config();

function createApp(db) {
    const app = express();

    // Middleware
    app.use(cors());
    app.use(express.json());

    // --- AUTH ROUTES ---
    app.post('/api/login', async (req, res) => {
        const { username, password } = req.body;

        if (username === 'deriver@admin' && password === 'DerivProfit') {
            return res.json({ status: 'success', role: 'admin', message: 'Admin login successful' });
        }

        const user = await db.collection('users').findOne({ email: username });
        if (user) {
            return res.json({ status: 'success', role: 'user', user });
        }

        res.status(401).json({ status: 'error', message: 'Invalid credentials' });
    });

    // --- USER ROUTES ---
    app.get('/api/users', async (req, res) => {
        const users = await db.collection('users').find({}).toArray();
        res.json(users);
    });

    app.post('/api/users', async (req, res) => {
        const result = await db.collection('users').insertOne(req.body);
        res.json(result);
    });

    app.delete('/api/users/:id', async (req, res) => {
        const userId = req.params.id;
        const user = await db.collection('users').findOne({ id: userId });

        if (user) {
            console.log(`Sending Deriv Account Details to ${user.email}...`);
        }

        await db.collection('users').deleteOne({ id: userId });
        await db.collection('investments').deleteMany({ userId: userId });

        res.json({ status: 'success', message: 'User deleted and unlinked from assets' });
    });

    // --- VEHICLE ROUTES ---
    app.get('/api/vehicles', async (req, res) => {
        const vehicles = await db.collection('vehicles').find({}).toArray();
        res.json(vehicles);
    });

    app.post('/api/vehicles', async (req, res) => {
        const result = await db.collection('vehicles').insertOne(req.body);
        res.json(result);
    });

    // --- INVESTMENT ROUTES ---
    app.get('/api/investments/:userId', async (req, res) => {
        const investments = await db.collection('investments').find({ userId: req.params.userId }).toArray();
        res.json(investments);
    });

    app.post('/api/investments', async (req, res) => {
        const result = await db.collection('investments').insertOne(req.body);
        res.json(result);
    });

    return app;
}

module.exports = createApp;

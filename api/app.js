const express = require('express');
const cors = require('cors');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         name:
 *           type: string
 *         email:
 *           type: string
 *     Vehicle:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         name:
 *           type: string
 *         type:
 *           type: string
 *     Investment:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *         userId:
 *           type: string
 *         vehicleId:
 *           type: string
 *         amount:
 *           type: number
 */

function createApp(db) {
    const app = express();

    // Swagger configuration
    const swaggerOptions = {
        definition: {
            openapi: '3.0.0',
            info: {
                title: 'Drink & Deryve API',
                version: '1.0.0',
                description: 'Express API for Drink & Deryve application',
            },
            servers: [
                {
                    url: 'http://localhost:3000',
                },
            ],
        },
        apis: ['./app.js'], // files containing annotations
    };

    const swaggerDocs = swaggerJsdoc(swaggerOptions);
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

    // Middleware
    app.use(cors());
    app.use(express.json());

    // --- AUTH ROUTES ---
    /**
     * @swagger
     * /api/login:
     *   post:
     *     summary: Login a user
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             properties:
     *               username:
     *                 type: string
     *               password:
     *                 type: string
     *     responses:
     *       200:
     *         description: Login successful
     *       401:
     *         description: Invalid credentials
     */
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
    /**
     * @swagger
     * /api/users:
     *   get:
     *     summary: Get all users
     *     responses:
     *       200:
     *         description: A list of users
     *         content:
     *           application/json:
     *             schema:
     *               type: array
     *               items:
     *                 $ref: '#/components/schemas/User'
     */
    app.get('/api/users', async (req, res) => {
        const users = await db.collection('users').find({}).toArray();
        res.json(users);
    });

    /**
     * @swagger
     * /api/users:
     *   post:
     *     summary: Create a new user
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             $ref: '#/components/schemas/User'
     *     responses:
     *       200:
     *         description: User created
     */
    app.post('/api/users', async (req, res) => {
        const result = await db.collection('users').insertOne(req.body);
        res.json(result);
    });

    /**
     * @swagger
     * /api/users/{id}:
     *   delete:
     *     summary: Delete a user by ID
     *     parameters:
     *       - in: path
     *         name: id
     *         required: true
     *         schema:
     *           type: string
     *     responses:
     *       200:
     *         description: User deleted
     */
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
    /**
     * @swagger
     * /api/vehicles:
     *   get:
     *     summary: Get all vehicles
     *     responses:
     *       200:
     *         description: A list of vehicles
     */
    app.get('/api/vehicles', async (req, res) => {
        const vehicles = await db.collection('vehicles').find({}).toArray();
        res.json(vehicles);
    });

    /**
     * @swagger
     * /api/vehicles:
     *   post:
     *     summary: Add a new vehicle
     *     responses:
     *       200:
     *         description: Vehicle added
     */
    app.post('/api/vehicles', async (req, res) => {
        const result = await db.collection('vehicles').insertOne(req.body);
        res.json(result);
    });

    // --- INVESTMENT ROUTES ---
    /**
     * @swagger
     * /api/investments/{userId}:
     *   get:
     *     summary: Get investments for a user
     *     parameters:
     *       - in: path
     *         name: userId
     *         required: true
     *         schema:
     *           type: string
     *     responses:
     *       200:
     *         description: A list of investments
     */
    app.get('/api/investments/:userId', async (req, res) => {
        const investments = await db.collection('investments').find({ userId: req.params.userId }).toArray();
        res.json(investments);
    });

    /**
     * @swagger
     * /api/investments:
     *   post:
     *     summary: Start a new investment
     *     responses:
     *       200:
     *         description: Investment started
     */
    app.post('/api/investments', async (req, res) => {
        const result = await db.collection('investments').insertOne(req.body);
        res.json(result);
    });

    return app;
}

module.exports = createApp;

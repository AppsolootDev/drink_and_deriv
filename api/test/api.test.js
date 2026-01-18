const request = require('supertest');
const { MongoClient } = require('mongodb');
const createApp = require('../app');

describe('Drink & Deryve API Functional & UAT Tests', () => {
    let connection;
    let db;
    let app;

    beforeAll(async () => {
        const url = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';
        connection = await MongoClient.connect(url);
        db = connection.db('drink_and_deryve_test'); // Use a test database
        app = createApp(db);
    });

    afterAll(async () => {
        await db.dropDatabase();
        await connection.close();
    });

    // --- UAT: Admin Login ---
    test('UAT: Admin should be able to login with correct credentials', async () => {
        const response = await request(app)
            .post('/api/login')
            .send({
                username: 'deriver@admin',
                password: 'DerivProfit'
            });

        expect(response.statusCode).toBe(200);
        expect(response.body.role).toBe('admin');
        expect(response.body.status).toBe('success');
    });

    // --- Functional: User CRUD ---
    test('Functional: Should be able to create and retrieve users', async () => {
        const newUser = {
            id: 'test_user_1',
            fullName: 'Test User',
            email: 'test@user.com'
        };

        // Create
        const createRes = await request(app)
            .post('/api/users')
            .send(newUser);
        expect(createRes.statusCode).toBe(200);

        // Retrieve
        const getRes = await request(app).get('/api/users');
        expect(getRes.statusCode).toBe(200);
        expect(getRes.body.some(u => u.id === 'test_user_1')).toBe(true);
    });

    // --- Functional: Vehicle CRUD ---
    test('Functional: Should be able to retrieve vehicles', async () => {
        const response = await request(app).get('/api/vehicles');
        expect(response.statusCode).toBe(200);
        expect(Array.isArray(response.body)).toBe(true);
    });

    // --- UAT: User Deletion Logic ---
    test('UAT: Deleting a user should also clear their investments', async () => {
        const userId = 'user_to_delete';

        // Setup: Create user and investment
        await db.collection('users').insertOne({ id: userId, email: 'delete@me.com' });
        await db.collection('investments').insertOne({ userId: userId, amount: 1000 });

        // Delete
        const deleteRes = await request(app).delete(`/api/users/${userId}`);
        expect(deleteRes.statusCode).toBe(200);

        // Verify deletion
        const user = await db.collection('users').findOne({ id: userId });
        const investment = await db.collection('investments').findOne({ userId: userId });

        expect(user).toBeNull();
        expect(investment).toBeNull();
    });
});

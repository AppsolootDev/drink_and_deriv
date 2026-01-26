const { MongoClient } = require('mongodb');
const http = require('http');
const { Server } = require('socket.io');
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
        const server = http.createServer(app);
        const io = new Server(server, {
            cors: {
                origin: "*",
                methods: ["GET", "POST"]
            }
        });

        // Attach io to app so routes can use it
        app.set('socketio', io);

        io.on('connection', (socket) => {
            console.log('A user connected:', socket.id);

            socket.on('start_investment', (data) => {
                console.log('Investment started via socket:', data);
                // Join a room for this specific investment
                socket.join(`investment_${data.investmentId}`);

                // Simulate continuous trade data
                const interval = setInterval(() => {
                    const isWin = Math.random() > 0.5;
                    const tradeData = {
                        investmentId: data.investmentId,
                        time: new Date().toISOString(),
                        isWin: isWin,
                        profitLoss: isWin ? (Math.random() * 50 + 10) : -(Math.random() * 40 + 10),
                        type: 'Rise/Fall' // Simplified for simulation
                    };
                    io.to(`investment_${data.investmentId}`).emit('trade_update', tradeData);
                }, 5000);

                socket.on('disconnect', () => {
                    clearInterval(interval);
                    console.log('User disconnected, stopped simulation for:', data.investmentId);
                });

                socket.on('stop_investment', () => {
                    clearInterval(interval);
                    socket.leave(`investment_${data.investmentId}`);
                });
            });
        });

        server.listen(port, () => {
            console.log(`Express server with WebSockets running at http://localhost:${port}`);
        });
    } catch (err) {
        console.error('Failed to connect to MongoDB', err);
        process.exit(1);
    }
}

startServer();

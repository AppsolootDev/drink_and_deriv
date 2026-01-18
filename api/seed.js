const { MongoClient } = require('mongodb');

const url = 'mongodb://127.0.0.1:27017';
const dbName = 'drink_and_deryve';

const users = [];
for (let i = 1; i <= 10; i++) {
    users.push({
        id: `user_${i}`,
        fullName: i === 1 ? 'John Doe' : i === 2 ? 'Jane Smith' : i === 3 ? 'Mike Ross' : `User ${i}`,
        email: `user${i}@example.com`,
        cellNumber: `+27 82 000 000${i}`,
        profileImageUrl: `https://placeholder.com/user${i}.png`,
        memberSince: new Date('2023-01-15').toISOString(),
        totalInvested: 5000.0 * i,
        totalWins: i * 2,
        totalTrades: i * 3,
        access: i % 4 === 0 ? 'Restricted' : 'Full',
    });
}

const vehicles = [
    {
        id: 'v_01',
        name: 'Kentucky Rounder',
        type: 'Fleet Asset',
        tradingOption: 'Rise/Fall',
        targetAmount: 25000.0,
        lotSize: 40,
        lotPrice: 625.0,
        status: 'Open',
        expectedRoi: 15.0,
        maturityMonths: 24,
        description: 'The Kentucky Rounder is a high-performance long-haul fleet vehicle.',
        imageUrl: 'assets/images/car_1.jpeg',
    },
    {
        id: 'v_02',
        name: 'Levora',
        type: 'Logistics Asset',
        tradingOption: 'Higher/Lower',
        targetAmount: 18500.0,
        lotSize: 25,
        lotPrice: 740.0,
        status: 'Open',
        expectedRoi: 12.5,
        maturityMonths: 18,
        description: 'The Levora specializes in urban logistics.',
        imageUrl: 'assets/images/car_2.jpeg',
    },
    {
        id: 'v_03',
        name: 'Matchbox',
        type: 'Economy Asset',
        tradingOption: 'Touch/No Touch',
        targetAmount: 12000.0,
        lotSize: 15,
        lotPrice: 800.0,
        status: 'Open',
        expectedRoi: 10.0,
        maturityMonths: 12,
        description: 'Our Matchbox tier focuses on compact economy fleet scaling.',
        imageUrl: 'assets/images/car_3.jpeg',
    },
];

const investments = [
    {
        id: 'inv_01', userId: 'user_01', vehicleId: 'v_01', vehicleName: 'Kentucky Rounder',
        amountInvested: 25000.0, investedAt: new Date().toISOString(),
        status: 'Active', currentReturns: 1200.0,
    },
    {
        id: 'inv_02', userId: 'user_01', vehicleId: 'v_02', vehicleName: 'Levora',
        amountInvested: 18500.0, investedAt: new Date().toISOString(),
        status: 'Paused', currentReturns: 800.0,
    },
    {
        id: 'inv_03', userId: 'user_01', vehicleId: 'v_03', vehicleName: 'Matchbox',
        amountInvested: 12000.0, investedAt: new Date().toISOString(),
        status: 'Active', currentReturns: 400.0,
    },
];

async function seed() {
    const client = await MongoClient.connect(url);
    const db = client.db(dbName);

    console.log('Clearing existing data...');
    await db.collection('users').deleteMany({});
    await db.collection('vehicles').deleteMany({});
    await db.collection('investments').deleteMany({});

    console.log('Seeding users...');
    await db.collection('users').insertMany(users);

    console.log('Seeding vehicles...');
    await db.collection('vehicles').insertMany(vehicles);

    console.log('Seeding investments...');
    await db.collection('investments').insertMany(investments);

    console.log('Database seeded successfully!');
    await client.close();
}

seed().catch(console.error);

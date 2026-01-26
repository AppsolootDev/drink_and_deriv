const { Server } = require("socket.io");
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 7500;

// Simple HTML Dashboard
const dashboardHtml = `
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Simulator Dashboard</title>
    <script src="/socket.io/socket.io.js"></script>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f7f9; margin: 0; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; }
        header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 20px; }
        h2 { margin-top: 0; color: #333; }
        #logs { height: 400px; overflow-y: auto; background: #1e1e1e; color: #d4d4d4; padding: 15px; border-radius: 4px; font-family: 'Consolas', monospace; font-size: 13px; }
        .log-entry { margin-bottom: 5px; border-bottom: 1px solid #333; padding-bottom: 5px; }
        .type-sent { color: #4ec9b0; }
        .type-received { color: #ce9178; }
        .win { color: #6a9955; font-weight: bold; }
        .loss { color: #f44747; font-weight: bold; }
        .timestamp { color: #808080; margin-right: 10px; }
        .stats { display: flex; gap: 20px; }
        .stat-box { flex: 1; text-align: center; }
        .stat-value { fontSize: 24px; fontWeight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Drink & Deryve WS Simulator</h1>
            <div id="status" style="color: green;">● Server Online</div>
        </header>

        <div class="card stats">
            <div class="stat-box">
                <div class="stat-value" id="active-count">0</div>
                <div style="color: #666;">Active Investments</div>
            </div>
            <div class="stat-box">
                <div class="stat-value" id="trade-count">0</div>
                <div style="color: #666;">Trades Sent</div>
            </div>
        </div>

        <div class="card">
            <h2>Live Traffic</h2>
            <div id="logs"></div>
        </div>
    </div>

    <script>
        const socket = io();
        const logsContainer = document.getElementById('logs');
        const activeCount = document.getElementById('active-count');
        const tradeCount = document.getElementById('trade-count');
        let totalTrades = 0;

        function addLog(type, message, data) {
            const entry = document.createElement('div');
            entry.className = 'log-entry';
            const now = new Date().toLocaleTimeString();

            let dataStr = JSON.stringify(data);
            let highlightClass = '';
            if (data && data.isWin !== undefined) {
                highlightClass = data.isWin ? 'win' : 'loss';
            }

            entry.innerHTML = \`<span class="timestamp">[\${now}]</span> <span class="type-\${type.toLowerCase()}">[\${type}]</span> \${message} <span class="\${highlightClass}">\${dataStr}</span>\`;
            logsContainer.insertBefore(entry, logsContainer.firstChild);

            if (logsContainer.childNodes.length > 100) {
                logsContainer.removeChild(logsContainer.lastChild);
            }
        }

        socket.on('dashboard_update', (data) => {
            if (data.type === 'START') {
                addLog('RECEIVED', 'Start Investment', data.payload);
            } else if (data.type === 'STOP') {
                addLog('RECEIVED', 'Stop Investment', data.payload);
            } else if (data.type === 'TRADE') {
                totalTrades++;
                tradeCount.innerText = totalTrades;
                addLog('SENT', 'Trade Update', data.payload);
            }
            activeCount.innerText = data.activeCount;
        });

        socket.on('connect', () => console.log('Connected to server'));
    </script>
</body>
</html>
`;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(dashboardHtml);
});

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const activeInvestments = new Map();

function broadcastToDashboard(type, payload) {
  io.emit("dashboard_update", {
    type,
    payload,
    activeCount: activeInvestments.size
  });
}

io.on("connection", (socket) => {
  console.log("App connected:", socket.id);

  socket.on("start_investment", (data) => {
    const { investmentId, username } = data;
    console.log(`Starting simulator for investment: ${investmentId} (User: ${username})`);

    if (activeInvestments.has(investmentId)) {
      clearTimeout(activeInvestments.get(investmentId));
    }

    activeInvestments.set(investmentId, null); // Placeholder to count as active
    broadcastToDashboard("START", data);

    const sendTrade = () => {
      const isWin = Math.random() > 0.4; // 60% win rate
      const profitLoss = isWin
        ? (Math.random() * 50 + 10).toFixed(2)
        : -(Math.random() * 30 + 5).toFixed(2);

      const update = {
        investmentId: investmentId,
        isWin: isWin,
        profitLoss: parseFloat(profitLoss),
        timestamp: new Date().toISOString()
      };

      console.log(`Sending trade for ${investmentId}:`, update);
      socket.emit("trade_update", update);
      broadcastToDashboard("TRADE", update);

      // Schedule next trade with random interval 0.5s to 1.2s
      const nextInterval = Math.floor(Math.random() * (1200 - 500 + 1) + 500);
      const timeoutId = setTimeout(sendTrade, nextInterval);
      activeInvestments.set(investmentId, timeoutId);
    };

    // Start the first trade
    const initialTimeout = setTimeout(sendTrade, 1000);
    activeInvestments.set(investmentId, initialTimeout);
  });

  socket.on("stop_investment", (data) => {
    const { investmentId } = data;
    console.log(`Stopping simulator for investment: ${investmentId}`);
    if (activeInvestments.has(investmentId)) {
      clearTimeout(activeInvestments.get(investmentId));
      activeInvestments.delete(investmentId);
    }
    broadcastToDashboard("STOP", data);
  });

  socket.on("disconnect", () => {
    console.log("App disconnected");
  });
});

server.listen(PORT, () => {
  console.log(`WebSocket Simulator running at http://localhost:${PORT}`);
});

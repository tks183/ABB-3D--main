const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const Modbus = require('modbus-serial');
const path = require('path');
const os = require('os');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: { origin: "*", methods: ["GET", "POST"] }
});

app.use(express.static('public'));
app.use('/libs/three', express.static(path.join(__dirname, 'node_modules/three')));
app.use('/libs/fflate', express.static(path.join(__dirname, 'node_modules/fflate')));

// ========== 修正后的配置 ==========
const PLC_CONFIG = {
    host: '192.168.0.1',
    port: 502,
    unitId: 1,
    startRegister: 0,      // 对应 HoldStart = &VB300 时的 VW300
    registerCount: 12      // 6个浮点数 * 2寄存器
};

// 浮点数解析模式（西门子默认大端序）
const FLOAT_MODE = 'big-endian';

function getLocalIP() {
    const interfaces = os.networkInterfaces();
    const ips = { ipv4: [], ipv6: [] };
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (!iface.internal) {
                if (iface.family === 'IPv4') ips.ipv4.push(iface.address);
                else if (iface.family === 'IPv6') ips.ipv6.push(iface.address);
            }
        }
    }
    return ips;
}
const LOCAL_IPS = getLocalIP();

const client = new Modbus();
let isConnected = false;
let connectionAttempts = 0;
const MAX_CONNECTION_ATTEMPTS = 10;
let reconnectTimer = null;

async function connectToPLC() {
    try {
        await client.connectTCP(PLC_CONFIG.host, { port: PLC_CONFIG.port, timeout: 3000 });
        client.setID(PLC_CONFIG.unitId);
        client.setTimeout(3000);
        isConnected = true;
        connectionAttempts = 0;
        if (reconnectTimer) clearTimeout(reconnectTimer);
        console.log('✅ 成功连接到 PLC');
        return true;
    } catch (error) {
        console.error(`❌ 连接失败 (${connectionAttempts+1}/${MAX_CONNECTION_ATTEMPTS}):`, error.message);
        isConnected = false;
        connectionAttempts++;
        if (connectionAttempts <= MAX_CONNECTION_ATTEMPTS) {
            const delay = Math.min(2000 * Math.pow(1.5, connectionAttempts - 1), 30000);
            reconnectTimer = setTimeout(() => connectToPLC(), delay);
        }
        return false;
    }
}

function registersToFloat(regs, mode) {
    const buffer = Buffer.alloc(4);
    switch (mode) {
        case 'big-endian':
            buffer.writeUInt16BE(regs[0], 0);
            buffer.writeUInt16BE(regs[1], 2);
            break;
        case 'little-endian':
            buffer.writeUInt16LE(regs[0], 0);
            buffer.writeUInt16LE(regs[1], 2);
            break;
        case 'big-endian-swapped':
            buffer.writeUInt16BE(regs[1], 0);
            buffer.writeUInt16BE(regs[0], 2);
            break;
        default:
            buffer.writeUInt16BE(regs[0], 0);
            buffer.writeUInt16BE(regs[1], 2);
    }
    return buffer.readFloatBE(0);
}

async function readRobotData() {
    if (!isConnected) return null;

    try {
        const response = await client.readHoldingRegisters(PLC_CONFIG.startRegister, PLC_CONFIG.registerCount);
        if (!response || !response.data || response.data.length !== PLC_CONFIG.registerCount) {
            throw new Error('寄存器数据异常');
        }

        const rawHex = response.data.map(v => `0x${v.toString(16).padStart(4, '0')}`).join(' ');
        console.log(`原始寄存器数据 (地址 ${PLC_CONFIG.startRegister} 开始): ${rawHex}`);

        const jointAngles = [];
        for (let i = 0; i < 6; i++) {
            const regPair = [response.data[i*2], response.data[i*2+1]];
            const value = registersToFloat(regPair, FLOAT_MODE);
            jointAngles.push(value);
        }

        const robotData = {
            joint1: jointAngles[0],
            joint2: jointAngles[1],
            joint3: jointAngles[2],
            joint4: jointAngles[3],
            joint5: jointAngles[4],
            joint6: jointAngles[5],
            timestamp: new Date().toISOString(),
            isMockData: false
        };

        console.log('📡 解析后的角度:', {
            j1: robotData.joint1.toFixed(2) + '°',
            j2: robotData.joint2.toFixed(2) + '°',
            j3: robotData.joint3.toFixed(2) + '°',
            j4: robotData.joint4.toFixed(2) + '°',
            j5: robotData.joint5.toFixed(2) + '°',
            j6: robotData.joint6.toFixed(2) + '°'
        });

        return robotData;
    } catch (error) {
        console.error('读取PLC数据失败:', error.message);
        isConnected = false;
        if (connectionAttempts === 0) connectToPLC();
        return null;
    }
}

io.on('connection', (socket) => {
    console.log('🔗 客户端已连接:', socket.id);
    socket.emit('connectionStatus', { plcConnected: isConnected, message: isConnected ? 'PLC已连接' : 'PLC未连接' });

    const interval = setInterval(async () => {
        const data = await readRobotData();
        if (data) socket.emit('robotData', data);
    }, 100);

    socket.on('requestData', async () => {
        const data = await readRobotData();
        if (data) socket.emit('robotData', data);
    });

    socket.on('disconnect', () => {
        console.log('🔌 客户端断开:', socket.id);
        clearInterval(interval);
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok', plcConnected: isConnected, connectionAttempts });
});
app.get('/read-data', async (req, res) => {
    const data = await readRobotData();
    data ? res.json({ success: true, data }) : res.status(500).json({ success: false });
});

process.on('SIGINT', async () => {
    console.log('🛑 关闭服务器...');
    if (reconnectTimer) clearTimeout(reconnectTimer);
    if (client.isOpen) await client.close();
    process.exit(0);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`🚀 服务器运行在 http://localhost:${PORT}`);
    console.log(`📡 本机IP: ${LOCAL_IPS.ipv4.join(', ')}`);
    connectToPLC();
});

module.exports = { readRobotData, connectToPLC };
const PokerTableEngine = require('../pokerGame');

let instance = null;

function init(io) {
    if (!instance) {
        instance = new PokerTableEngine(io, { 
            smallBlind: 5, 
            bigBlind: 10, 
            maxPlayers: 9,
            tableId: 'sala-practica-400', // 🔥 Buena práctica para los sockets
            isPractice: true              // 🔥 ESTO ES LO QUE BLOQUEA EL RAKE Y EL CASH-OUT
        });
    }
    return instance;
}

function getTable() {
    return instance;
}

function getSeats() {
    return instance ? instance.seats : [];
}

module.exports = { init, getTable, getSeats };
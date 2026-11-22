function getClientIp(req) {
    let ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    if (ip && ip.includes(',')) {
        ip = ip.split(',')[0].trim();
    }
    if (ip === '::1') ip = '127.0.0.1';
    return ip;
}

module.exports = { getClientIp };
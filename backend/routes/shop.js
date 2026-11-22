// backend/routes/shop.js
// 🔥 TIENDA — endpoints HTTP (emojis y estilos de cartas)
const express = require('express');
const router = express.Router();
const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
const { validateShopPurchase, validateShopEquip } = require('../middlewares/validators');
const shop = require('../services/shop');

// Catálogo + inventario del usuario
router.get('/shop/items', verifyToken, async (req, res) => {
    try {
        const data = await shop.listShop(req.user.id);
        res.json(data);
    } catch (error) {
        console.error('Error al listar la tienda:', error);
        res.status(500).json({ error: 'Error al cargar la tienda' });
    }
});

// Comprar un artículo (emoji o estilo) con NTX-20
router.post('/shop/purchase', verifyToken, validateShopPurchase, async (req, res) => {
    try {
        const result = await shop.purchaseItem(req.user.id, Number(req.body.itemId));
        res.json({ message: `¡Compraste ${result.item.name}!`, ...result });
    } catch (error) {
        res.status(400).json({ error: error.message || 'Error al comprar' });
    }
});

// Equipar un estilo de cartas
router.post('/shop/equip', verifyToken, validateShopEquip, async (req, res) => {
    try {
        const result = await shop.equipCardStyle(req.user.id, Number(req.body.itemId));
        res.json({ message: 'Estilo equipado', ...result });
    } catch (error) {
        res.status(400).json({ error: error.message || 'Error al equipar' });
    }
});

// Estilo de cartas equipado (para renderizar las cartas)
router.get('/shop/equipped', verifyToken, async (req, res) => {
    try {
        const style = await shop.getEquippedStyle(req.user.id);
        res.json({ style });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el estilo' });
    }
});

// Inventario simple (ids de artículos poseídos)
router.get('/shop/inventory', verifyToken, async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT si.id, si.item_type, si.name, si.value, si.price_ntx
             FROM user_items ui JOIN shop_items si ON si.id = ui.item_id
             WHERE ui.user_id = ? ORDER BY si.item_type, si.sort_order`,
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el inventario' });
    }
});

module.exports = router;

// backend/services/shop.js
// ============================================================
// 🔥 TIENDA — RoyalBet
// Vende EMOJIS (para usar en las mesas mientras se juega) y
// ESTILOS DE CARTAS (visual de las cartas del jugador).
//   Emojis        : precios de 1 a 4 NTX-20
//   Estilos cartas: precios de 1 a 3 NTX-20 (Clásico gratis)
// El NTX-20 pagado se acumula en el FONDO DEL PROYECTO (bank_reserves).
// Las fichas de club NO se canjean ni se compran aquí (eso es del dueño
// del club, 1 NTX-20 = 1 ficha de club, en /clubs/chips/purchase).
// ============================================================
const pool = require('../db');

// Validación local del catálogo (defensa en profundidad; el catálogo real
// vive en shop_items y se siembra con la base de datos).
const CATALOG_RULES = {
    emote:      { min: 1, max: 4 },
    card_style: { min: 1, max: 3 },
};

const OWNERSHIP_CACHE_TTL_MS = 30 * 1000;
const ownershipCache = new Map(); // `${userId}:${value}` -> { owned, at }

function invalidateOwnershipCache(userId = null) {
    if (userId === null) return ownershipCache.clear();
    for (const key of ownershipCache.keys()) {
        if (key.startsWith(`${userId}:`)) ownershipCache.delete(key);
    }
}

// Reparto puro (testeable sin BD): precio válido por tipo de artículo
function isPriceValidForType(itemType, price) {
    const rule = CATALOG_RULES[itemType];
    if (!rule) return false;
    const p = Number(price);
    return Number.isFinite(p) && p >= rule.min && p <= rule.max;
}

// Lista el catálogo activo + marca lo que el usuario ya posee
async function listShop(userId = null) {
    const [items] = await pool.query(
        'SELECT id, item_type, name, value, price_ntx, sort_order FROM shop_items WHERE active = 1 ORDER BY item_type, sort_order'
    );
    let owned = new Set();
    let equippedCardStyle = null;
    if (userId) {
        const [rows] = await pool.query('SELECT item_id FROM user_items WHERE user_id = ?', [userId]);
        owned = new Set(rows.map(r => r.item_id));
        const [prefs] = await pool.query('SELECT equipped_card_style FROM user_preferences WHERE user_id = ?', [userId]);
        equippedCardStyle = prefs[0]?.equipped_card_style ?? null;
    }
    return {
        emotes: items.filter(i => i.item_type === 'emote').map(i => ({ ...i, owned: owned.has(i.id) })),
        cardStyles: items.filter(i => i.item_type === 'card_style').map(i => ({
            ...i,
            owned: owned.has(i.id),
            equipped: equippedCardStyle === i.id,
        })),
        equippedCardStyle,
    };
}

// Compra: transacción — descuenta NTX-20, registra inventario y suma al Fondo del Proyecto
async function purchaseItem(userId, itemId) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [items] = await connection.query(
            'SELECT id, item_type, name, value, price_ntx FROM shop_items WHERE id = ? AND active = 1 FOR UPDATE',
            [itemId]
        );
        const item = items[0];
        if (!item) throw new Error('Artículo no encontrado');
        if (!isPriceValidForType(item.item_type, item.price_ntx)) {
            throw new Error('Precio del artículo fuera de rango permitido');
        }

        const [dupe] = await connection.query(
            'SELECT id FROM user_items WHERE user_id = ? AND item_id = ? FOR UPDATE',
            [userId, itemId]
        );
        if (dupe.length > 0) throw new Error('Ya tienes este artículo');

        // El estilo Clásico es gratis y lo tiene todo el mundo: no se compra
        if (item.item_type === 'card_style' && Number(item.price_ntx) === 0) {
            throw new Error('Este estilo ya viene incluido por defecto');
        }

        const [wallets] = await connection.query(
            'SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE',
            [userId]
        );
        if (!wallets[0]) throw new Error('Billetera no encontrada');
        const price = Number(item.price_ntx);
        if (Number(wallets[0].balance_ntx) < price) {
            throw new Error('Saldo NTX-20 insuficiente');
        }

        await connection.query(
            'UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?',
            [price, userId]
        );
        await connection.query(
            'INSERT INTO user_items (user_id, item_id) VALUES (?, ?)',
            [userId, itemId]
        );
        // El dinero de la Tienda entra al FONDO DEL PROYECTO
        await connection.query(
            'UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1',
            [price]
        );

        await connection.commit();
        invalidateOwnershipCache(userId);
        return { ok: true, item: { id: item.id, name: item.name, type: item.item_type }, price };
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
}

// Equipa un estilo de cartas (debe ser suyo, o el Clásico gratis)
async function equipCardStyle(userId, itemId) {
    const [items] = await pool.query(
        "SELECT id, value FROM shop_items WHERE id = ? AND item_type = 'card_style' AND active = 1",
        [itemId]
    );
    const item = items[0];
    if (!item) throw new Error('Estilo de cartas no encontrado');

    if (Number((await pool.query('SELECT price_ntx FROM shop_items WHERE id = ?', [itemId]))[0][0].price_ntx) > 0) {
        const [owned] = await pool.query(
            'SELECT id FROM user_items WHERE user_id = ? AND item_id = ?',
            [userId, itemId]
        );
        if (owned.length === 0) throw new Error('Debes comprar este estilo antes de equiparlo');
    }

    await pool.query(
        `INSERT INTO user_preferences (user_id, equipped_card_style) VALUES (?, ?)
         ON DUPLICATE KEY UPDATE equipped_card_style = VALUES(equipped_card_style)`,
        [userId, itemId]
    );
    return { ok: true, style: item.value };
}

// Estilo equipado (para el motor visual de las cartas); null => Clásico
async function getEquippedStyle(userId) {
    const [rows] = await pool.query(
        `SELECT sp.value FROM user_preferences up
         JOIN shop_items sp ON sp.id = up.equipped_card_style
         WHERE up.user_id = ?`,
        [userId]
    );
    return rows[0]?.value || 'clasico';
}

// ¿El jugador posee este emoji? (usado por los sockets al enviar un emote)
async function ownsEmote(userId, emoteValue) {
    const key = `${userId}:${emoteValue}`;
    const cached = ownershipCache.get(key);
    if (cached && (Date.now() - cached.at) < OWNERSHIP_CACHE_TTL_MS) return cached.owned;

    const [rows] = await pool.query(
        `SELECT ui.id FROM user_items ui
         JOIN shop_items si ON si.id = ui.item_id
         WHERE ui.user_id = ? AND si.value = ? AND si.item_type = 'emote' AND si.active = 1`,
        [userId, String(emoteValue).slice(0, 40)]
    );
    const owned = rows.length > 0;
    ownershipCache.set(key, { owned, at: Date.now() });
    return owned;
}

module.exports = {
    CATALOG_RULES,
    isPriceValidForType,
    listShop,
    purchaseItem,
    equipCardStyle,
    getEquippedStyle,
    ownsEmote,
    invalidateOwnershipCache,
};

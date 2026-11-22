const express = require('express');
const router = express.Router();

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');
// ===========================================================
// VALIDADOR
// ===========================================================
const {
  validateClubCreate, validateClubJoin, validateClubUpdate,
  validateClubDiscord, validateTemplateOrTable, validateIdParam,
  validateClubTier, validateClubChips, validateClubModerator,
  validateClubKick, validateClubInvite, validateClubTournament,
} = require('../middlewares/validators');

// ===========================================================
// 🔥 NIVELES DE CLUB (tiers) — regla de negocio
//   0  Gratis     → 10 jugadores,  torneos solo para miembros
//   1  70 NTX-20  → 50 jugadores,  torneos solo para miembros
//   2  100 NTX-20 → 100 jugadores, 1 torneo activo visible en el lobby del casino
//   3  300 NTX-20 → 250 jugadores, 3 torneos activos visibles en el lobby
// ===========================================================
const CLUB_TIERS = {
  0: { price: 0,   max_players: 10,  public_tournaments: 0 },
  1: { price: 70,  max_players: 50,  public_tournaments: 0 },
  2: { price: 100, max_players: 100, public_tournaments: 1 },
  3: { price: 300, max_players: 250, public_tournaments: 3 },
};

// Fichas de club: el dueño las COMpra 1 NTX-20 = 1 ficha (igual que se compra NTX-20)
const CHIP_EXCHANGE_RATE = 1;

// Genera un código único para encontrar el club por su ID (CLUB####)
function generateClubCode() {
  return 'CLUB' + Math.floor(1000 + Math.random() * 9000);
}

// Rol del usuario en un club: 'owner' | 'moderator' | 'member' | null
async function getClubRole(connection, clubId, userId) {
  const [rows] = await connection.query(
    'SELECT role FROM club_members WHERE club_id = ? AND user_id = ?',
    [clubId, userId]
  );
  if (!rows[0]) return null;
  return rows[0].role === 'owner' ? 'owner'
    : rows[0].role === 'moderator' ? 'moderator'
    : 'member';
}

const canManage = (role) => role === 'owner' || role === 'moderator';

// ===========================================================
// CREAR CLUB (nivel 0 — gratis, máx 10 jugadores)
// ===========================================================
router.post('/clubs/create', verifyToken, validateClubCreate, async (req, res) => {
    const { name } = req.body;
    const owner_id = req.user.id;

    if (!name) return res.status(400).json({ error: 'El nombre del club es obligatorio' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [existing] = await connection.query('SELECT id FROM club_members WHERE user_id = ?', [owner_id]);
        if (existing.length > 0) throw new Error('Ya perteneces a un club');

        const [clubCount] = await connection.query(
          'SELECT COUNT(*) as count FROM clubs WHERE owner_id = ?',
          [owner_id]
        );
        if (clubCount[0].count > 0) throw new Error('Ya eres dueño de un club');

        // Código único (reintenta si colisiona con la clave única)
        let club_id = null;
        for (let attempt = 0; attempt < 5; attempt++) {
            try {
                const [result] = await connection.query(
                    'INSERT INTO clubs (name, code, owner_id, max_players, tier, chip_balance) VALUES (?, ?, ?, 10, 0, 0)',
                    [name, generateClubCode(), owner_id]
                );
                club_id = result.insertId;
                break;
            } catch (e) {
                if (e.code !== 'ER_DUP_ENTRY') throw e;
            }
        }
        if (!club_id) throw new Error('No se pudo generar un código de club único, intenta de nuevo');

        await connection.query(
            'INSERT INTO club_members (club_id, user_id, role) VALUES (?, ?, "owner")',
            [club_id, owner_id]
        );

        await connection.commit();
        const [clubs] = await connection.query('SELECT * FROM clubs WHERE id = ?', [club_id]);
        res.json({ message: 'Club creado exitosamente', club: clubs[0] });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ===========================================================
// UNIRSE POR CÓDIGO/ID (máx jugadores según el nivel del club)
// ===========================================================
router.post('/clubs/join', verifyToken, validateClubJoin, async (req, res) => {
    const { code } = req.body;
    const user_id = req.user.id;

    if (!code) return res.status(400).json({ error: 'El codigo es obligatorio' });
    const normalized = String(code).trim().toUpperCase();

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [existing] = await connection.query('SELECT id FROM club_members WHERE user_id = ?', [user_id]);
        if (existing.length > 0) throw new Error('Ya perteneces a un club');

        const [clubs] = await connection.query(
            'SELECT * FROM clubs WHERE UPPER(code) = ? OR id = ?',
            [normalized, parseInt(normalized.replace(/\D/g, ''), 10) || 0]
        );
        if (clubs.length === 0) throw new Error('Club no encontrado con ese codigo');
        const club = clubs[0];

        const [players] = await connection.query(
            'SELECT COUNT(*) as count FROM club_members WHERE club_id = ?',
            [club.id]
        );
        if (players[0].count >= club.max_players) {
            throw new Error(`El club esta lleno (Maximo ${club.max_players} jugadores)`);
        }

        await connection.query(
            'INSERT INTO club_members (club_id, user_id, role) VALUES (?, ?, "player")',
            [club.id, user_id]
        );

        await connection.commit();
        res.json({ message: 'Te has unido al club exitosamente', club });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ===========================================================
// BUSCAR CLUB POR SU ID (para que los socios lo encuentren rápido)
// ===========================================================
router.get('/clubs/search/:code', verifyToken, async (req, res) => {
    try {
        const q = String(req.params.code || '').trim().toUpperCase();
        if (!q) return res.status(400).json({ error: 'Indica el ID del club' });
        const [clubs] = await pool.query(
            `SELECT c.id, c.name, c.code, c.tier, c.max_players, c.avatar_url, c.description,
                    (SELECT COUNT(*) FROM club_members cm WHERE cm.club_id = c.id) AS members
             FROM clubs c
             WHERE UPPER(c.code) = ? OR c.id = ?`,
            [q, parseInt(q.replace(/\D/g, ''), 10) || 0]
        );
        if (clubs.length === 0) return res.status(404).json({ error: 'Club no encontrado' });
        res.json(clubs[0]);
    } catch (error) {
        res.status(500).json({ error: 'Error al buscar el club' });
    }
});

// ===========================================================
// MI CLUB
// ===========================================================
router.get('/clubs/my-club', verifyToken, async (req, res) => {
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [user_id]);
        if (memberships.length === 0) return res.status(404).json({ error: 'No perteneces a ningun club' });

        const club_id = memberships[0].club_id;
        const my_role = memberships[0].role;

        const [clubs] = await pool.query('SELECT * FROM clubs WHERE id = ?', [club_id]);
        const club = clubs[0];

        const [players] = await pool.query('SELECT COUNT(*) as count FROM club_members WHERE club_id = ?', [club_id]);

        // Fichas personales del socio dentro del club
        const [me] = await pool.query(
            'SELECT club_chips FROM club_members WHERE club_id = ? AND user_id = ?',
            [club_id, user_id]
        );

        res.json({
            club,
            role: my_role,
            current_players: players[0].count,
            my_club_chips: Number(me[0]?.club_chips || 0),
            tier_info: CLUB_TIERS[club.tier] || CLUB_TIERS[0],
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener informacion del club' });
    }
});

// ===========================================================
// EDITAR CLUB — el DUEÑO o el MODERADOR pueden editar (nombre, aviso, foto)
// ===========================================================
router.put('/clubs/update', verifyToken, validateClubUpdate, async (req, res) => {
    const { name, description, avatar_url } = req.body;
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            return res.status(403).json({ error: 'Solo el dueño o el moderador pueden editar el club' });
        }

        const club_id = memberships[0].club_id;
        await connection.query(
            'UPDATE clubs SET name = ?, description = ?, avatar_url = ? WHERE id = ?',
            [name, description, avatar_url, club_id]
        );
        res.json({ message: 'Club actualizado correctamente' });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar el club' });
    } finally {
        connection.release();
    }
});

router.put('/clubs/discord-settings', verifyToken, validateClubDiscord, async (req, res) => {
    const { discord_client_id, discord_client_secret, discord_redirect_uri } = req.body;
    const user_id = req.user.id;

    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [user_id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'Solo el dueno puede configurar esto' });

        const club_id = memberships[0].club_id;
        await pool.query(
            'UPDATE clubs SET discord_client_id = ?, discord_client_secret = ?, discord_redirect_uri = ? WHERE id = ?',
            [discord_client_id, discord_client_secret, discord_redirect_uri, club_id]
        );
        res.json({ message: 'Credenciales de Discord guardadas correctamente' });
    } catch (error) {
        res.status(500).json({ error: 'Error al guardar las credenciales de Discord' });
    }
});

// ===========================================================
// 🔥 NIVELES DE CLUB — pagar con NTX-20 (70 / 100 / 300)
// ===========================================================
router.post('/clubs/tier/upgrade', verifyToken, validateClubTier, async (req, res) => {
    const tier = Number(req.body.tier);
    const user_id = req.user.id;

    const config = CLUB_TIERS[tier];
    if (!config || tier === 0) return res.status(400).json({ error: 'Nivel de club invalido' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || memberships[0].role !== 'owner') {
            throw new Error('Solo el dueño del club puede pagar un nivel');
        }
        const club_id = memberships[0].club_id;

        const [clubs] = await connection.query('SELECT tier FROM clubs WHERE id = ? FOR UPDATE', [club_id]);
        const currentTier = Number(clubs[0]?.tier || 0);
        if (tier <= currentTier) throw new Error('Ya tienes este nivel o uno superior');
        if (tier !== currentTier + 1) throw new Error(`Debes subir por niveles: primero compra el nivel ${currentTier + 1}`);

        const price = config.price;
        const [wallets] = await connection.query(
            'SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE',
            [user_id]
        );
        if (Number(wallets[0]?.balance_ntx || 0) < price) {
            throw new Error(`Saldo NTX-20 insuficiente (precio: ${price} NTX-20)`);
        }

        // Pago: billetera del dueño → Fondo del Proyecto
        await connection.query('UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?', [price, user_id]);
        await connection.query('UPDATE bank_reserves SET balance_ntx = balance_ntx + ? WHERE id = 1', [price]);
        await connection.query(
            'INSERT INTO club_tier_payments (club_id, tier, amount_ntx) VALUES (?, ?, ?)',
            [club_id, tier, price]
        );
        await connection.query(
            'UPDATE clubs SET tier = ?, max_players = ? WHERE id = ?',
            [tier, config.max_players, club_id]
        );

        await connection.commit();
        res.json({
            message: `¡Club actualizado al nivel ${tier}!`,
            tier,
            max_players: config.max_players,
            public_tournaments: config.public_tournaments,
        });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ===========================================================
// 🔥 FICHAS DEL CLUB (1 NTX-20 = 1 ficha) — SOLO EL DUEÑO las compra
// ===========================================================
router.get('/clubs/chips', verifyToken, async (req, res) => {
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query(
            'SELECT club_id, role, club_chips FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0) return res.status(404).json({ error: 'No perteneces a ningun club' });
        const { club_id, role, club_chips } = memberships[0];

        const [clubs] = await pool.query('SELECT chip_balance, tier FROM clubs WHERE id = ?', [club_id]);
        const [tx] = await pool.query(
            `SELECT cct.*, u.username AS target_username, a.username AS actor_username
             FROM club_chip_tx cct
             LEFT JOIN users u ON u.id = cct.target_user_id
             LEFT JOIN users a ON a.id = cct.actor_id
             WHERE cct.club_id = ? ORDER BY cct.created_at DESC LIMIT 50`,
            [club_id]
        );
        res.json({
            role,
            club_balance: Number(clubs[0]?.chip_balance || 0),
            my_chips: Number(club_chips || 0),
            exchange_rate: CHIP_EXCHANGE_RATE,
            transactions: tx,
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener las fichas del club' });
    }
});

// El dueño compra fichas de club con NTX-20 (1:1). Igual que se compra NTX-20:
// el dinero sale de su billetera y entra al Fondo del Proyecto.
router.post('/clubs/chips/purchase', verifyToken, validateClubChips, async (req, res) => {
    const amount = Math.floor(Number(req.body.amount));
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || memberships[0].role !== 'owner') {
            throw new Error('Solo el dueño del club puede comprar fichas de club');
        }
        const club_id = memberships[0].club_id;

        const [wallets] = await connection.query(
            'SELECT balance_ntx FROM wallets WHERE user_id = ? FOR UPDATE',
            [user_id]
        );
        const cost = amount * CHIP_EXCHANGE_RATE;
        if (Number(wallets[0]?.balance_ntx || 0) < cost) {
            throw new Error(`Saldo NTX-20 insuficiente (necesitas ${cost} NTX-20)`);
        }

        await connection.query('UPDATE wallets SET balance_ntx = balance_ntx - ? WHERE user_id = ?', [cost, user_id]);
        const [upd] = await connection.query(
            'UPDATE clubs SET chip_balance = chip_balance + ? WHERE id = ?',
            [amount, club_id]
        );
        if (upd.affectedRows === 0) throw new Error('Club no encontrado');

        const [clubs] = await connection.query('SELECT chip_balance FROM clubs WHERE id = ?', [club_id]);
        await connection.query(
            `INSERT INTO club_chip_tx (club_id, actor_id, type, amount, club_balance_after, note)
             VALUES (?, ?, 'purchase', ?, ?, ?)`,
            [club_id, user_id, amount, Number(clubs[0].chip_balance), `Compra de ${amount} fichas con ${cost} NTX-20`]
        );

        await connection.commit();
        res.json({ message: `Compraste ${amount} fichas de club`, club_balance: Number(clubs[0].chip_balance) });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// El dueño (o el moderador) administra las fichas: entrega fichas del club a un socio
router.post('/clubs/chips/grant', verifyToken, validateClubChips, async (req, res) => {
    const amount = Math.floor(Number(req.body.amount));
    const targetUserId = Number(req.body.userId);
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            throw new Error('Solo el dueño o el moderador pueden repartir fichas del club');
        }
        const club_id = memberships[0].club_id;

        const [targets] = await connection.query(
            'SELECT user_id, role, club_chips FROM club_members WHERE club_id = ? AND user_id = ? FOR UPDATE',
            [club_id, targetUserId]
        );
        if (targets.length === 0) throw new Error('Ese usuario no es miembro de tu club');
        if (targets[0].role === 'owner') throw new Error('No puedes enviarte fichas a ti mismo como dueño');

        const [clubs] = await connection.query('SELECT chip_balance FROM clubs WHERE id = ? FOR UPDATE', [club_id]);
        if (Number(clubs[0].chip_balance) < amount) throw new Error('El club no tiene suficientes fichas');

        await connection.query('UPDATE clubs SET chip_balance = chip_balance - ? WHERE id = ?', [amount, club_id]);
        await connection.query(
            'UPDATE club_members SET club_chips = club_chips + ? WHERE club_id = ? AND user_id = ?',
            [amount, club_id, targetUserId]
        );

        const [after] = await connection.query('SELECT chip_balance FROM clubs WHERE id = ?', [club_id]);
        const memberAfter = Number(targets[0].club_chips || 0) + amount;
        await connection.query(
            `INSERT INTO club_chip_tx (club_id, actor_id, target_user_id, type, amount, club_balance_after, member_balance_after, note)
             VALUES (?, ?, ?, 'grant', ?, ?, ?, ?)`,
            [club_id, user_id, targetUserId, amount, Number(after[0].chip_balance), memberAfter, 'Entrega de fichas del club']
        );

        // Notificación al socio
        await connection.query(
            `INSERT INTO user_notifications (user_id, title, message, type)
             SELECT ?, 'Fichas de club', ?, 'club_chips'`,
            [targetUserId, `Recibiste ${amount} fichas de tu club.`]
        );

        await connection.commit();
        res.json({ message: `Entregaste ${amount} fichas de club`, club_balance: Number(after[0].chip_balance) });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// Un socio invierte (deposita) sus fichas de club en el fondo del club
router.post('/clubs/chips/deposit', verifyToken, validateClubChips, async (req, res) => {
    const amount = Math.floor(Number(req.body.amount));
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [memberships] = await connection.query(
            'SELECT club_id, role, club_chips FROM club_members WHERE user_id = ? FOR UPDATE',
            [user_id]
        );
        if (memberships.length === 0) throw new Error('No perteneces a un club');
        const { club_id, club_chips } = memberships[0];
        if (Number(club_chips || 0) < amount) throw new Error('No tienes suficientes fichas de club');

        await connection.query(
            'UPDATE club_members SET club_chips = club_chips - ? WHERE club_id = ? AND user_id = ?',
            [amount, club_id, user_id]
        );
        const [upd] = await connection.query(
            'UPDATE clubs SET chip_balance = chip_balance + ? WHERE id = ?',
            [amount, club_id]
        );
        if (upd.affectedRows === 0) throw new Error('Club no encontrado');

        const [after] = await connection.query('SELECT chip_balance FROM clubs WHERE id = ?', [club_id]);
        await connection.query(
            `INSERT INTO club_chip_tx (club_id, actor_id, target_user_id, type, amount, club_balance_after, member_balance_after, note)
             VALUES (?, ?, ?, 'deposit', ?, ?, ?, ?)`,
            [club_id, user_id, user_id, amount, Number(after[0].chip_balance), Number(club_chips || 0) - amount, 'Inversión de fichas al club']
        );

        await connection.commit();
        res.json({ message: `Depositaste ${amount} fichas en el club`, club_balance: Number(after[0].chip_balance) });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// ===========================================================
// 🔥 GESTIÓN DE MIEMBROS — lista, moderador, expulsar, invitar
// ===========================================================
router.get('/clubs/members', verifyToken, async (req, res) => {
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0) return res.status(404).json({ error: 'No perteneces a ningun club' });
        const club_id = memberships[0].club_id;

        const [members] = await pool.query(
            `SELECT cm.user_id, cm.role, cm.club_chips, cm.joined_at, u.username, u.unique_id, u.avatar_url
             FROM club_members cm JOIN users u ON u.id = cm.user_id
             WHERE cm.club_id = ? ORDER BY FIELD(cm.role, 'owner','moderator','player','member'), cm.joined_at`,
            [club_id]
        );
        const [clubs] = await pool.query('SELECT max_players, tier FROM clubs WHERE id = ?', [club_id]);
        res.json({
            my_role: memberships[0].role,
            max_players: clubs[0]?.max_players || 10,
            tier: clubs[0]?.tier || 0,
            members,
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener los miembros' });
    }
});

// Nombrar / quitar moderador (solo dueño). Un club tiene UN moderador a la vez.
router.post('/clubs/moderator', verifyToken, validateClubModerator, async (req, res) => {
    const targetUserId = req.body.userId === null ? null : Number(req.body.userId);
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || memberships[0].role !== 'owner') {
            throw new Error('Solo el dueño puede designar al moderador');
        }
        const club_id = memberships[0].club_id;

        await connection.query(
            "UPDATE club_members SET role = 'player' WHERE club_id = ? AND role = 'moderator'",
            [club_id]
        );

        if (targetUserId !== null) {
            const [targets] = await connection.query(
                "SELECT role FROM club_members WHERE club_id = ? AND user_id = ? FOR UPDATE",
                [club_id, targetUserId]
            );
            if (targets.length === 0) throw new Error('Ese usuario no es miembro del club');
            if (targets[0].role === 'owner') throw new Error('El dueño no puede ser moderador');
            await connection.query(
                "UPDATE club_members SET role = 'moderator' WHERE club_id = ? AND user_id = ?",
                [club_id, targetUserId]
            );
            await connection.query(
                `INSERT INTO user_notifications (user_id, title, message, type)
                 SELECT ?, 'Nuevo moderador', ?, 'club'`,
                [targetUserId, 'El dueño del club te nombró moderador. Ahora puedes gestionar fichas, miembros y torneos.']
            );
        }

        await connection.commit();
        res.json({ message: targetUserId ? 'Moderador designado' : 'Moderador removido' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// Expulsar a un jugador (dueño o moderador; el moderador solo expulsa a miembros normales)
router.post('/clubs/kick', verifyToken, validateClubKick, async (req, res) => {
    const targetUserId = Number(req.body.userId);
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            throw new Error('Solo el dueño o el moderador pueden expulsar jugadores');
        }
        const club_id = memberships[0].club_id;
        const myRole = memberships[0].role;

        const [targets] = await connection.query(
            'SELECT role FROM club_members WHERE club_id = ? AND user_id = ? FOR UPDATE',
            [club_id, targetUserId]
        );
        if (targets.length === 0) throw new Error('Ese usuario no es miembro del club');
        const targetRole = targets[0].role;
        if (targetRole === 'owner') throw new Error('No puedes expulsar al dueño del club');
        if (myRole === 'moderator' && targetRole === 'moderator') throw new Error('Un moderador no puede expulsar a otro moderador');

        await connection.query(
            'DELETE FROM club_members WHERE club_id = ? AND user_id = ?',
            [club_id, targetUserId]
        );
        await connection.query(
            `INSERT INTO user_notifications (user_id, title, message, type)
             SELECT ?, 'Expulsado del club', ?, 'club'`,
            [targetUserId, 'Fuiste expulsado del club por su administración.']
        );

        await connection.commit();
        res.json({ message: 'Jugador expulsado del club' });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

// Invitar a un jugador (dueño o moderador) por username o ID único → notificación con el código
router.post('/clubs/invite', verifyToken, validateClubInvite, async (req, res) => {
    const query = String(req.body.query || '').trim();
    const user_id = req.user.id;

    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [user_id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            return res.status(403).json({ error: 'Solo el dueño o el moderador pueden invitar jugadores' });
        }
        const club_id = memberships[0].club_id;

        const [clubs] = await pool.query('SELECT name, code, max_players FROM clubs WHERE id = ?', [club_id]);
        const [counts] = await pool.query('SELECT COUNT(*) as count FROM club_members WHERE club_id = ?', [club_id]);
        if (counts[0].count >= clubs[0].max_players) {
            return res.status(400).json({ error: `El club esta lleno (Maximo ${clubs[0].max_players} jugadores)` });
        }

        const [targets] = await pool.query(
            'SELECT id, username FROM users WHERE username = ? OR unique_id = ? LIMIT 1',
            [query, query]
        );
        if (targets.length === 0) return res.status(404).json({ error: 'Jugador no encontrado' });
        const target = targets[0];

        const [already] = await pool.query(
            'SELECT id FROM club_members WHERE club_id = ? AND user_id = ?',
            [club_id, target.id]
        );
        if (already.length > 0) return res.status(400).json({ error: 'Ese jugador ya es miembro del club' });

        await pool.query(
            `INSERT INTO user_notifications (user_id, title, message, type, metadata)
             VALUES (?, 'Invitación de club', ?, 'club_invite', ?)`,
            [target.id,
             `Fuiste invitado al club "${clubs[0].name}". Únete con el código ${clubs[0].code} en la sección Club.`,
             JSON.stringify({ clubId: club_id, clubCode: clubs[0].code })]
        );

        res.json({ message: `Invitación enviada a ${target.username}` });
    } catch (error) {
        res.status(500).json({ error: 'Error al invitar al jugador' });
    }
});

// ===========================================================
// 🔥 TORNEOS DEL CLUB — el dueño o el moderador los crea
//   visibility 'members' → solo socios (niveles 0 y 1)
//   visibility 'public'  → visible en el lobby del casino (nivel 2: 1 activo, nivel 3: 3)
// ===========================================================
router.get('/clubs/tournaments', verifyToken, async (req, res) => {
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ?', [user_id]);
        if (memberships.length === 0) return res.status(404).json({ error: 'No perteneces a ningun club' });
        const club_id = memberships[0].club_id;

        const [tournaments] = await pool.query(
            'SELECT * FROM club_tournaments WHERE club_id = ? ORDER BY FIELD(status, "open","running","finished","cancelled"), created_at DESC',
            [club_id]
        );
        res.json(tournaments);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener los torneos del club' });
    }
});

router.post('/clubs/tournaments', verifyToken, validateClubTournament, async (req, res) => {
    const { name, type, mode, settings, visibility } = req.body;
    const user_id = req.user.id;

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [memberships] = await connection.query(
            'SELECT club_id, role FROM club_members WHERE user_id = ?',
            [user_id]
        );
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            throw new Error('Solo el dueño o el moderador pueden crear torneos');
        }
        const club_id = memberships[0].club_id;

        const [clubs] = await connection.query('SELECT tier FROM clubs WHERE id = ?', [club_id]);
        const tier = Number(clubs[0]?.tier || 0);
        const tierConfig = CLUB_TIERS[tier] || CLUB_TIERS[0];
        const finalVisibility = visibility === 'public' ? 'public' : 'members';

        if (finalVisibility === 'public' && tierConfig.public_tournaments === 0) {
            throw new Error('Tu nivel de club no permite torneos públicos en el lobby. Sube de nivel (100 o 300 NTX-20).');
        }
        if (finalVisibility === 'public') {
            const [activePublic] = await connection.query(
                "SELECT COUNT(*) as count FROM club_tournaments WHERE club_id = ? AND visibility = 'public' AND status IN ('open','running')",
                [club_id]
            );
            if (activePublic[0].count >= tierConfig.public_tournaments) {
                throw new Error(`Alcanzaste el máximo de ${tierConfig.public_tournaments} torneo(s) público(s) activos para tu nivel`);
            }
        }

        const [result] = await connection.query(
            `INSERT INTO club_tournaments (club_id, name, type, mode, settings, visibility, status, created_by)
             VALUES (?, ?, ?, ?, ?, ?, 'open', ?)`,
            [club_id, name, type || 'MTT', mode || 'NLH', JSON.stringify(settings || {}), finalVisibility, user_id]
        );

        await connection.commit();
        res.json({ message: 'Torneo del club creado', id: result.insertId });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.delete('/clubs/tournaments/:id', verifyToken, validateIdParam, async (req, res) => {
    const tournament_id = req.params.id;
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [user_id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            return res.status(403).json({ error: 'Solo el dueño o el moderador pueden eliminar torneos' });
        }
        const club_id = memberships[0].club_id;
        await pool.query('DELETE FROM club_tournaments WHERE id = ? AND club_id = ?', [tournament_id, club_id]);
        res.json({ message: 'Torneo eliminado' });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar el torneo' });
    }
});

// Torneos PÚBLICOS de clubes para el LOBBY del casino (donde están las otras mesas)
router.get('/clubs/public-tournaments', verifyToken, async (req, res) => {
    try {
        const [tournaments] = await pool.query(
            `SELECT ct.id, ct.club_id, ct.name, ct.type, ct.mode, ct.settings, ct.status, ct.created_at,
                    c.name AS club_name, c.code AS club_code, c.tier AS club_tier, c.avatar_url AS club_avatar
             FROM club_tournaments ct
             JOIN clubs c ON c.id = ct.club_id
             WHERE ct.visibility = 'public' AND ct.status IN ('open','running')
             ORDER BY ct.created_at DESC`
        );
        // Límite de torneos públicos activos por nivel de club (2 → 1, 3 → 3)
        const counts = {};
        const limited = [];
        for (const t of tournaments) {
            const limit = (CLUB_TIERS[t.club_tier] || CLUB_TIERS[0]).public_tournaments;
            counts[t.club_id] = (counts[t.club_id] || 0) + 1;
            if (counts[t.club_id] <= limit) limited.push(t);
        }
        res.json(limited);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener los torneos públicos de clubes' });
    }
});

// ===========================================================
// 🔥 GANANCIAS DEL CLUB — 97% del rake va a la billetera del dueño,
// 3% al Fondo del Proyecto (registrado en rake_ledger con source='club')
// ===========================================================
router.get('/clubs/earnings', verifyToken, async (req, res) => {
    const user_id = req.user.id;
    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [user_id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) {
            return res.status(403).json({ error: 'No autorizado' });
        }
        const club_id = memberships[0].club_id;

        const [totals] = await pool.query(
            "SELECT COALESCE(SUM(rake_amount),0) as total_rake, COALESCE(SUM(project_share),0) as total_project FROM rake_ledger WHERE source = 'club' AND club_id = ?",
            [club_id]
        );
        const [last24h] = await pool.query(
            "SELECT COALESCE(SUM(rake_amount),0) as rake_24h FROM rake_ledger WHERE source = 'club' AND club_id = ? AND created_at >= NOW() - INTERVAL 24 HOUR",
            [club_id]
        );
        const [clubs] = await pool.query('SELECT chip_balance FROM clubs WHERE id = ?', [club_id]);

        res.json({
            total_rake: Number(totals[0].total_rake || 0),
            owner_share_97: Number((Number(totals[0].total_rake || 0) * 0.97).toFixed(2)),
            project_share_3: Number(totals[0].total_project || 0),
            rake_24h: Number(last24h[0].rake_24h || 0),
            owner_24h: Number((Number(last24h[0].rake_24h || 0) * 0.97).toFixed(2)),
            club_balance: Number(clubs[0]?.chip_balance || 0),
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener las ganancias del club' });
    }
});

// ===========================================================
// PLANTILLAS Y MESAS (mesas con la configuración que el dueño desee)
// ===========================================================
router.post('/clubs/save-template', verifyToken, validateTemplateOrTable, async (req, res) => {
    const { title, type, mode, settings } = req.body;
    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) return res.status(403).json({ error: 'Solo los duenos pueden guardar plantillas' });
        const club_id = memberships[0].club_id;

        await pool.query(
            'INSERT INTO table_templates (club_id, title, type, mode, settings) VALUES (?, ?, ?, ?, ?)',
            [club_id, title, type, mode, JSON.stringify(settings)]
        );
        res.json({ message: 'Plantilla guardada exitosamente' });
    } catch (error) {
        console.error("ERROR MYSQL AL GUARDAR PLANTILLA:", error);
        res.status(500).json({ error: error.message });
    }
});

router.get('/clubs/templates', verifyToken, async (req, res) => {
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        const [templates] = await pool.query('SELECT * FROM table_templates WHERE club_id = ? ORDER BY created_at DESC', [club_id]);
        res.json(templates);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener plantillas' });
    }
});

router.delete('/clubs/templates/:id', verifyToken, validateIdParam, async (req, res) => {
    const template_id = req.params.id;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        await pool.query('DELETE FROM table_templates WHERE id = ? AND club_id = ?', [template_id, club_id]);
        res.json({ message: 'Plantilla eliminada' });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar la plantilla' });
    }
});

router.post('/clubs/tables', verifyToken, validateTemplateOrTable, async (req, res) => {
    const { title, type, mode, settings } = req.body;
    try {
        const [memberships] = await pool.query('SELECT club_id, role FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        await pool.query(
            'INSERT INTO active_tables (club_id, title, type, mode, settings) VALUES (?, ?, ?, ?, ?)',
            [club_id, title, type, mode, JSON.stringify(settings)]
        );
        res.json({ message: 'Mesa creada exitosamente' });
    } catch (error) {
        console.error("ERROR MYSQL AL CREAR MESA:", error);
        res.status(500).json({ error: error.message });
    }
});

router.get('/clubs/tables', verifyToken, async (req, res) => {
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        const [tables] = await pool.query(
            'SELECT * FROM active_tables WHERE club_id = ? AND status = "OPEN" ORDER BY created_at DESC',
            [club_id]
        );
        res.json(tables);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener mesas' });
    }
});

router.delete('/clubs/tables/:id', verifyToken, validateIdParam, async (req, res) => {
    const table_id = req.params.id;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ?', [req.user.id]);
        if (memberships.length === 0 || !canManage(memberships[0].role)) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        await pool.query('DELETE FROM active_tables WHERE id = ? AND club_id = ?', [table_id, club_id]);
        res.json({ message: 'Mesa eliminada' });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar la mesa' });
    }
});

module.exports = router;
// Exportado para pruebas y futuros módulos (p. ej. panel admin de clubes)
module.exports.CLUB_TIERS = CLUB_TIERS;
module.exports.CLUB_PROJECT_SHARE_PCT = require('../services/funds').CLUB_PROJECT_SHARE_PCT;

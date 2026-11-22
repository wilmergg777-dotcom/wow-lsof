const express = require('express');
const router = express.Router();

const pool = require('../db');
const { verifyToken } = require('../middlewares/auth');

router.post('/clubs/create', verifyToken, async (req, res) => {
    const { name } = req.body;
    const owner_id = req.user.id;

    if (!name) return res.status(400).json({ error: 'El nombre del club es obligatorio' });
    const code = 'CLUB' + Math.floor(1000 + Math.random() * 9000);

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [existing] = await connection.query('SELECT id FROM club_members WHERE user_id = ?', [owner_id]);
        if (existing.length > 0) throw new Error('Ya perteneces a un club');

        const [result] = await connection.query(
            'INSERT INTO clubs (name, code, owner_id, max_players) VALUES (?, ?, ?, 10)',
            [name, code, owner_id]
        );
        const club_id = result.insertId;

        await connection.query(
            'INSERT INTO club_members (club_id, user_id, role) VALUES (?, ?, "owner")',
            [club_id, owner_id]
        );

        await connection.commit();
        res.json({ message: 'Club creado exitosamente', club: { id: club_id, name, code, owner_id } });
    } catch (error) {
        await connection.rollback();
        res.status(400).json({ error: error.message });
    } finally {
        connection.release();
    }
});

router.post('/clubs/join', verifyToken, async (req, res) => {
    const { code } = req.body;
    const user_id = req.user.id;

    if (!code) return res.status(400).json({ error: 'El codigo es obligatorio' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const [existing] = await connection.query('SELECT id FROM club_members WHERE user_id = ?', [user_id]);
        if (existing.length > 0) throw new Error('Ya perteneces a un club');

        const [clubs] = await connection.query('SELECT * FROM clubs WHERE code = ?', [code]);
        if (clubs.length === 0) throw new Error('Club no encontrado con ese codigo');
        const club = clubs[0];

        const [players] = await connection.query(
            'SELECT COUNT(*) as count FROM club_members WHERE club_id = ? AND role = "player"',
            [club.id]
        );
        if (players[0].count >= club.max_players) throw new Error('El club esta lleno (Maximo 10 jugadores)');

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

        res.json({ club, role: my_role, current_players: players[0].count });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener informacion del club' });
    }
});

router.put('/clubs/update', verifyToken, async (req, res) => {
    const { name, description, avatar_url } = req.body;
    const user_id = req.user.id;

    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [user_id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'Solo el dueno puede editar el club' });

        const club_id = memberships[0].club_id;
        await pool.query(
            'UPDATE clubs SET name = ?, description = ?, avatar_url = ? WHERE id = ?',
            [name, description, avatar_url, club_id]
        );
        res.json({ message: 'Club actualizado correctamente' });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar el club' });
    }
});

router.put('/clubs/discord-settings', verifyToken, async (req, res) => {
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

router.post('/clubs/save-template', verifyToken, async (req, res) => {
    const { title, type, mode, settings } = req.body;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'Solo los duenos pueden guardar plantillas' });
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
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        const [templates] = await pool.query('SELECT * FROM table_templates WHERE club_id = ? ORDER BY created_at DESC', [club_id]);
        res.json(templates);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener plantillas' });
    }
});

router.delete('/clubs/templates/:id', verifyToken, async (req, res) => {
    const template_id = req.params.id;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        await pool.query('DELETE FROM table_templates WHERE id = ? AND club_id = ?', [template_id, club_id]);
        res.json({ message: 'Plantilla eliminada' });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar la plantilla' });
    }
});

router.post('/clubs/tables', verifyToken, async (req, res) => {
    const { title, type, mode, settings } = req.body;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
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

router.delete('/clubs/tables/:id', verifyToken, async (req, res) => {
    const table_id = req.params.id;
    try {
        const [memberships] = await pool.query('SELECT club_id FROM club_members WHERE user_id = ? AND role = "owner"', [req.user.id]);
        if (memberships.length === 0) return res.status(403).json({ error: 'No autorizado' });
        const club_id = memberships[0].club_id;

        await pool.query('DELETE FROM active_tables WHERE id = ? AND club_id = ?', [table_id, club_id]);
        res.json({ message: 'Mesa eliminada' });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar la mesa' });
    }
});

module.exports = router;
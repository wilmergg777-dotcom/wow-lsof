<?php

/**
 * PVEEmpireTemplateHelper — AstroIO v1.1
 *
 * Gestiona las PLANTILLAS de imperios PvE:
 *   - listar / obtener
 *   - crear / actualizar / borrar
 *   - duplicar
 *   - marcar como default
 *   - activar / desactivar
 *   - parsear los JSON (ships, defenses, buildings)
 *
 * Tabla: uni1_pve_empire_templates
 *
 * v1.0 — CRUD de plantillas + parseo JSON + sanitización
 *
 * v1.1 — DOBLE RIEL (NTX-20 / UNTX-20):
 *   · Este helper NO toca NTX-20 ni UNTX-20 en ningún punto.
 *   · Las plantillas de imperios PvE solo definen:
 *       - HP base (hp_mult)
 *       - Recursos universales (metal/crystal/deuterium)
 *       - Naves / defensas / edificios (ships/defenses/buildings)
 *       - Configuración de viaje, oleadas, regeneración y programación
 *   · Los recursos son UNIVERSALES (no dependen del `metodo_retiro` del
 *     jugador). El botín del Imperio Caído se reparte en metal/crystal/
 *     deuterium y NUNCA en NTX-20/UNTX-20.
 *   · No hay detección de riel, ni getPlayerMethod(), ni isIntl(),
 *     ni getPrecioParaJugador(), ni addBalance(), ni removeBalance(),
 *     ni WalletHelper, ni NTX20LogHelper.
 *   · Se añaden las constantes UNTX_MULTIPLIER y RIELS por coherencia
 *     con el resto de helpers PvE/PvP, aunque este archivo no las use
 *     funcionalmente.
 *   · Se documenta explícitamente en el header para evitar "arreglos"
 *     futuros innecesarios (aplicar ×2 a recursos sería un bug).
 *
 * @package AstroIO
 * @subpackage PvE
 * @version 1.1
 */

class PVEEmpireTemplateHelper
{
    /* ============================================================
     *  CONSTANTES
     * ============================================================ */

    // Regla ×2 centralizada (por coherencia con el resto de helpers PvE/PvP)
    const UNTX_MULTIPLIER = 2;

    // Rieles válidos
    const RIELS = array('CUP', 'QVAPAY');


    // ═══════════════════════════════════════════════════════════════
    //  LECTURA
    // ═══════════════════════════════════════════════════════════════

    /**
     * Devuelve TODAS las plantillas (activas e inactivas por defecto).
     *
     * @param bool $onlyActive  Si true, solo devuelve activas
     * @return array
     */
    public static function getAllTemplates(bool $onlyActive = false): array
    {
        $db = Database::get();

        $sql = "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%%";
        if ($onlyActive) {
            $sql .= " WHERE is_active = 1";
        }
        $sql .= " ORDER BY is_default DESC, id ASC;";

        try {
            $rows = $db->select($sql);
            return is_array($rows) ? $rows : [];
        } catch (Throwable $e) {
            return [];
        }
    }

    /**
     * Devuelve una plantilla por su ID (o null).
     *
     * @param int $id
     * @return array|null
     */
    public static function getTemplate(int $id): ?array
    {
        if ($id <= 0) return null;

        $db = Database::get();

        try {
            $row = $db->selectSingle(
                "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%% WHERE id = :id LIMIT 1;",
                [':id' => $id]
            );
            return !empty($row) ? $row : null;
        } catch (Throwable $e) {
            return null;
        }
    }

    /**
     * Devuelve una plantilla por su slug (o null).
     *
     * @param string $slug
     * @return array|null
     */
    public static function getTemplateBySlug(string $slug): ?array
    {
        if ($slug === '') return null;

        $db = Database::get();

        try {
            $row = $db->selectSingle(
                "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%% WHERE slug = :slug LIMIT 1;",
                [':slug' => $slug]
            );
            return !empty($row) ? $row : null;
        } catch (Throwable $e) {
            return null;
        }
    }

    /**
     * Devuelve la plantilla marcada como DEFAULT (o la primera activa
     * si no hay default marcada, o la "Normal" como último fallback).
     *
     * @return array|null
     */
    public static function getDefaultTemplate(): ?array
    {
        $db = Database::get();

        // 1) Buscar la marcada como default y activa
        try {
            $row = $db->selectSingle(
                "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%%
                 WHERE is_default = 1 AND is_active = 1
                 LIMIT 1;"
            );
            if (!empty($row)) return $row;
        } catch (Throwable $e) {}

        // 2) Buscar cualquier activa
        try {
            $row = $db->selectSingle(
                "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%%
                 WHERE is_active = 1
                 ORDER BY id ASC LIMIT 1;"
            );
            if (!empty($row)) return $row;
        } catch (Throwable $e) {}

        // 3) Buscar por slug "normal"
        try {
            $row = $db->selectSingle(
                "SELECT * FROM %%PVE_EMPIRE_TEMPLATES%%
                 WHERE slug = 'normal' LIMIT 1;"
            );
            if (!empty($row)) return $row;
        } catch (Throwable $e) {}

        return null;
    }

    // ═══════════════════════════════════════════════════════════════
    //  ESCRITURA
    // ═══════════════════════════════════════════════════════════════

    /**
     * Crea una nueva plantilla.
     *
     * @param array $data
     * @return int  ID de la nueva plantilla (0 si falla)
     */
    public static function createTemplate(array $data): int
    {
        $db  = Database::get();
        $now = TIMESTAMP;

        $clean = self::sanitize($data);

        // Comprobar slug único
        if (self::getTemplateBySlug($clean['slug']) !== null) {
            // ✅ v3.8 — Truncar ANTES del sufijo: la columna es varchar(32)
            // UNIQUE y sanitize() ya trunca a 32 → slug + '_' + 4 chars = 37
            // y el INSERT moría con STRICT_ALL_TABLES (error 1406, la
            // plantilla no se creaba y createTemplate devolvía 0 en silencio).
            $clean['slug'] = substr($clean['slug'], 0, 27) . '_' . substr(md5((string)mt_rand()), 0, 4);
        }

        try {
            $db->insert(
                "INSERT INTO %%PVE_EMPIRE_TEMPLATES%%
                 (name, slug, description,
                  hp_mult,
                  res_metal, res_crystal, res_deuterium,
                  ships, defenses, buildings,
                  travel_mode, travel_min, travel_max, travel_fixed,
                  scheduled_day, scheduled_hour, scheduled_minute,
                  fleet_speed_pct,
                  waves_enabled, waves_count, waves_delay_min,
                  regen_enabled, regen_interval_min, regen_pct,
                  is_default, is_active,
                  created_at, updated_at)
                 VALUES
                 (:name, :slug, :description,
                  :hp_mult,
                  :res_metal, :res_crystal, :res_deuterium,
                  :ships, :defenses, :buildings,
                  :travel_mode, :travel_min, :travel_max, :travel_fixed,
                  :sched_day, :sched_hour, :sched_min,
                  :speed,
                  :waves_enabled, :waves_count, :waves_delay,
                  :regen_enabled, :regen_interval, :regen_pct,
                  :is_default, :is_active,
                  :now, :now);",
                [
                    ':name'         => $clean['name'],
                    ':slug'         => $clean['slug'],
                    ':description'  => $clean['description'],
                    ':hp_mult'      => $clean['hp_mult'],
                    ':res_metal'    => $clean['res_metal'],
                    ':res_crystal'  => $clean['res_crystal'],
                    ':res_deuterium'=> $clean['res_deuterium'],
                    ':ships'        => json_encode($clean['ships']),
                    ':defenses'     => json_encode($clean['defenses']),
                    ':buildings'    => json_encode($clean['buildings']),
                    ':travel_mode'  => $clean['travel_mode'],
                    ':travel_min'   => $clean['travel_min'],
                    ':travel_max'   => $clean['travel_max'],
                    ':travel_fixed' => $clean['travel_fixed'],
                    ':sched_day'    => $clean['scheduled_day'],
                    ':sched_hour'   => $clean['scheduled_hour'],
                    ':sched_min'    => $clean['scheduled_minute'],
                    ':speed'        => $clean['fleet_speed_pct'],
                    ':waves_enabled'=> $clean['waves_enabled'],
                    ':waves_count'  => $clean['waves_count'],
                    ':waves_delay'  => $clean['waves_delay_min'],
                    ':regen_enabled'=> $clean['regen_enabled'],
                    ':regen_interval'=> $clean['regen_interval_min'],
                    ':regen_pct'    => $clean['regen_pct'],
                    ':is_default'   => $clean['is_default'],
                    ':is_active'    => $clean['is_active'],
                    ':now'          => $now,
                ]
            );

            $id = (int) $db->lastInsertId();

            // Si es default, quitar el default a las demás
            if ($clean['is_default'] == 1 && $id > 0) {
                self::setDefaultTemplate($id);
            }

            return $id;
        } catch (Throwable $e) {
            return 0;
        }
    }

    /**
     * Actualiza una plantilla existente.
     *
     * @param int   $id
     * @param array $data
     * @return bool
     */
    public static function updateTemplate(int $id, array $data): bool
    {
        if ($id <= 0) return false;
        if (self::getTemplate($id) === null) return false;

        $db  = Database::get();
        $now = TIMESTAMP;

        $clean = self::sanitize($data);

        try {
            $db->update(
                "UPDATE %%PVE_EMPIRE_TEMPLATES%% SET
                    name              = :name,
                    slug              = :slug,
                    description       = :description,
                    hp_mult           = :hp_mult,
                    res_metal         = :res_metal,
                    res_crystal       = :res_crystal,
                    res_deuterium     = :res_deuterium,
                    ships             = :ships,
                    defenses          = :defenses,
                    buildings         = :buildings,
                    travel_mode       = :travel_mode,
                    travel_min        = :travel_min,
                    travel_max        = :travel_max,
                    travel_fixed      = :travel_fixed,
                    scheduled_day     = :sched_day,
                    scheduled_hour    = :sched_hour,
                    scheduled_minute  = :sched_min,
                    fleet_speed_pct   = :speed,
                    waves_enabled     = :waves_enabled,
                    waves_count       = :waves_count,
                    waves_delay_min   = :waves_delay,
                    regen_enabled     = :regen_enabled,
                    regen_interval_min= :regen_interval,
                    regen_pct         = :regen_pct,
                    is_default        = :is_default,
                    is_active         = :is_active,
                    updated_at        = :now
                 WHERE id = :id;",
                [
                    ':id'           => $id,
                    ':name'         => $clean['name'],
                    ':slug'         => $clean['slug'],
                    ':description'  => $clean['description'],
                    ':hp_mult'      => $clean['hp_mult'],
                    ':res_metal'    => $clean['res_metal'],
                    ':res_crystal'  => $clean['res_crystal'],
                    ':res_deuterium'=> $clean['res_deuterium'],
                    ':ships'        => json_encode($clean['ships']),
                    ':defenses'     => json_encode($clean['defenses']),
                    ':buildings'    => json_encode($clean['buildings']),
                    ':travel_mode'  => $clean['travel_mode'],
                    ':travel_min'   => $clean['travel_min'],
                    ':travel_max'   => $clean['travel_max'],
                    ':travel_fixed' => $clean['travel_fixed'],
                    ':sched_day'    => $clean['scheduled_day'],
                    ':sched_hour'   => $clean['scheduled_hour'],
                    ':sched_min'    => $clean['scheduled_minute'],
                    ':speed'        => $clean['fleet_speed_pct'],
                    ':waves_enabled'=> $clean['waves_enabled'],
                    ':waves_count'  => $clean['waves_count'],
                    ':waves_delay'  => $clean['waves_delay_min'],
                    ':regen_enabled'=> $clean['regen_enabled'],
                    ':regen_interval'=> $clean['regen_interval_min'],
                    ':regen_pct'    => $clean['regen_pct'],
                    ':is_default'   => $clean['is_default'],
                    ':is_active'    => $clean['is_active'],
                    ':now'          => $now,
                ]
            );

            // Si se marcó como default, quitar el default a las demás
            if ($clean['is_default'] == 1) {
                self::setDefaultTemplate($id);
            }

            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    /**
     * Elimina una plantilla.
     * Impide borrar la default (primero hay que marcar otra como default).
     *
     * @param int $id
     * @return bool
     */
    public static function deleteTemplate(int $id): bool
    {
        if ($id <= 0) return false;

        $template = self::getTemplate($id);
        if ($template === null) return false;

        // No permitir borrar la default
        if ((int) $template['is_default'] === 1) {
            return false;
        }

        $db = Database::get();

        try {
            $db->delete(
                "DELETE FROM %%PVE_EMPIRE_TEMPLATES%% WHERE id = :id;",
                [':id' => $id]
            );
            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    /**
     * Duplica una plantilla existente.
     *
     * @param int $id
     * @return int  ID de la copia (0 si falla)
     */
    public static function duplicateTemplate(int $id): int
    {
        $template = self::getTemplate($id);
        if ($template === null) return 0;

        // Reconstruir data para createTemplate
        $data = [
            'name'              => $template['name'] . ' (Copia)',
            // ✅ v3.8 — Truncar antes del sufijo (_copy_ = 6 + 4 chars):
            // slug completo superaba varchar(32) y el INSERT fallaba en STRICT.
            'slug'              => substr($template['slug'], 0, 21) . '_copy_' . substr(md5((string)mt_rand()), 0, 4),
            'description'       => $template['description'],
            'hp_mult'           => $template['hp_mult'],
            'res_metal'         => $template['res_metal'],
            'res_crystal'       => $template['res_crystal'],
            'res_deuterium'     => $template['res_deuterium'],
            'ships'             => self::parseShips($template),
            'defenses'          => self::parseDefenses($template),
            'buildings'         => self::parseBuildings($template),
            'travel_mode'       => $template['travel_mode'],
            'travel_min'        => $template['travel_min'],
            'travel_max'        => $template['travel_max'],
            'travel_fixed'      => $template['travel_fixed'],
            'scheduled_day'     => $template['scheduled_day'],
            'scheduled_hour'    => $template['scheduled_hour'],
            'scheduled_minute'  => $template['scheduled_minute'],
            'fleet_speed_pct'   => $template['fleet_speed_pct'],
            'waves_enabled'     => $template['waves_enabled'],
            'waves_count'       => $template['waves_count'],
            'waves_delay_min'   => $template['waves_delay_min'],
            'regen_enabled'     => $template['regen_enabled'],
            'regen_interval_min'=> $template['regen_interval_min'],
            'regen_pct'         => $template['regen_pct'],
            'is_default'        => 0,
            'is_active'         => $template['is_active'],
        ];

        return self::createTemplate($data);
    }

    /**
     * Marca una plantilla como DEFAULT (quita el default a las demás).
     *
     * @param int $id
     * @return bool
     */
    public static function setDefaultTemplate(int $id): bool
    {
        if ($id <= 0) return false;

        $db = Database::get();

        try {
            // Quitar default a todas
            $db->update(
                "UPDATE %%PVE_EMPIRE_TEMPLATES%% SET is_default = 0 WHERE is_default = 1;"
            );

            // Marcar la nueva
            $db->update(
                "UPDATE %%PVE_EMPIRE_TEMPLATES%% SET is_default = 1 WHERE id = :id;",
                [':id' => $id]
            );

            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    /**
     * Activa o desactiva una plantilla.
     *
     * @param int  $id
     * @param bool $active
     * @return bool
     */
    public static function toggleActive(int $id, bool $active): bool
    {
        if ($id <= 0) return false;

        $db = Database::get();

        try {
            $db->update(
                "UPDATE %%PVE_EMPIRE_TEMPLATES%%
                 SET is_active = :active, updated_at = :now
                 WHERE id = :id;",
                [
                    ':active' => $active ? 1 : 0,
                    ':now'    => TIMESTAMP,
                    ':id'     => $id,
                ]
            );
            return true;
        } catch (Throwable $e) {
            return false;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  PARSEO DE JSON
    // ═══════════════════════════════════════════════════════════════

    /**
     * Decodifica el JSON de ships de la plantilla.
     * Devuelve array [shipId => cantidad].
     */
    public static function parseShips(array $template): array
    {
        return self::parseJsonField($template, 'ships');
    }

    /**
     * Decodifica el JSON de defenses.
     */
    public static function parseDefenses(array $template): array
    {
        return self::parseJsonField($template, 'defenses');
    }

    /**
     * Decodifica el JSON de buildings.
     */
    public static function parseBuildings(array $template): array
    {
        return self::parseJsonField($template, 'buildings');
    }

    /**
     * Helper genérico de parseo.
     */
    private static function parseJsonField(array $template, string $field): array
    {
        if (empty($template[$field])) return [];

        $raw = $template[$field];
        if (is_array($raw)) return $raw; // por si acaso

        $decoded = json_decode($raw, true);
        if (!is_array($decoded)) return [];

        // Normalizar: keys a int, values a int, quitar <= 0
        $clean = [];
        foreach ($decoded as $k => $v) {
            $k = (int) $k;
            $v = (int) $v;
            if ($k > 0 && $v > 0) {
                $clean[$k] = $v;
            }
        }
        return $clean;
    }

    // ═══════════════════════════════════════════════════════════════
    //  SANITIZACIÓN
    // ═══════════════════════════════════════════════════════════════

    /**
     * Valida y normaliza los datos de una plantilla antes de guardar.
     *
     * v1.1 — DOBLE RIEL: NO APLICA.
     *
     *   Los campos `res_metal`, `res_crystal`, `res_deuterium` son
     *   recursos UNIVERSALES. NO dependen del `metodo_retiro` del jugador.
     *   El ×2 de UNTX-20 solo aplica a NTX-20/UNTX-20, no a recursos.
     *
     *   Por eso NO hay multiplicador aquí. Los recursos se guardan tal
     *   cual el admin los configura y se reparten tal cual a los
     *   contribuyentes del Imperio Caído.
     */
    private static function sanitize(array $data): array
    {
        return [
            'name'              => self::cleanString($data['name'] ?? '', 64, 'Sin nombre'),
            'slug'              => self::cleanSlug($data['slug'] ?? ($data['name'] ?? 'template')),
            'description'       => self::cleanString($data['description'] ?? '', 500, ''),
            'hp_mult'           => self::cleanDecimal($data['hp_mult'] ?? 5.00, 0.01, 999.99),

            // ⚠️ Recursos universales (sin ×2 ni detección de riel)
            'res_metal'         => self::cleanInt($data['res_metal'] ?? 0, 0),
            'res_crystal'       => self::cleanInt($data['res_crystal'] ?? 0, 0),
            'res_deuterium'     => self::cleanInt($data['res_deuterium'] ?? 0, 0),

            'ships'             => self::cleanJsonArray($data['ships'] ?? []),
            'defenses'          => self::cleanJsonArray($data['defenses'] ?? []),
            'buildings'         => self::cleanJsonArray($data['buildings'] ?? []),

            'travel_mode'       => self::cleanEnum(
                $data['travel_mode'] ?? 'random',
                ['instant', 'scheduled', 'random', 'fixed'],
                'random'
            ),
            'travel_min'        => self::cleanInt($data['travel_min'] ?? 30, 0, 99999),
            'travel_max'        => self::cleanInt($data['travel_max'] ?? 120, 0, 99999),
            'travel_fixed'      => self::cleanInt($data['travel_fixed'] ?? 60, 0, 99999),

            'scheduled_day'     => self::cleanInt($data['scheduled_day'] ?? 0, 0, 31),
            'scheduled_hour'    => self::cleanInt($data['scheduled_hour'] ?? 0, 0, 23),
            'scheduled_minute'  => self::cleanInt($data['scheduled_minute'] ?? 0, 0, 59),

            'fleet_speed_pct'   => self::cleanInt($data['fleet_speed_pct'] ?? 100, 10, 500),

            'waves_enabled'     => self::cleanBoolInt($data['waves_enabled'] ?? 0),
            'waves_count'       => self::cleanInt($data['waves_count'] ?? 1, 1, 20),
            'waves_delay_min'   => self::cleanInt($data['waves_delay_min'] ?? 10, 1, 1440),

            'regen_enabled'     => self::cleanBoolInt($data['regen_enabled'] ?? 0),
            'regen_interval_min'=> self::cleanInt($data['regen_interval_min'] ?? 15, 1, 1440),
            'regen_pct'         => self::cleanDecimal($data['regen_pct'] ?? 10.00, 0.00, 100.00),

            'is_default'        => self::cleanBoolInt($data['is_default'] ?? 0),
            'is_active'         => self::cleanBoolInt($data['is_active'] ?? 1),
        ];
    }

    private static function cleanString($value, int $max, string $default): string
    {
        $value = trim((string) $value);
        if ($value === '') $value = $default;
        if (mb_strlen($value) > $max) {
            $value = mb_substr($value, 0, $max);
        }
        return $value;
    }

    private static function cleanSlug($value): string
    {
        $value = strtolower(trim((string) $value));
        $value = preg_replace('/[^a-z0-9_\-]/', '_', $value);
        $value = trim($value, '_');
        if ($value === '') $value = 'template';
        if (strlen($value) > 32) $value = substr($value, 0, 32);
        return $value;
    }

    private static function cleanInt($value, int $min, int $max = PHP_INT_MAX): int
    {
        $value = (int) $value;
        if ($value < $min) $value = $min;
        if ($value > $max) $value = $max;
        return $value;
    }

    private static function cleanDecimal($value, float $min, float $max): float
    {
        $value = (float) $value;
        if ($value < $min) $value = $min;
        if ($value > $max) $value = $max;
        return round($value, 2);
    }

    private static function cleanBoolInt($value): int
    {
        return (!empty($value) && $value != '0') ? 1 : 0;
    }

    private static function cleanEnum($value, array $allowed, $default)
    {
        $value = (string) $value;
        return in_array($value, $allowed, true) ? $value : $default;
    }

    /**
     * Limpia un array JSON {id => cantidad} para que solo contenga
     * claves y valores positivos.
     */
    private static function cleanJsonArray($value): array
    {
        if (is_string($value)) {
            $decoded = json_decode($value, true);
            if (is_array($decoded)) $value = $decoded;
        }
        if (!is_array($value)) return [];

        $clean = [];
        foreach ($value as $k => $v) {
            $k = (int) $k;
            $v = (int) $v;
            if ($k > 0 && $v > 0) {
                $clean[$k] = $v;
            }
        }
        return $clean;
    }
}
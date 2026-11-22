<?php
/**
 * TaskHelper.class.php
 * Sistema de Tareas AstroIO v1.1
 *
 * ASTROIO-FIX v1.1 (NTX-20):
 *  - Hook NTX20LogHelper::log() en doTaskAndReward() cuando la recompensa es NTX-20 (ingreso)
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

class TaskHelper
{
    private static function prefix()
    {
        return 'uni1_';
    }

    /**
     * 🆕 ASTROIO v1.1 — Carga el helper de auditoría NTX-20 (si existe)
     */
    private static function loadNtxLogHelper()
    {
        if (class_exists('NTX20LogHelper')) return true;

        if (defined('ROOT_PATH')) {
            $file = ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
        } else {
            $file = dirname(__FILE__) . '/NTX20LogHelper.class.php';
        }

        if (file_exists($file)) {
            require_once $file;
        }
        return class_exists('NTX20LogHelper');
    }

    /**
     * 🆕 ASTROIO v1.1 — Wrapper seguro para el log (no rompe si falla)
     */
    private static function logNtx20($userId, $amount, $type, $description = '', $refId = 0)
    {
        try {
            if (!self::loadNtxLogHelper()) return;
            NTX20LogHelper::log($userId, $amount, $type, $description, $refId);
        } catch (Exception $e) {
            // silencioso
        }
    }

    /**
     * Obtiene todas las tareas activas con el progreso del jugador
     */
    public static function getUserTasks($userId)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $tasks = $db->select("SELECT * FROM `" . $prefix . "tasks_catalog` WHERE `is_active` = 1 ORDER BY `sort_order` ASC");
        $progressRows = $db->select("SELECT * FROM `" . $prefix . "users_tasks` WHERE `user_id` = :uid", [':uid' => $userId]);

        $progressMap = [];
        foreach ($progressRows as $row) {
            $progressMap[$row['task_id']] = $row;
        }

        $result = [];
        foreach ($tasks as $task) {
            $taskId = $task['id'];
            $progress = isset($progressMap[$taskId]) ? $progressMap[$taskId] : null;

            $result[] = [
                'id'             => $task['id'],
                'code'           => $task['code'],
                'title'          => $task['title'],
                'description'    => $task['description'],
                'type'           => $task['type'],
                'action'         => $task['action'],
                'target_amount'  => $task['target_amount'],
                'reward_type'    => $task['reward_type'],
                'reward_amount'  => $task['reward_amount'],
                'external_url'   => $task['external_url'],
                'icon'           => $task['icon'],
                'status'         => $progress ? $progress['status'] : 'pending',
                'progress'       => $progress ? $progress['progress'] : 0,
                'completed_at'   => $progress ? $progress['completed_at'] : 0,
                'claimed_at'     => $progress ? $progress['claimed_at'] : 0,
            ];
        }

        return $result;
    }

    /**
     * Obtiene una tarea por su codigo
     */
    public static function getTaskByCode($code)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $row = $db->selectSingle("SELECT * FROM `" . $prefix . "tasks_catalog` WHERE `code` = :code AND `is_active` = 1 LIMIT 1", [':code' => $code]);

        return !empty($row) ? $row : null;
    }

    /**
     * Completa una tarea y otorga la recompensa en un solo paso.
     */
    public static function doTaskAndReward($userId, $taskId)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $task = $db->selectSingle("SELECT * FROM `" . $prefix . "tasks_catalog` WHERE `id` = :id AND `is_active` = 1", [':id' => $taskId]);
        if (empty($task)) {
            return ['success' => false, 'message' => 'Tarea no encontrada.', 'url' => ''];
        }

        $existing = $db->selectSingle("SELECT * FROM `" . $prefix . "users_tasks` WHERE `user_id` = :uid AND `task_id` = :tid", [
            ':uid' => $userId,
            ':tid' => $taskId
        ]);

        if (!empty($existing) && $existing['status'] === 'claimed') {
            return ['success' => false, 'message' => 'Ya completaste esta mision.', 'url' => ''];
        }

        $rewardType = $task['reward_type'];
        $rewardAmount = $task['reward_amount'];

        switch ($rewardType) {
            case 'ntx20':
                $db->update("UPDATE `" . $prefix . "users` SET `ntx20` = `ntx20` + :amt WHERE `id` = :uid", [
                    ':amt' => $rewardAmount,
                    ':uid' => $userId
                ]);
                if (isset($GLOBALS['USER']['ntx20'])) {
                    $GLOBALS['USER']['ntx20'] += $rewardAmount;
                }

                // 🆕 ASTROIO v1.1 — Registrar ingreso por tarea completada
                self::logNtx20(
                    $userId,
                    +$rewardAmount,
                    'earn_task',
                    'Tarea completada: ' . $task['title'],
                    (int) $taskId
                );
                break;

            case 'darkmatter':
                $db->update("UPDATE `" . $prefix . "users` SET `darkmatter` = `darkmatter` + :amt WHERE `id` = :uid", [
                    ':amt' => $rewardAmount,
                    ':uid' => $userId
                ]);
                if (isset($GLOBALS['USER']['darkmatter'])) {
                    $GLOBALS['USER']['darkmatter'] += $rewardAmount;
                }
                break;

            case 'metal':
                $db->update("UPDATE `" . $prefix . "planets` SET `metal` = `metal` + :amt WHERE `id_owner` = :uid AND `planet_type` = 1", [
                    ':amt' => $rewardAmount,
                    ':uid' => $userId
                ]);
                break;

            case 'crystal':
                $db->update("UPDATE `" . $prefix . "planets` SET `crystal` = `crystal` + :amt WHERE `id_owner` = :uid AND `planet_type` = 1", [
                    ':amt' => $rewardAmount,
                    ':uid' => $userId
                ]);
                break;

            case 'deuterium':
                $db->update("UPDATE `" . $prefix . "planets` SET `deuterium` = `deuterium` + :amt WHERE `id_owner` = :uid AND `planet_type` = 1", [
                    ':amt' => $rewardAmount,
                    ':uid' => $userId
                ]);
                break;

            case 'none':
                break;
        }

        if (empty($existing)) {
            $db->insert("INSERT INTO `" . $prefix . "users_tasks` (`user_id`, `task_id`, `progress`, `status`, `completed_at`, `claimed_at`) VALUES (:uid, :tid, :prog, 'claimed', :time, :time2)", [
                ':uid'   => $userId,
                ':tid'   => $taskId,
                ':prog'  => $task['target_amount'],
                ':time'  => time(),
                ':time2' => time()
            ]);
        } else {
            $db->update("UPDATE `" . $prefix . "users_tasks` SET `progress` = :prog, `status` = 'claimed', `completed_at` = :time, `claimed_at` = :time2 WHERE `id` = :id", [
                ':prog'  => $task['target_amount'],
                ':time'  => time(),
                ':time2' => time(),
                ':id'    => $existing['id']
            ]);
        }

        self::log($userId, $taskId, 'reclamada', 'Recompensa otorgada: ' . $rewardAmount . ' ' . $rewardType);

        return [
            'success' => true,
            'message' => 'Mision completada. Recompensa otorgada.',
            'url'     => $task['external_url']
        ];
    }

    /**
     * Verifica si el jugador tiene la Tarea 3 completada
     */
    public static function hasTelegramLink($userId)
    {
        $prefix = self::prefix();
        $db = Database::get();

        $task = self::getTaskByCode('telegram_link');
        if (empty($task)) {
            return true;
        }

        $row = $db->selectSingle("SELECT `status` FROM `" . $prefix . "users_tasks` WHERE `user_id` = :uid AND `task_id` = :tid", [
            ':uid' => $userId,
            ':tid' => $task['id']
        ]);

        if (empty($row)) {
            return false;
        }

        return in_array($row['status'], ['completed', 'claimed']);
    }

    /**
     * Registra una accion en el log
     */
    private static function log($userId, $taskId, $action, $detalle = '')
    {
        $prefix = self::prefix();
        $db = Database::get();

        $db->insert("INSERT INTO `" . $prefix . "tasks_log` (`user_id`, `task_id`, `action`, `detalle`, `fecha`) VALUES (:uid, :tid, :action, :detalle, :time)", [
            ':uid'     => $userId,
            ':tid'     => $taskId,
            ':action'  => $action,
            ':detalle' => $detalle,
            ':time'    => time()
        ]);
    }
}
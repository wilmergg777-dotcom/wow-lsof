<?php
/**
 * ShowTasksPage.class.php
 * Controlador de la pagina de Tareas y Logros (Jugador)
 *
 * URL: game.php?page=tasks
 *      game.php?page=tasks&tab=achievements
 */

if (!defined('MODE')) {
    die('Hacking attempt');
}

require_once 'includes/classes/TaskHelper.class.php';
require_once 'includes/classes/AchievementHelper.class.php';

class ShowTasksPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Pagina principal: lista de tareas
     * Si tab=achievements, muestra los logros
     */
    public function show(): void
    {
        global $USER;

        $tab = isset($_GET['tab']) ? $_GET['tab'] : 'tasks';

        if ($tab === 'achievements') {
            $this->showAchievements();
            return;
        }

        // Pestana de Tareas
        $userId = (int) $USER['id'];

        $tasks = TaskHelper::getUserTasks($userId);

        $taskList = [];
        foreach ($tasks as $task) {
            $statusLabel = '';
            $statusClass = '';

            switch ($task['status']) {
                case 'pending':
                    $statusLabel = 'Pendiente';
                    $statusClass = 'pending';
                    break;
                case 'completed':
                    $statusLabel = 'Completada';
                    $statusClass = 'completed';
                    break;
                case 'claimed':
                    $statusLabel = 'Completada';
                    $statusClass = 'claimed';
                    break;
            }

            if ($task['reward_type'] === 'none') {
                $rewardText = 'Desbloquea Banco y Mercado Negro';
            } else {
                $rewardText = number_format((int) $task['reward_amount'], 0, ',', '.');
            }

            $taskList[] = [
                'id'             => $task['id'],
                'code'           => $task['code'],
                'title'          => $task['title'],
                'description'    => $task['description'],
                'status'         => $task['status'],
                'status_label'   => $statusLabel,
                'status_class'   => $statusClass,
                'reward_text'    => $rewardText,
                'reward_type'    => $task['reward_type'],
                'reward_amount'  => (int) $task['reward_amount'],
                'external_url'   => $task['external_url'],
                'icon'           => $task['icon'],
                'can_do'         => ($task['status'] === 'pending'),
                'is_done'        => ($task['status'] === 'completed' || $task['status'] === 'claimed'),
            ];
        }

        $message = '';
        $messageType = '';
        if (!empty($_SESSION['task_message'])) {
            $message = $_SESSION['task_message'];
            $messageType = $_SESSION['task_message_type'] ?? 'success';
            unset($_SESSION['task_message'], $_SESSION['task_message_type']);
        }

        $this->assign([
            'tasks'           => $taskList,
            'message'         => $message,
            'message_type'    => $messageType,
            'user_ntx20'      => (int) $USER['ntx20'],
            'user_darkmatter' => (int) $USER['darkmatter'],
            'active_tab'      => 'tasks',
        ]);

        $this->display('page.tasks.default.tpl');
    }

    /**
     * Muestra la pestana de Logros
     */
    private function showAchievements(): void
    {
        global $USER;

        $userId = (int) $USER['id'];

        $achievements = AchievementHelper::getUserAchievements($userId);

        $message = '';
        $messageType = '';
        if (!empty($_SESSION['ach_message'])) {
            $message = $_SESSION['ach_message'];
            $messageType = $_SESSION['ach_message_type'] ?? 'success';
            unset($_SESSION['ach_message'], $_SESSION['ach_message_type']);
        }

        $this->assign([
            'achievements'    => $achievements,
            'message'         => $message,
            'message_type'    => $messageType,
            'user_darkmatter' => (int) $USER['darkmatter'],
            'active_tab'      => 'achievements',
        ]);

        $this->display('page.tasks.achievements.tpl');
    }

    /**
     * Reclama la recompensa de un logro
     * GET: code
     */
    public function claimAch(): void
    {
        global $USER;

        $userId = (int) $USER['id'];
        $code = isset($_GET['code']) ? trim($_GET['code']) : '';

        if (empty($code)) {
            $_SESSION['ach_message'] = 'Codigo de logro invalido.';
            $_SESSION['ach_message_type'] = 'error';
            $this->redirectTo('game.php?page=tasks&tab=achievements');
            return;
        }

        $result = AchievementHelper::claimAchievement($userId, $code);

        if ($result['success']) {
            $_SESSION['ach_message'] = $result['message'];
            $_SESSION['ach_message_type'] = 'success';
        } else {
            $_SESSION['ach_message'] = $result['message'];
            $_SESSION['ach_message_type'] = 'error';
        }

        $this->redirectTo('game.php?page=tasks&tab=achievements');
    }

    /**
     * Completa la mision y da la recompensa.
     * GET: id
     * Redirige al enlace externo despues de completar.
     */
    public function doTask(): void
    {
        global $USER;

        $userId = (int) $USER['id'];
        $taskId = isset($_GET['id']) ? (int) $_GET['id'] : 0;

        if ($taskId <= 0) {
            $_SESSION['task_message'] = 'ID de tarea invalido.';
            $_SESSION['task_message_type'] = 'error';
            $this->redirectTo('game.php?page=tasks');
            return;
        }

        $result = TaskHelper::doTaskAndReward($userId, $taskId);

        if ($result['success']) {
            $_SESSION['task_message'] = $result['message'];
            $_SESSION['task_message_type'] = 'success';
        } else {
            $_SESSION['task_message'] = $result['message'];
            $_SESSION['task_message_type'] = 'error';
        }

        if (!empty($result['url'])) {
            header('Location: ' . $result['url']);
            exit;
        }

        $this->redirectTo('game.php?page=tasks');
    }
}
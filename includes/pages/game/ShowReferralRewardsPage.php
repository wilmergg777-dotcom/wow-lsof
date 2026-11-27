<?php
/**
 * AstroIO - Admin Panel: Recompensas por Referidos
 * Ruta: includes/pages/adm/ShowReferralRewardsPage.php
 */

function ShowReferralRewardsPage()
{
    global $LNG;
    $db = $GLOBALS['DATABASE'];

    // Obtener todas las recompensas
    $rewards = $db->query("SELECT * FROM `uni1_referral_rewards` ORDER BY `id` DESC");
    
    $rewardList = [];
    while ($row = $db->fetch_array($rewards)) {
        if ($row['is_permanent'] == 0) {
            $row['start_date_str'] = $row['start_time'] > 0 ? date('Y-m-d\TH:i', $row['start_time']) : '';
            $row['end_date_str']   = $row['end_time'] > 0 ? date('Y-m-d\TH:i', $row['end_time']) : '';
        }
        $rewardList[] = $row;
    }

    // Asignar variables al template
    $template = new template();
    $template->assign_vars([
        'rewards' => $rewardList,
        'msg'     => HTTP::_GP('msg', '')
    ]);
    
    // Mostrar el template del admin
    $template->show('ShowReferralRewardsPage.tpl');
}

function SaveReferralReward()
{
    $db = $GLOBALS['DATABASE'];

    $points   = (int)$_POST['points_required'];
    
    // Recursos
    $metal    = (float)$_POST['reward_metal'];
    $crystal  = (float)$_POST['reward_crystal'];
    $deut     = (float)$_POST['reward_deuterium'];
    $ntx20    = (int)$_POST['reward_ntx20'];
    $dm       = (float)$_POST['reward_darkmatter'];
    
    // Contenedores
    $cont_gen = (int)$_POST['reward_cont_generic'];
    $box_com  = (int)$_POST['reward_box_common'];
    $box_rar  = (int)$_POST['reward_box_rare'];
    $box_leg  = (int)$_POST['reward_box_legendary'];

    // Temporalidad
    $is_perm  = isset($_POST['is_permanent']) && $_POST['is_permanent'] == 1 ? 1 : 0;
    $start    = 0;
    $end      = 0;

    if ($is_perm == 0) {
        if (!empty($_POST['start_time'])) $start = strtotime($_POST['start_time']);
        if (!empty($_POST['end_time']))   $end   = strtotime($_POST['end_time']);
    }

    // Insertar en la base de datos
    $sql = "INSERT INTO `uni1_referral_rewards` 
            (`points_required`, `reward_metal`, `reward_crystal`, `reward_deuterium`, `reward_ntx20`, `reward_darkmatter`, 
             `reward_cont_generic`, `reward_box_common`, `reward_box_rare`, `reward_box_legendary`, 
             `is_permanent`, `start_time`, `end_time`, `is_active`) 
            VALUES 
            ($points, $metal, $crystal, $deut, $ntx20, $dm, 
             $cont_gen, $box_com, $box_rar, $box_leg, 
             $is_perm, $start, $end, 1)";
    
    $db->query($sql);

    // Redirigir de vuelta al panel con mensaje de éxito
    HTTP::redirectTo('admin.php?page=referral_rewards&msg=created');
}

function ToggleReferralReward()
{
    $db = $GLOBALS['DATABASE'];
    $id = HTTP::_GP('id', 0);

    if ($id > 0) {
        $db->query("UPDATE `uni1_referral_rewards` SET `is_active` = 1 - `is_active` WHERE `id` = " . (int)$id);
    }
    
    HTTP::redirectTo('admin.php?page=referral_rewards&msg=toggled');
}

function DeleteReferralReward()
{
    $db = $GLOBALS['DATABASE'];
    $id = HTTP::_GP('id', 0);

    if ($id > 0) {
        $db->query("DELETE FROM `uni1_referral_rewards` WHERE `id` = " . (int)$id);
        $db->query("DELETE FROM `uni1_referral_rewards_history` WHERE `reward_id` = " . (int)$id);
    }
    
    HTTP::redirectTo('admin.php?page=referral_rewards&msg=deleted');
}
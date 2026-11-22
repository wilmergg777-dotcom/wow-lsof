<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */

class ShowMessagesPage extends AbstractGamePage
{
    public static $requireModule = MODULE_MESSAGES;

    function __construct()
    {
        parent::__construct();
    }

    function view()
    {
        global $LNG, $USER;
        $MessCategory   = HTTP::_GP('messcat', 100);
        $page           = HTTP::_GP('site', 1);

        $db = Database::get();

        $this->initTemplate();
        $this->setWindow('ajax');

        $MessageList    = array();
        $MessagesID     = array();

        if($MessCategory == 999)  {
            $sql = "SELECT COUNT(*) as state FROM %%MESSAGES%% WHERE message_sender = :userId AND message_type != 50 AND message_deleted IS NULL;";
            $MessageCount = $db->selectSingle($sql, array(':userId' => $USER['id']), 'state');
            $maxPage    = max(1, ceil($MessageCount / MESSAGES_PER_PAGE));
            $page       = max(1, min($page, $maxPage));

            $sql = "SELECT message_id, message_time, CONCAT(username, ' [',galaxy, ':', system, ':', planet,']') as message_from, message_subject, message_sender, message_type, message_unread, message_text
            FROM %%MESSAGES%% INNER JOIN %%USERS%% ON id = message_owner
            WHERE message_sender = :userId AND message_type != 50 AND message_deleted IS NULL
            ORDER BY message_time DESC LIMIT :offset, :limit;";

            $MessageResult = $db->select($sql, array(':userId' => $USER['id'], ':offset' => (($page - 1) * MESSAGES_PER_PAGE), ':limit' => MESSAGES_PER_PAGE));
        }
        else
        {
            if ($MessCategory == 100)
            {
                $sql = "SELECT COUNT(*) as state FROM %%MESSAGES%% WHERE message_owner = :userId AND message_deleted IS NULL;";
                $MessageCount = $db->selectSingle($sql, array(':userId' => $USER['id']), 'state');
                $maxPage    = max(1, ceil($MessageCount / MESSAGES_PER_PAGE));
                $page       = max(1, min($page, $maxPage));

                $sql = "SELECT message_id, message_time, message_from, message_subject, message_sender, message_type, message_unread, message_text
                           FROM %%MESSAGES%% WHERE message_owner = :userId AND message_deleted IS NULL
                           ORDER BY message_time DESC LIMIT :offset, :limit";

                $MessageResult = $db->select($sql, array(':userId' => $USER['id'], ':offset' => (($page - 1) * MESSAGES_PER_PAGE), ':limit' => MESSAGES_PER_PAGE));
            }
            elseif ($MessCategory == 101)
            {
                $sql = "SELECT COUNT(*) as state FROM %%MESSAGES%% WHERE message_owner = :userId AND message_unread = 1 AND message_deleted IS NULL;";
                $MessageCount = $db->selectSingle($sql, array(':userId' => $USER['id']), 'state');
                $maxPage    = max(1, ceil($MessageCount / MESSAGES_PER_PAGE));
                $page       = max(1, min($page, $maxPage));

                $sql = "SELECT message_id, message_time, message_from, message_subject, message_sender, message_type, message_unread, message_text
                           FROM %%MESSAGES%% WHERE message_owner = :userId AND message_unread = 1 AND message_deleted IS NULL
                           ORDER BY message_time DESC LIMIT :offset, :limit";

                $MessageResult = $db->select($sql, array(':userId' => $USER['id'], ':offset' => (($page - 1) * MESSAGES_PER_PAGE), ':limit' => MESSAGES_PER_PAGE));
            }
            else
            {
                $sql = "SELECT COUNT(*) as state FROM %%MESSAGES%% WHERE message_owner = :userId AND message_type = :messCategory AND message_deleted IS NULL;";
                $MessageCount = $db->selectSingle($sql, array(':userId' => $USER['id'], ':messCategory' => $MessCategory), 'state');

                $sql = "SELECT message_id, message_time, message_from, message_subject, message_sender, message_type, message_unread, message_text
                           FROM %%MESSAGES%% WHERE message_owner = :userId AND message_type = :messCategory AND message_deleted IS NULL
                           ORDER BY message_time DESC LIMIT :offset, :limit";

                $maxPage    = max(1, ceil($MessageCount / MESSAGES_PER_PAGE));
                $page       = max(1, min($page, $maxPage));

                $MessageResult = $db->select($sql, array(':userId' => $USER['id'], ':messCategory' => $MessCategory, ':offset' => (($page - 1) * MESSAGES_PER_PAGE), ':limit' => MESSAGES_PER_PAGE));
            }
        }

        foreach ($MessageResult as $MessageRow)
        {
            $MessagesID[]   = $MessageRow['message_id'];
            $MessageList[]  = array(
                'id'        => $MessageRow['message_id'],
                'time'      => _date($LNG['php_tdformat'], $MessageRow['message_time'], $USER['timezone']),
                'from'      => $MessageRow['message_from'],
                'subject'   => $MessageRow['message_subject'],
                'sender'    => $MessageRow['message_sender'],
                'type'      => $MessageRow['message_type'],
                'unread'    => $MessageRow['message_unread'],
                'text'      => $MessageRow['message_text'], 
            );
        }

        $this->assign(array(
            'MessID'        => $MessCategory,
            'MessageCount'  => $MessageCount,
            'MessageList'   => $MessageList,
            'page'          => $page,
            'maxPage'       => $maxPage,
        ));

        $this->display('page.messages.view.tpl');
    }

    function markread()
    {
        global $USER;
        $id = HTTP::_GP('id', 0);
        if ($id > 0) {
            $db = Database::get();
            $db->update("UPDATE %%MESSAGES%% SET message_unread = 0 WHERE message_id = :id AND message_owner = :userId;", array(':id' => $id, ':userId' => $USER['id']));
        }
        $this->sendJSON('ok');
    }

    function markallread()
    {
        global $USER;
        $db = Database::get();
        $db->update("UPDATE %%MESSAGES%% SET message_unread = 0 WHERE message_owner = :userId AND message_unread = 1;", array(':userId' => $USER['id']));
        $this->sendJSON('ok');
    }

    function getUnreadCounts()
    {
        global $USER;
        $db = Database::get();

        $unread = array(100 => 0, 101 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 0 => 0, 15 => 0);

        $row = $db->selectSingle("SELECT COUNT(*) AS total FROM %%MESSAGES%% WHERE message_owner = :uid AND message_unread = 1 AND message_deleted IS NULL", array(':uid' => $USER['id']));
        $total = (int)($row['total'] ?? 0);
        $unread[100] = $total;
        $unread[101] = $total;

        $rows = $db->select("SELECT message_type, SUM(message_unread) AS unread FROM %%MESSAGES%% WHERE message_owner = :uid AND message_deleted IS NULL GROUP BY message_type", array(':uid' => $USER['id']));
        if ($rows) {
            foreach ($rows as $r) {
                $t = (int)$r['message_type'];
                if (array_key_exists($t, $unread)) $unread[$t] = (int)$r['unread'];
            }
        }
        $this->sendJSON($unread);
    }

    function action()
    {
        global $USER;
        $db = Database::get();
        $MessCategory   = HTTP::_GP('messcat', 100);
        $page           = HTTP::_GP('page', 1);
        $messageIDs     = HTTP::_GP('messageID', array());
        $redirectUrl    = 'game.php?page=messages&category='.$MessCategory.'&side='.$page;

        $action = false;
        if(isset($_POST['submitTop'])) $action = HTTP::_GP('actionTop', '');
        elseif(isset($_POST['submitBottom'])) $action = HTTP::_GP('actionBottom', '');
        else $this->redirectTo($redirectUrl);

        if($action == 'deleteunmarked' && empty($messageIDs)) $action = 'deletetypeall';
        if($action == 'deletetypeall' && $MessCategory == 100) $action = 'deleteall';
        if($action == 'readtypeall' && $MessCategory == 100) $action = 'readall';

        switch($action)
        {
            case 'readall':
                $db->update("UPDATE %%MESSAGES%% SET message_unread = 0 WHERE message_owner = :userID;", array(':userID' => $USER['id']));
            break;
            case 'readtypeall':
                $db->update("UPDATE %%MESSAGES%% SET message_unread = 0 WHERE message_owner = :userID AND message_type = :messCategory;", array(':userID' => $USER['id'], ':messCategory' => $MessCategory));
            break;
            case 'readmarked':
                if(empty($messageIDs)) $this->redirectTo($redirectUrl);
                $messageIDs = array_filter($messageIDs, 'is_numeric');
                if(empty($messageIDs)) $this->redirectTo($redirectUrl);
                $db->update('UPDATE %%MESSAGES%% SET message_unread = 0 WHERE message_id IN ('.implode(',', array_keys($messageIDs)).') AND message_owner = :userID;', array(':userID' => $USER['id']));
            break;
            case 'deleteall':
                if(Config::get()->message_delete_behavior == 1) {
                    $db->update("UPDATE %%MESSAGES%% SET message_deleted = :timestamp WHERE message_owner = :userID;", array(':timestamp' => TIMESTAMP, ':userID' => $USER['id']));
                } else {
                    $db->delete("DELETE FROM %%MESSAGES%% WHERE message_owner = :userID;", array(':userID' => $USER['id']));
                }
            break;
            case 'deletetypeall':
                if(Config::get()->message_delete_behavior == 1) {
                    $db->update("UPDATE %%MESSAGES%% SET message_deleted = :timestamp WHERE message_owner = :userID AND message_type = :messCategory;", array(':timestamp' => TIMESTAMP, ':userID' => $USER['id'], ':messCategory' => $MessCategory));
                } else {
                    $db->delete("DELETE FROM %%MESSAGES%% WHERE message_owner = :userID AND message_type = :messCategory;", array(':userID' => $USER['id'], ':messCategory' => $MessCategory));
                }
            break;
            case 'deletemarked':
                if(empty($messageIDs)) $this->redirectTo($redirectUrl);
                $messageIDs = array_filter($messageIDs, 'is_numeric');
                if(empty($messageIDs)) $this->redirectTo($redirectUrl);
                if(Config::get()->message_delete_behavior == 1) {
                    $db->update('UPDATE %%MESSAGES%% SET message_deleted = :timestamp WHERE message_id IN (' . implode(',', array_keys($messageIDs)) . ') AND message_owner = :userId;', array(':timestamp' => TIMESTAMP, ':userId' => $USER['id']));
                } else {
                    $db->delete('DELETE FROM %%MESSAGES%% WHERE message_id IN (' . implode(',', array_keys($messageIDs)) . ') AND message_owner = :userId;', array(':userId' => $USER['id']));
                }
            break;
            case 'deleteunmarked':
                if(empty($messageIDs) || !is_array($messageIDs)) $this->redirectTo($redirectUrl);
                $messageIDs = array_filter($messageIDs, 'is_numeric');
                if(empty($messageIDs)) $this->redirectTo($redirectUrl);
                if(Config::get()->message_delete_behavior == 1) {
                    $db->update('UPDATE %%MESSAGES%% SET message_deleted = :timestamp WHERE message_id NOT IN (' . implode(',', array_keys($messageIDs)) . ') AND message_owner = :userId;', array(':timestamp' => TIMESTAMP, ':userId' => $USER['id']));
                } else {
                    $db->delete('DELETE FROM %%MESSAGES%% WHERE message_id NOT IN ('.implode(',', array_keys($messageIDs)).') AND message_owner = :userId;', array(':userId' => $USER['id']));
                }
            break;
        }
        $this->redirectTo($redirectUrl);
    }

    function send()
    {
        global $USER, $LNG;
        
        // Recibimos el nombre desde el modal y lo buscamos en la BD
        $receiverName = HTTP::_GP('to', '');
        $db = Database::get();
        
        $receiverID = 0;
        if (!empty($receiverName)) {
            $row = $db->selectSingle("SELECT id FROM %%USERS%% WHERE username = :name", array(':name' => $receiverName));
            if ($row) {
                $receiverID = $row['id'];
            }
        } else {
            $receiverID = HTTP::_GP('id', 0);
        }

        $subject    = HTTP::_GP('subject', $LNG['mg_no_subject'], true);
        $text       = HTTP::_GP('text', '', true);
        $senderName = $USER['username'].' ['.$USER['galaxy'].':'.$USER['system'].':'.$USER['planet'].']';

        // 🛡️ EL BLINDAJE: Limpiamos etiquetas HTML invisibles, pero permitimos <br> para saltos de línea
        $subject = strip_tags($subject);
        $text    = strip_tags($text, '<br>');

        $text = makebr($text);

        if (empty($receiverID) || empty($text)) {
            $this->sendJSON('Error: El jugador no existe o el mensaje está vacío.');
        }

        PlayerUtil::sendMessage($receiverID, $USER['id'], $senderName, 1, $subject, $text, TIMESTAMP);
        $this->sendJSON('Mensaje enviado correctamente.');
    }

    function write()
    {
        global $LNG, $USER;
        $this->setWindow('popup');
        $this->initTemplate();
        $db = Database::get();
        $receiverID = HTTP::_GP('id', 0);
        $Subject    = HTTP::_GP('subject', $LNG['mg_no_subject'], true);

        $receiverRecord = $db->selectSingle("SELECT a.galaxy, a.system, a.planet, b.username, b.id_planet, b.settings_blockPM FROM %%PLANETS%% as a, %%USERS%% as b WHERE b.id = :receiverId AND a.id = b.id_planet;", array(':receiverId' => $receiverID));

        if (!$receiverRecord) $this->printMessage($LNG['mg_error']);
        if ($receiverRecord['settings_blockPM'] == 1) $this->printMessage($LNG['mg_receiver_block_pm']);

        Session::load()->messageToken = md5($USER['id'].'|'.$receiverID);

        $this->assign(array('subject' => $Subject, 'id' => $receiverID, 'OwnerRecord' => $receiverRecord));
        $this->display('page.messages.write.tpl');
    }

    function show()
    {
        global $USER;
        $category = HTTP::_GP('category', 0);
        $side     = HTTP::_GP('side', 1);
        $db       = Database::get();

        $TitleColor = array(0 => '#FFFF00', 1 => '#FF6699', 2 => '#FF3300', 3 => '#FF9900', 4 => '#773399', 5 => '#009933', 15 => '#6495ed', 50 => '#666600', 99 => '#007070', 100 => '#ABABAB', 999 => '#CCCCCC');

        $MessOut = $db->selectSingle("SELECT COUNT(*) as state FROM %%MESSAGES%% WHERE message_sender = :userID AND message_type != 50;", array(':userID' => $USER['id']), 'state');

        $OperatorList = array();
        $Total  = array(0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 15 => 0, 50 => 0, 99 => 0, 100 => 0, 101 => 0, 999 => 0);
        $UnRead = array(0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 15 => 0, 50 => 0, 99 => 0, 100 => 0, 101 => 0, 999 => 0);

        $OperatorResult = $db->select("SELECT username, email FROM %%USERS%% WHERE universe = :universe AND authlevel != :authlevel ORDER BY username ASC;", array(':universe' => Universe::current(), ':authlevel' => AUTH_USR));

        foreach($OperatorResult as $OperatorRow) {
            $OperatorList[$OperatorRow['username']] = $OperatorRow['email'];
        }

        $CategoryResult = $db->select("SELECT message_type, SUM(message_unread) as message_unread, COUNT(*) as count FROM %%MESSAGES%% WHERE message_owner = :userID AND message_deleted IS NULL GROUP BY message_type;", array(':userID' => $USER['id']));

        foreach ($CategoryResult as $CategoryRow) {
            $UnRead[$CategoryRow['message_type']] = $CategoryRow['message_unread'];
            $Total[$CategoryRow['message_type']]  = $CategoryRow['count'];
        }

        $UnRead[100] = array_sum($UnRead);
        $Total[100]  = array_sum($Total);
        $Total[999]  = $MessOut;
        $UnRead[101] = $UnRead[100];
        $Total[101]  = $UnRead[100];

        $CategoryList = array();
        foreach($TitleColor as $CategoryID => $CategoryColor) {
            $CategoryList[$CategoryID] = array('color' => $CategoryColor, 'unread' => $UnRead[$CategoryID], 'total' => $Total[$CategoryID]);
        }

        $this->tplObj->loadscript('message.js');
        $this->assign(array('CategoryList' => $CategoryList, 'OperatorList' => $OperatorList, 'category' => $category, 'side' => $side));

        $this->display('page.messages.default.tpl');
    }
}
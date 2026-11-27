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

define('MODE', 'ADMIN');
define('DATABASE_VERSION', 'OLD');

define('ROOT_PATH', str_replace('\\', '/',dirname(__FILE__)).'/');

require 'includes/common.php';
require 'includes/classes/class.Log.php';

if ($USER['authlevel'] == AUTH_USR)
{
	HTTP::redirectTo('game.php');
}

$session	= Session::create();
if($session->adminAccess != 1)
{
	include_once('includes/pages/adm/ShowLoginPage.php');
	ShowLoginPage();
	exit;
}

$uni	= HTTP::_GP('uni', 0);

if($USER['authlevel'] == AUTH_ADM && !empty($uni))
{
	Universe::setEmulated($uni);
}

$page	= HTTP::_GP('page', '');
switch($page)
{
	case 'logout':
		include_once('includes/pages/adm/ShowLogoutPage.php');
		ShowLogoutPage();
	break;
	case 'infos':
		include_once('includes/pages/adm/ShowInformationPage.php');
		ShowInformationPage();
	break;
	case 'rights':
		include_once('includes/pages/adm/ShowRightsPage.php');
		ShowRightsPage();
	break;
	case 'config':
		include_once('includes/pages/adm/ShowConfigBasicPage.php');
		ShowConfigBasicPage();
	break;
	case 'configuni':
		include_once('includes/pages/adm/ShowConfigUniPage.php');
		ShowConfigUniPage();
	break;
	case 'weekendboost':
		include_once('includes/pages/adm/ShowWeekendBoostAdminPage.php');
		ShowWeekendBoostAdmin();
	break;
    case 'configmods':
        include_once('includes/pages/adm/ShowConfigModsPage.php');
        ShowConfigModsPage();
        break;
	case 'chat':
		include_once('includes/pages/adm/ShowChatConfigPage.php');
		ShowChatConfigPage();
	break;
	case 'teamspeak':
		include_once('includes/pages/adm/ShowTeamspeakPage.php');
		ShowTeamspeakPage();
	break;
	case 'facebook':
		include_once('includes/pages/adm/ShowFacebookPage.php');
		ShowFacebookPage();
	break;
	case 'module':
		include_once('includes/pages/adm/ShowModulePage.php');
		ShowModulePage();
	break;
	case 'statsconf':
		include_once('includes/pages/adm/ShowStatsPage.php');
		ShowStatsPage();
	break;
	case 'disclamer':
		include_once('includes/pages/adm/ShowDisclamerPage.php');
		ShowDisclamerPage();
	break;
	case 'create':
		include_once('includes/pages/adm/ShowCreatorPage.php');
		ShowCreatorPage();
	break;
	case 'accounteditor':
		include_once('includes/pages/adm/ShowAccountEditorPage.php');
		ShowAccountEditorPage();
	break;
	case 'active':
		include_once('includes/pages/adm/ShowActivePage.php');
		ShowActivePage();
	break;
	case 'bans':
		include_once('includes/pages/adm/ShowBanPage.php');
		ShowBanPage();
	break;
	case 'messagelist':
		include_once('includes/pages/adm/ShowMessageListPage.php');
		ShowMessageListPage();
	break;
	case 'globalmessage':
		include_once('includes/pages/adm/ShowSendMessagesPage.php');
		ShowSendMessagesPage();
	break;
	case 'fleets':
		include_once('includes/pages/adm/ShowFlyingFleetPage.php');
		ShowFlyingFleetPage();
	break;
	case 'accountdata':
		include_once('includes/pages/adm/ShowAccountDataPage.php');
		ShowAccountDataPage();
	break;
	case 'support':
		include_once('includes/pages/adm/ShowSupportPage.php');
		new ShowSupportPage();
	break;
	case 'password':
		include_once('includes/pages/adm/ShowPassEncripterPage.php');
		ShowPassEncripterPage();
	break;
	case 'search':
		include_once('includes/pages/adm/ShowSearchPage.php');
		ShowSearchPage();
	break;
	case 'qeditor':
		include_once('includes/pages/adm/ShowQuickEditorPage.php');
		ShowQuickEditorPage();
	break;
	case 'statsupdate':
		include_once('includes/pages/adm/ShowStatUpdatePage.php');
		ShowStatUpdatePage();
	break;
	case 'reset':
		include_once('includes/pages/adm/ShowResetPage.php');
		ShowResetPage();
	break;
	case 'news':
		include_once('includes/pages/adm/ShowNewsPage.php');
		ShowNewsPage();
	break;
	case 'topnav':
		include_once('includes/pages/adm/ShowTopnavPage.php');
		ShowTopnavPage();
	break;
	case 'overview':
		include_once('includes/pages/adm/ShowOverviewPage.php');
		ShowOverviewPage();
	break;
	case 'menu':
		include_once('includes/pages/adm/ShowMenuPage.php');
		ShowMenuPage();
	break;
	case 'clearcache':
		include_once('includes/pages/adm/ShowClearCachePage.php');
		ShowClearCachePage();
	break;
	case 'universe':
		include_once('includes/pages/adm/ShowUniversePage.php');
		ShowUniversePage();
	break;
	case 'multiips':
		include_once('includes/pages/adm/ShowMultiIPPage.php');
		ShowMultiIPPage();
	break;
	case 'log':
		include_once('includes/pages/adm/ShowLogPage.php');
		ShowLog();
	break;
	case 'vertify':
		include_once('includes/pages/adm/ShowVertify.php');
		ShowVertify();
	break;
	case 'cronjob':
		include_once('includes/pages/adm/ShowCronjobPage.php');
		ShowCronjob();
	break;
	case 'giveaway':
		include_once('includes/pages/adm/ShowGiveawayPage.php');
		ShowGiveaway();
	break;
	case 'boosters':
		include_once('includes/pages/adm/ShowBoostersAdminPage.php');
		ShowBoostersAdmin();
	break;
	case 'events':
		include_once('includes/pages/adm/ShowEventsAdminPage.php');
		ShowEventsAdmin();
	break;
	case 'market':
		include_once('includes/pages/adm/ShowMarketAdminPage.php');
		ShowMarketAdmin();
	break;
	case 'gamesadmin':
		include_once('includes/pages/adm/ShowGamesAdminPage.php');
		ShowGamesAdmin();
	break;
	case 'bugreportadmin':
		include_once('includes/pages/adm/ShowBugReportAdminPage.php');
		ShowBugReportAdmin();
	break;
	case 'improvementsadmin':
		include_once('includes/pages/adm/ShowImprovementsAdminPage.php');
		ShowImprovementsAdmin();
	break;
	case 'war':
		include_once('includes/pages/adm/ShowWarAdminPage.php');
		ShowWarAdmin();
	break;
	case 'autocomplete':
		include_once('includes/pages/adm/ShowAutoCompletePage.php');
		ShowAutoCompletePage();
	break;
	case 'dump':
		include_once('includes/pages/adm/ShowDumpPage.php');
		ShowDumpPage();
	break;
	case 'pveadmin':
		include_once('includes/pages/adm/ShowPveAdminPage.php');
		ShowPveAdmin();
	break;
	case 'pvpadmin':
		include_once('includes/pages/adm/ShowPvpAdminPage.php');
		ShowPvpAdmin();
	break;
	case 'shopadmin':
		include_once('includes/pages/adm/ShowShopAdminPage.php');
		ShowShopAdmin();
	break;
	case 'ntx20admin':
		include_once('includes/pages/adm/ShowNtx20AdminPage.php');
		ShowNtx20Admin();
	break;
	case 'tourneyadmin':
		include_once('includes/pages/adm/ShowTourneyAdminPage.php');
		ShowTourneyAdmin();
	break;
	
	// ═══════════════════════════════════════════════════════════
	// ASTROIO - RECOMPENSAS POR REFERIDOS
	// ═══════════════════════════════════════════════════════════
	case 'referral_rewards':
		include_once('includes/pages/adm/ShowReferralRewardsPage.php');
		$action = HTTP::_GP('action', '');
		if ($action == 'save') {
			SaveReferralReward();
		} elseif ($action == 'toggle') {
			ToggleReferralReward();
		} elseif ($action == 'delete') {
			DeleteReferralReward();
		} else {
			ShowReferralRewardsPage();
		}
	break;

	// ═══════════════════════════════════════════════════════════
	// ASTROIO - SISTEMA DE CLIMA (v1.0)
	// ═══════════════════════════════════════════════════════════
	case 'climas':
		include_once('includes/pages/adm/ShowClimasAdminPage.php');
		ShowClimasAdmin();
	break;

	// ═══════════════════════════════════════════════════════════
	// ASTROIO - CLONADOR DE UNIVERSOS (NUEVO)
	// ═══════════════════════════════════════════════════════════
	case 'cloneuniverse':
		include_once('includes/pages/adm/ShowCloneUniversePage.php');
		ShowCloneUniversePage();
	break;
	
	default:
		include_once('includes/pages/adm/ShowIndexPage.php');
		ShowIndexPage();
	break;
}
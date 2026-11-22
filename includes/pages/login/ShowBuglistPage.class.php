<?php
/**
 * ShowBuglistPage — Lista pública de bugs reportados
 * AstroIO v1.1
 *
 * URL: index.php?page=buglist
 * Visible para TODOS (sin necesidad de login)
 */

if (!defined('MODE')) die('Hacking attempt');

require_once __DIR__ . '/../../classes/BugReportHelper.class.php';

class ShowBuglistPage extends AbstractLoginPage
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        $reportes = BugReportHelper::getReportesPublicos(100);

        $this->assign([
            'reportes' => $reportes,
        ]);

        $this->display('page.buglist.default.tpl');
    }
}
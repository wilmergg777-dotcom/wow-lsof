<?php
if (!defined('MODE')) {
    die('Hacking attempt');
}

class UnifiedBase extends AbstractGamePage
{
    public static $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $LNG, $USER, $PLANET, $resource;

        $this->tplObj->assign_vars(array(
            'user_id'           => isset($USER['id'])          ? $USER['id']          : 0,
            'user_name'         => isset($USER['username'])    ? $USER['username']    : '',
            'user_rank'         => isset($USER['authlevel'])   ? $USER['authlevel']   : 0,
            'planet_name'       => isset($PLANET['name'])      ? $PLANET['name']      : '',
            'planet_id'         => isset($PLANET['id'])        ? $PLANET['id']        : 0,
            'current_metal'     => isset($resource['metal'])     ? $resource['metal']     : 0,
            'current_crystal'   => isset($resource['crystal'])   ? $resource['crystal']   : 0,
            'current_deuterium' => isset($resource['deuterium']) ? $resource['deuterium'] : 0,
            'current_energy'    => isset($resource['energy'])    ? $resource['energy']    : 0,
        ));

        $this->display('unified_base.tpl');
    }
}
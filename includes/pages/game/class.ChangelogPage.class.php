<?php
/**
 * ══════════════════════════════════════════════════════════════════
 *  ASTROIO — Página de Changelog (CHANGES.md)
 *  URL: game.php?page=changelog
 *  Estilo: AstroIO v3.0 (glassmorphism + cyan)
 * ══════════════════════════════════════════════════════════════════
 */

class ChangelogPage extends Page
{
    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        $path = ROOT_PATH . 'CHANGES.md';
        $html = '';

        if (file_exists($path)) {
            $raw = @file_get_contents($path);
            if ($raw !== false && trim($raw) !== '') {
                $raw  = str_replace(["\r\n", "\r"], "\n", $raw);
                $html = $this->parseMd($raw);
            }
        }

        if ($html === '') {
            $html = '<div class="astrolog_empty">📄 No se encontró <code>CHANGES.md</code> en la raíz del servidor.</div>';
        }

        // Contar versiones
        $count = substr_count($html, 'astrolog_version_block');

        $this->assign([
            'changelog_html'  => $html,
            'changelog_count' => $count,
        ]);

        $this->display('page.changelog.default.tpl');
    }

    /**
     * Parsea el markdown del CHANGES.md a HTML con clases AstroIO
     */
    private function parseMd($md)
    {
        $out = '';
        $lines = explode("\n", $md);
        $state = null;   // null | 'main' | 'sub'
        $inBody = false; // si estamos dentro de un .astrolog_version_body
        $versionNum = 0;

        foreach ($lines as $raw) {
            $line = rtrim($raw);
            $L = ltrim($line);

            // ─── Línea vacía ───
            if ($L === '') {
                if ($state !== null) {
                    $out .= '</ul>';
                    $state = null;
                }
                continue;
            }

            // ─── Separador --- ───
            if (preg_match('/^-{3,}\s*$/', $L)) {
                if ($state !== null) { $out .= '</ul>'; $state = null; }
                if ($inBody) { $out .= '</div>'; $inBody = false; }
                $out .= '<hr class="astrolog_sep">';
                continue;
            }

            // ─── ### Título de versión ───
            if (preg_match('/^###\s+(.+)$/u', $L, $m)) {
                if ($state !== null) { $out .= '</ul>'; $state = null; }
                if ($inBody) { $out .= '</div>'; $inBody = false; }

                $title = preg_replace('/^_(.+)_$/', '$1', trim($m[1]));
                $title = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');

                $isCurrent  = ($versionNum === 0);
                $cls        = $isCurrent ? ' astrolog_version_current' : '';
                $badge      = $isCurrent ? '<span class="astrolog_badge_current">✨ ACTUAL</span>' : '';

                $out .= '<div class="astrolog_version_block">';
                $out .=   '<div class="astrolog_version_header' . $cls . '">';
                $out .=     '<span class="astrolog_version_title">' . $title . '</span>';
                $out .=     $badge;
                $out .=   '</div>';
                $out .=   '<div class="astrolog_version_body">';
                $inBody = true;
                $versionNum++;
                continue;
            }

            // ─── **Badge** (línea de solo negritas) ───
            if (preg_match('/^\*\*(.+?)\*\*\s*$/u', $L, $m)) {
                if ($state !== null) { $out .= '</ul>'; $state = null; }
                $txt = htmlspecialchars(trim($m[1]), ENT_QUOTES, 'UTF-8');
                $out .= '<div class="astrolog_badge">' . $txt . '</div>';
                continue;
            }

            // ─── [Sección] tipo [Nuevo — X] ───
            if (preg_match('/^\[(.+?)\]\s*:?\s*$/u', $L, $m)) {
                if ($state !== null) { $out .= '</ul>'; $state = null; }
                $txt = htmlspecialchars(trim($m[1]), ENT_QUOTES, 'UTF-8');
                $out .= '<div class="astrolog_section">' . $txt . '</div>';
                continue;
            }

            // ─── • Sub-bullet ───
            if (preg_match('/^[•·]\s*(.+)$/u', $L, $m)) {
                if ($state !== 'sub') {
                    if ($state === 'main') {
                        $out .= '<ul class="astrolog_sublist">';
                    } else {
                        $out .= '<ul class="astrolog_sublist astrolog_sublist_root">';
                    }
                    $state = 'sub';
                }
                $out .= '<li>' . $this->inline($m[1]) . '</li>';
                continue;
            }

            // ─── - Bullet principal ───
            if (preg_match('/^-\s+(.+)$/u', $L, $m)) {
                if ($state === 'sub') { $out .= '</ul>'; $state = null; }
                if ($state !== 'main') {
                    $out .= '<ul class="astrolog_list">';
                    $state = 'main';
                }
                $out .= '<li>' . $this->inline($m[1]) . '</li>';
                continue;
            }

            // ─── Párrafo normal ───
            if ($state !== null) { $out .= '</ul>'; $state = null; }
            $out .= '<p class="astrolog_para">' . $this->inline($L) . '</p>';
        }

        if ($state !== null) { $out .= '</ul>'; }
        if ($inBody) { $out .= '</div>'; }
        $out .= '</div>'; // cerramos el último .astrolog_version_block

        return $out;
    }

    /**
     * Formato inline: **bold**, _italic_, `code`, emojis (ya vienen)
     */
    private function inline($t)
    {
        $t = htmlspecialchars($t, ENT_QUOTES, 'UTF-8');
        $t = preg_replace('/\*\*(.+?)\*\*/u', '<strong>$1</strong>', $t);
        $t = preg_replace('/_(.+?)_/u',         '<em>$1</em>', $t);
        $t = preg_replace('/`(.+?)`/u',         '<code>$1</code>', $t);
        return $t;
    }
}
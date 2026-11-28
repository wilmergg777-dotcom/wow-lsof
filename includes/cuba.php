<?php
/**
 * ============================================================
 * DIVISIÓN POLÍTICO-ADMINISTRATIVA DE CUBA
 * ============================================================
 * 15 provincias + 1 municipio especial (Isla de la Juventud).
 * Para cada provincia: slug, nombre, municipios (slug => nombre)
 * y provincias adyacentes (para el fallback "cercana").
 *
 * Usado por:
 *  - mi-tienda.php        (ubicación de la tienda)
 *  - cuenta.php           (ubicación por defecto del comprador)
 *  - productos.php/index.php (filtrado municipio→provincia→cercana→todas)
 *
 * Las coordenadas (lat/lng) son de la capital provincial y sirven
 * para centrar el mapa de entrega en checkout.php.
 * ============================================================
 */

function cuba_provinces(): array {
    return [
        'pinar-del-rio' => [
            'name' => 'Pinar del Río',
            'lat' => 22.4175, 'lng' => -83.6736,
            'adjacent' => ['artemisa'],
            'municipalities' => [
                'pinar-del-rio' => 'Pinar del Río', 'consolacion-del-sur' => 'Consolación del Sur',
                'los-palacios' => 'Los Palacios', 'mantua' => 'Mantua',
                'minas-de-matahambre' => 'Minas de Matahambre', 'sandino' => 'Sandino',
                'san-juan-y-martinez' => 'San Juan y Martínez', 'guane' => 'Guane',
                'la-fe' => 'La Fe', 'vinales' => 'Viñales', 'paso-real-de-guane' => 'Paso Real de Guane',
            ],
        ],
        'artemisa' => [
            'name' => 'Artemisa',
            'lat' => 22.8111, 'lng' => -82.7589,
            'adjacent' => ['pinar-del-rio', 'mayabeque', 'la-habana'],
            'municipalities' => [
                'artemisa' => 'Artemisa', 'bauta' => 'Bauta', 'candelaria' => 'Candelaria',
                'guanajay' => 'Guanajay', 'güira-de-melena' => 'Güira de Melena',
                'mariel' => 'Mariel', 'san-antonio-de-los-baños' => 'San Antonio de los Baños',
                'san-cristobal' => 'San Cristóbal', 'caimito' => 'Caimito',
                'almiquizar' => 'Alquízar', 'ariguanabo' => 'Ariguanabo',
            ],
        ],
        'la-habana' => [
            'name' => 'La Habana',
            'lat' => 23.1136, 'lng' => -82.3666,
            'adjacent' => ['artemisa', 'mayabeque'],
            'municipalities' => [
                'plaza-de-la-revolucion' => 'Plaza de la Revolución',
                'centro-habana' => 'Centro Habana', 'habana-vieja' => 'La Habana Vieja',
                'cerro' => 'Cerro', 'diez-de-octubre' => 'Diez de Octubre',
                'playa' => 'Playa', 'miramar' => 'Miramar', 'vedado' => 'Vedado',
                'lisa' => 'La Lisa', 'boyeros' => 'Boyeros', 'arroyo-naranjo' => 'Arroyo Naranjo',
                'san-miguel-del-padron' => 'San Miguel del Padrón',
                'regla' => 'Regla', 'habana-del-este' => 'Habana del Este',
                'guanabacoa' => 'Guanabacoa', 'cotorro' => 'Cotorro',
                'altahabana' => 'Altahabana', 'casablanca' => 'Casablanca',
                'tarara' => 'Tarará', 'bacuranao' => 'Bacuranao',
            ],
        ],
        'mayabeque' => [
            'name' => 'Mayabeque',
            'lat' => 22.9719, 'lng' => -82.1519,
            'adjacent' => ['artemisa', 'la-habana', 'matanzas'],
            'municipalities' => [
                'san-jose-de-las-lajas' => 'San José de las Lajas',
                'bejucal' => 'Bejucal', 'jaruco' => 'Jaruco',
                'santa-cruz-del-norte' => 'Santa Cruz del Norte',
                'madruga' => 'Madruga', 'nueva-paz' => 'Nueva Paz',
                'san-nicolas-de-bari' => 'San Nicolás de Bari',
                'güines' => 'Güines', 'melena-del-sur' => 'Melena del Sur',
                'batabano' => 'Batabanó', 'quivicán' => 'Quivicán',
            ],
        ],
        'matanzas' => [
            'name' => 'Matanzas',
            'lat' => 23.0411, 'lng' => -81.5775,
            'adjacent' => ['mayabeque', 'villa-clara', 'cienfuegos'],
            'municipalities' => [
                'matanzas' => 'Matanzas', 'varadero' => 'Varadero',
                'cardenas' => 'Cárdenas', 'marti' => 'Mártir',
                'colon' => 'Colón', 'jovellanos' => 'Jovellanos',
                'pedro-betancourt' => 'Pedro Betancourt', 'limonar' => 'Limonar',
                'jaguey-grande' => 'Jagüey Grande', 'aguayaro' => 'Aguayo',
                'calimete' => 'Calimete', 'perico' => 'Perico',
                'los-arabos' => 'Los Arabos', 'unión-de-reyes' => 'Unión de Reyes',
                'ciudad-de-matanzas' => 'Ciudad de Matanzas',
            ],
        ],
        'villa-clara' => [
            'name' => 'Villa Clara',
            'lat' => 22.4089, 'lng' => -79.9644,
            'adjacent' => ['matanzas', 'cienfuegos', 'sancti-spiritus'],
            'municipalities' => [
                'santa-clara' => 'Santa Clara', 'sagua-la-grande' => 'Sagua la Grande',
                'caibarien' => 'Caibarién', 'camajuani' => 'Camajuaní',
                'cifuentes' => 'Cifuentes', 'corralillo' => 'Corralillo',
                'encrucijada' => 'Encrucijada', 'manicaragua' => 'Manicaragua',
                'placetas' => 'Placetas', 'quemado-de-güines' => 'Quemado de Güines',
                'remedios' => 'Remedios', 'santo-domingo' => 'Santo Domingo',
                'ranchuelo' => 'Ranchuelo', 'zulueta' => 'Zulueta',
            ],
        ],
        'cienfuegos' => [
            'name' => 'Cienfuegos',
            'lat' => 22.1461, 'lng' => -80.4356,
            'adjacent' => ['matanzas', 'villa-clara', 'sancti-spiritus'],
            'municipalities' => [
                'cienfuegos' => 'Cienfuegos', 'aguada-de-pasajeros' => 'Aguada de Pasajeros',
                'rodas' => 'Rodas', 'palmira' => 'Palmira',
                'cruces' => 'Cruces', 'abreus' => 'Abreus',
                'cumanayagua' => 'Cumanayagua', 'lajas' => 'Lajas',
            ],
        ],
        'sancti-spiritus' => [
            'name' => 'Sancti Spíritus',
            'lat' => 21.9297, 'lng' => -79.4425,
            'adjacent' => ['villa-clara', 'cienfuegos', 'ciego-de-avila'],
            'municipalities' => [
                'sancti-spiritus' => 'Sancti Spíritus', 'trinidad' => 'Trinidad',
                'cabaiguan' => 'Cabaiguán', 'fomento' => 'Fomento',
                'jatibonico' => 'Jatibonico', 'la-sierpe' => 'La Sierpe',
                'yaguajay' => 'Yaguajay', 'taguasco' => 'Taguasco',
            ],
        ],
        'ciego-de-avila' => [
            'name' => 'Ciego de Ávila',
            'lat' => 21.7389, 'lng' => -78.7639,
            'adjacent' => ['sancti-spiritus', 'camaguey'],
            'municipalities' => [
                'ciego-de-avila' => 'Ciego de Ávila', 'moron' => 'Morón',
                'chirivito' => 'Chambas', 'ciro-redondo' => 'Ciro Redondo',
                'baragua' => 'Baraguá', 'primero-de-enero' => 'Primero de Enero',
                'venezuela' => 'Venezuela', 'florencia' => 'Florencia',
                'majagua' => 'Majagua', 'jicotea' => 'Jicotea',
            ],
        ],
        'camaguey' => [
            'name' => 'Camagüey',
            'lat' => 21.3809, 'lng' => -77.9169,
            'adjacent' => ['ciego-de-avila', 'las-tunas'],
            'municipalities' => [
                'camaguey' => 'Camagüey', 'florida' => 'Florida',
                'nuevitas' => 'Nuevitas', 'vertientes' => 'Vertientes',
                'jimaguayu' => 'Jimaguayú', 'sierra-de-cubitas' => 'Sierra de Cubitas',
                'minas' => 'Minas', 'sibanicu' => 'Sibanicú',
                'guaimaro' => 'Guáimaro', 'esmeralda' => 'Esmeralda',
                'najarasa' => 'Najasa', 'santa-cruz-del-sur' => 'Santa Cruz del Sur',
            ],
        ],
        'las-tunas' => [
            'name' => 'Las Tunas',
            'lat' => 20.9617, 'lng' => -76.9508,
            'adjacent' => ['camaguey', 'holguin', 'granma'],
            'municipalities' => [
                'las-tunas' => 'Las Tunas', 'puerto-padre' => 'Puerto Padre',
                'amancio' => 'Amancio', 'colombia' => 'Colombia',
                'jobabo' => 'Jobabo', 'majibacoa' => 'Majibacoa',
                'manuel-tames' => 'Manuel Tames', 'jesus-menzie' => 'Jesús Menéndez',
            ],
        ],
        'holguin' => [
            'name' => 'Holguín',
            'lat' => 20.8872, 'lng' => -76.2631,
            'adjacent' => ['las-tunas', 'granma', 'santiago-de-cuba', 'guantanamo'],
            'municipalities' => [
                'holguin' => 'Holguín', 'banes' => 'Banes', 'antilla' => 'Antilla',
                'baisre' => 'Báguanos', 'cacocum' => 'Cacocum', 'calixto-garcia' => 'Calixto García',
                'cueto' => 'Cueto', 'frank-pais' => 'Frank País', 'gibara' => 'Gibara',
                'mayari' => 'Mayarí', 'moa' => 'Moa', 'rafael-freire' => 'Rafael Freire',
                'sagua-de-tanamo' => 'Sagua de Tánamo', 'urbano-norris' => 'Urbano Noris',
            ],
        ],
        'granma' => [
            'name' => 'Granma',
            'lat' => 20.3789, 'lng' => -76.6411,
            'adjacent' => ['las-tunas', 'holguin', 'santiago-de-cuba'],
            'municipalities' => [
                'bayamo' => 'Bayamo', 'manzanillo' => 'Manzanillo',
                'jiguani' => 'Jiguaní', 'cauto-cristo' => 'Cauto Cristo',
                'rio-cauto' => 'Río Cauto', 'yara' => 'Yara',
                'campechuela' => 'Campechuela', 'media-luna' => 'Media Luna',
                'niquero' => 'Niquero', 'pilon' => 'Pilón',
                'bartolome-maso' => 'Bartolomé Masó', 'buey-arriba' => 'Buey Arriba',
                'guisa' => 'Guisa', 'maceo' => 'Maceo',
            ],
        ],
        'santiago-de-cuba' => [
            'name' => 'Santiago de Cuba',
            'lat' => 20.0247, 'lng' => -75.8219,
            'adjacent' => ['granma', 'holguin', 'guantanamo'],
            'municipalities' => [
                'santiago-de-cuba' => 'Santiago de Cuba', 'palma-soriano' => 'Palma Soriano',
                'san-luis' => 'San Luis', 'contramaestre' => 'Contramaestre',
                'mella' => 'Mella', 'segundo-frente' => 'Segundo Frente',
                'songo-la-maya' => 'Songo - La Maya', 'el-cobre' => 'El Cobre',
                'guama' => 'Guamá', 'third-frente' => 'Tercer Frente',
            ],
        ],
        'guantanamo' => [
            'name' => 'Guantánamo',
            'lat' => 20.1434, 'lng' => -75.2094,
            'adjacent' => ['holguin', 'santiago-de-cuba'],
            'municipalities' => [
                'guantanamo' => 'Guantánamo', 'baracoa' => 'Baracoa',
                'caimanera' => 'Caimanera', 'el-salvador' => 'El Salvador',
                'yateras' => 'Yateras', 'maisi' => 'Maisí',
                'manuel-tames' => 'Manuel Tames', 'niceto-perez' => 'Niceto Pérez',
                'san-antonio-del-sur' => 'San Antonio del Sur', 'imias' => 'Imías',
            ],
        ],
        'isla-de-la-juventud' => [
            'name' => 'Isla de la Juventud',
            'lat' => 21.8833, 'lng' => -82.8333,
            'adjacent' => ['mayabeque', 'matanzas'], // por ferry, no frontera terrestre
            'municipalities' => [
                'nueva-gerona' => 'Nueva Gerona', 'santa-rosa' => 'Santa Rosa',
                'columbia' => 'Columbia', 'santa-fe' => 'Santa Fe',
                'del-io' => 'Delio Portilla', 'joven-club' => 'Joven Club',
            ],
        ],
    ];
}

/* Devuelve el nombre legible de una provincia por su slug. */
function province_name(?string $slug): string {
    if (!$slug) return '—';
    $p = cuba_provinces()[$slug] ?? null;
    return $p['name'] ?? ucfirst(str_replace('-', ' ', $slug));
}

/* Devuelve el nombre legible de un municipio por su slug y provincia. */
function municipality_name(?string $provinceSlug, ?string $muniSlug): string {
    if (!$muniSlug) return '—';
    $p = $provinceSlug ? (cuba_provinces()[$provinceSlug] ?? null) : null;
    if ($p && isset($p['municipalities'][$muniSlug])) return $p['municipalities'][$muniSlug];
    return ucfirst(str_replace('-', ' ', $muniSlug));
}

/* Devuelve las provincias cercanas (incluida la propia) para un fallback. */
function nearby_provinces(string $provinceSlug, int $maxLevels = 1): array {
    $provs = cuba_provinces();
    $result = [$provinceSlug];
    $frontier = [$provinceSlug];
    for ($level = 0; $level < $maxLevels; $level++) {
        $next = [];
        foreach ($frontier as $p) {
            foreach (($provs[$p]['adjacent'] ?? []) as $adj) {
                if (!in_array($adj, $result, true)) {
                    $result[] = $adj;
                    $next[] = $adj;
                }
            }
        }
        $frontier = $next;
        if (!$frontier) break;
    }
    return $result;
}

/* Lista ordenada de provincias para <select>: [slug => nombre]. */
function province_options(): array {
    $out = [];
    foreach (cuba_provinces() as $slug => $p) $out[$slug] = $p['name'];
    return $out;
}

/* Lista de municipios para <select> de una provincia: [slug => nombre]. */
function municipality_options(string $provinceSlug): array {
    return cuba_provinces()[$provinceSlug]['municipalities'] ?? [];
}

/* Coordenadas de la capital provincial (para centrar el mapa). */
function province_center(string $provinceSlug): array {
    $p = cuba_provinces()[$provinceSlug] ?? null;
    return $p ? ['lat' => $p['lat'], 'lng' => $p['lng']] : ['lat' => 21.5, 'lng' => -77.7];
}

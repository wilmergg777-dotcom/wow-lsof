# AstroIO v2.4.0 — Mapa de imágenes nuevas (ID → ubicación)

Este documento lista TODAS las imágenes añadidas en la versión 2.4.0 con su
**ID de elemento del juego**, su **ubicación exacta** dentro del repo y su
**nombre mostrado**. Para cambiar cualquier imagen en el futuro: reemplaza el
archivo en esa ruta manteniendo el nombre (los GIF para elementos del juego,
JPG para razas/facciones).

> Convención del tema: los elementos (edificios, técnicas, naves, defensas)
> usan `styles/theme/gow/gebaeude/<ID>.gif` y las plantillas los referencian
> automáticamente por `{$dpath}gebaeude/{$ID}.gif`. No hay que tocar código
> para actualizar una imagen: basta sustituir el archivo.

## 1. Edificios y técnicas (recursos nuevos)

| ID | Elemento | Ubicación |
|----|----------|-----------|
| 7 | Mina de Norio | `styles/theme/gow/gebaeude/7.gif` |
| 17 | Mina de Germanio | `styles/theme/gow/gebaeude/17.gif` |
| 25 | Almacén de Norio | `styles/theme/gow/gebaeude/25.gif` |
| 26 | Almacén de Germanio | `styles/theme/gow/gebaeude/26.gif` |
| 134 | Tecnología de Procesado de Norium | `styles/theme/gow/gebaeude/134.gif` |
| 135 | Tecnología de Procesado de Germanium | `styles/theme/gow/gebaeude/135.gif` |

## 2. Naves nuevas (228-237)

| ID | Nave | Ubicación |
|----|------|-----------|
| 228 | Cazador Furtivo | `styles/theme/gow/gebaeude/228.gif` |
| 229 | Fragata de Plasma | `styles/theme/gow/gebaeude/229.gif` |
| 230 | Crucero Blindado | `styles/theme/gow/gebaeude/230.gif` |
| 231 | Nodriza Ligera | `styles/theme/gow/gebaeude/231.gif` |
| 232 | Acorazado de Norio | `styles/theme/gow/gebaeude/232.gif` |
| 233 | Portaestaciones | `styles/theme/gow/gebaeude/233.gif` |
| 234 | Taladrador de Norio | `styles/theme/gow/gebaeude/234.gif` |
| 235 | Corbeta del Destructor | `styles/theme/gow/gebaeude/235.gif` |
| 236 | Fragata del General | `styles/theme/gow/gebaeude/236.gif` |
| 237 | Dreadnought del Emperador | `styles/theme/gow/gebaeude/237.gif` |

## 3. Defensas nuevas (416-422)

| ID | Defensa | Ubicación |
|----|---------|-----------|
| 416 | Cañón de Plasma Pesado | `styles/theme/gow/gebaeude/416.gif` |
| 417 | Torre de Iones Avanzada | `styles/theme/gow/gebaeude/417.gif` |
| 418 | Red Antimisiles Orbital | `styles/theme/gow/gebaeude/418.gif` |
| 419 | Escudo Planetario | `styles/theme/gow/gebaeude/419.gif` |
| 420 | Cañón Gravitónico Mejorado | `styles/theme/gow/gebaeude/420.gif` |
| 421 | Torre del Defensor | `styles/theme/gow/gebaeude/421.gif` |
| 422 | Bastión del Búnker | `styles/theme/gow/gebaeude/422.gif` |

## 4. Iconos del mercado (módulo 45)

| Recurso | Ubicación |
|---------|-----------|
| Norium | `styles/theme/gow/mercado/norium.gif` |
| Germanio | `styles/theme/gow/mercado/germanio.gif` |

## 5. Razas (tabla `uni1_races`, columna `race_img`)

| race_id | Raza | Ubicación |
|---------|------|-----------|
| 1 | PREDATORS | `styles/theme/gow/razas/raza_predators.jpg` |
| 2 | ALIENS | `styles/theme/gow/razas/raza_aliens.jpg` |
| 3 | CHARTER | `styles/theme/gow/razas/raza_charter.jpg` |
| 4 | SARCKS | `styles/theme/gow/razas/raza_sarcks.jpg` |
| 5 | ESPECTROS | `styles/theme/gow/razas/raza_espectros.jpg` |
| 6 | MERCADERES | `styles/theme/gow/razas/raza_mercaderes.jpg` |

## 6. Facciones (tabla `uni1_factions`, columna `faction_img`)

| faction_id | Facción | Ubicación |
|------------|---------|-----------|
| 1 | Pirata | `styles/theme/gow/facciones/fac_pirata.jpg` |
| 2 | Mineros | `styles/theme/gow/facciones/fac_mineros.jpg` |
| 3 | Defensores | `styles/theme/gow/facciones/fac_defensores.jpg` |
| 4 | Tecnócratas | `styles/theme/gow/facciones/fac_tecnocratas.jpg` |
| 5 | Exploradores | `styles/theme/gow/facciones/fac_exploradores.jpg` |
| 6 | Comerciantes | `styles/theme/gow/facciones/fac_comerciantes.jpg` |

## 7. Cómo actualizar una imagen en el futuro

1. Prepara la imagen nueva (GIF 512×512 o más para elementos; JPG para razas/facciones).
2. Sustituye el archivo en la ruta de la tabla correspondiente, con el MISMO nombre.
3. Si es una raza/facción, no hace falta nada más (la ruta ya está en la BD).
4. Las imágenes de elementos no requieren rebuild de caché: el navegador las
   referencia directamente (`{$dpath}gebaeude/<ID>.gif`). Haz Ctrl+F5 para
   verlas si el navegador las cacheó.

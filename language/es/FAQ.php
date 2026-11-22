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
 *
 * ✅ AstroIO — FAQ.php traducido al español
 *   - Contenido 100% en español (antes estaba en alemán)
 *   - FIX: clave [2][2] duplicada corregida
 *     · [2][2] = Saven
 *     · [2][3] = Allianzkampfsystem (SAC)
 *     · [2][4] = Monde (Lunas)
 *     · [2][5] = Allianzen (Alianzas)
 */


$LNG['faq_overview']	= "Preguntas Frecuentes";
 
$LNG['questions']					= array();
$LNG['questions'][1]['category']	= 'Consejos para principiantes';
$LNG['questions'][1][1]['title']	= 'Paso 1';
$LNG['questions'][1][1]['body']		= <<<BODY
<p>En esta parte del tutorial se describen los edificios principales. Se explica cuáles deberías construir al principio y para qué sirven. Para construir un imperio exitoso es importante construir los edificios en un orden lógico.</p>
<h3>La planta de energía solar:</h3>
<p>Para producir los recursos que necesitás para desarrollar tu imperio, es necesario construir este edificio primero. Provee la energía con la que tus minas producen los recursos metal, cristal y deuterio. Una vez que la construcción haya terminado, podés ver en la barra de recursos y también en el apartado "Producción" cuánta energía tenés disponible.</p>
<h3>La mina de metal:</h3>
<p>El metal es uno de los tres recursos que tenés disponibles en el juego. El metal se usa para casi todo lo que podés construir o investigar. Por eso es recomendable mejorar bien esta mina. Sobre todo al principio es importante que esta mina esté varios niveles por encima de las demás.</p>
<h3>La mina de cristal y el sintetizador de deuterio:</h3>
<p>El cristal es una materia prima importante para edificios, naves e investigaciones. Se produce en menor cantidad que el metal, lo que no lo hace menos valioso. Con el correr del juego vas a ver lo disputado que puede ser el cristal. El deuterio es fuente de energía (sintetizador de deuterio), combustible de flotas y recurso base de algunas investigaciones y construcciones importantes (laboratorio de investigación).</p>
BODY;
$LNG['questions'][1][2]['title']	= 'Paso 2';
$LNG['questions'][1][2]['body']		= <<<BODY
<p>Para agrandar tu imperio y medirte o interactuar con otros jugadores necesitás más edificios. A través de la investigación y la construcción de un hangar comienza el desarrollo de tu flota y de la defensa planetaria. Más detalles acá:</p>
<h3>El hangar:</h3>
<p>Aquí se construyen todas las naves que tenés disponibles en el juego. Aunque el hangar esté disponible muy temprano en el juego, vas a necesitar más investigaciones para poder construir ciertas clases de naves. Podés encontrar un resumen de qué nave o defensa tiene qué requisitos técnicos en el apartado "Tecnología" del menú. Cuanto más alto esté el hangar, más rápido se podrá construir.</p>
<h3>El laboratorio de investigación:</h3>
<p>Aquí se pueden iniciar investigaciones. Sirven para poder construir nuevos edificios, investigaciones y defensas. Además, ciertas investigaciones aportan un bonus a logros ya existentes. Las investigaciones también se pueden acelerar mejorando el laboratorio de investigación.</p>
<h3>La fábrica de robots:</h3>
<p>La fábrica de robots es un edificio esencial. Al mejorarla se reduce el tiempo de producción de naves y el tiempo de construcción de edificios. Si los tiempos de construcción se vuelven muy largos, podés reducirlos mejorando la fábrica de robots.</p>
BODY;
$LNG['questions'][1][3]['title']	= 'Paso 3';
$LNG['questions'][1][3]['body']		= <<<BODY
<p>Esta parte del tutorial está dedicada a la defensa del propio planeta y a las primeras acciones con la propia flota. Se describen brevemente las posibilidades que tenés para enviar la flota e interactuar con otros jugadores.</p>
<h3>La vista de galaxia:</h3>
<p>Sirve para localizar a otros jugadores. Ahí encontrás información detallada de los demás planetas y también podés enviar parte de tu flota directamente desde esa vista. Además, desde esa vista podés contactar a otros jugadores o espiar otro planeta, siempre que ya puedas construir y hayas construido sondas de espionaje.</p>
<h3>Enviar flotas:</h3>
<p>Las flotas se pueden enviar desde la vista de galaxia o desde el apartado "Flota". Primero se elige qué cantidad de naves de un tipo determinado va a volar. Luego hay que configurar cuál es el destino (coordenadas que obtenés en la vista de galaxia) y la velocidad con la que querés llegar. También se puede elegir el tipo de misión, como "Atacar", "Estacionar", "Mantener", "Reciclar" o "Mantener".</p>
<h3>La defensa:</h3>
<p>Para proteger tu propio planeta, con la construcción del hangar también se habilitan las defensas. Estas ofrecen cierta protección contra atacantes y combaten junto a la propia flota que se encuentre en el planeta en el momento del ataque contra el enemigo. A diferencia de la flota, el 70% de la defensa se reconstruye sola después del combate.</p>
BODY;

$LNG['questions'][2]['category']	= 'Información avanzada';
$LNG['questions'][2][1]['title']	= 'Saquear';
$LNG['questions'][2][1]['body']		= <<<BODY
<h3>Saquear:</h3>
<p>Es el término popular para atacar a otros jugadores y apropiarse de sus recursos.
Existen varios tipos de saqueo:</p>
<ul>
	<li>Farmeo</li>
	<li>Ataque a flota</li>
	<li>Saqueo</li>
	<li>Intercepción</li>
</ul>
<h3>Farmeo:</h3>
<p>Son probablemente las acciones más masivas que se realizan por día en un universo.<br>
Para ello se escanean los planetas de los alrededores y se envían pequeñas flotas que tengan suficiente capacidad de transporte y potencia de fuego para romper una defensa pequeña y salir del ataque con ganancia (la suma de recursos robados supera el consumo de deuterio y las pérdidas propias).</p>
<h3>Ataque a flota:</h3>
<p>La categoría reina del saqueo.<br>
Acá se persiguen específicamente flotas enemigas.<br>
Es la categoría reina porque además de sondas de espionaje y una buena dosis de suerte, también influyen las phalanx y un buen timing. Una vez detectada una flota enemiga, solo hay que atraparla y reciclarla. Esto suele no ser fácil, porque las flotas que realmente dan ganancia muchas veces se mueven fuera de la propia capacidad de recicladores. Entonces, además de la flota propia, hay que coordinar los recicladores o, dado el caso, también a los compañeros del SAC.</p>
<h3>Saqueo de campo de escombros:</h3>
<p>La forma más cómoda pero también la más impopular de obtener ganancia. Se les roba el campo de escombros a otros.
Como la regla del campo de escombros dice que no le pertenece a nadie y que se lo puede quedar quien lo encuentre, los "carroñeros" suelen ser un gran fastidio.</p>
<h3>Intercepción</h3>
<p>El sentido de la vida de un fleeter consiste en construir flota y destruir flota. Como no siempre se ven flotas por ahí, a veces hay que esforzarse un poco más, sobre todo para atrapar a muy buenos jugadores. Se pueden interceptar sus flotas cuando savean o cuando lanzan un ataque. Sin embargo, esto generalmente no es tan simple, porque hay formas de protegerse.</p>
<ul>
	<li><p>Si tenés una luna, la intercepción es más fácil que sin luna, porque podés phalanxear otros planetas con tu sensor phalanx (espiar los movimientos de flotas), si están dentro de tu alcance. Si encontrás una flota que vale la pena interceptar, hay que calcular cuánto tiempo sigue volando hasta llegar a su destino, es decir, averiguar el tiempo de regreso. Para eso se necesitan los datos de los motores (motor de combustión, motor de impulso y propulsor hiperespacial), que se pueden averiguar fácilmente con un informe de espionaje. Ahora podés calcular con una calculadora cuánto tiempo sigue volando la flota o usar una herramienta. Un reloj despertador con el que puedas ver la hora exacta a la que llega la flota es una ventaja.</p>
	<p>Una calculadora de tiempo de vuelo de flotas también es útil, te ahorra la calculadora. Encontrás un enlace en las plataformas oficiales.<br>Ahora se lanzan la flota y los recicladores de manera que lleguen 3-5 segundos después de la flota del enemigo a su planeta/luna y la destruyan. Los recicladores también deberían estar bien sincronizados.</p></li>
	<li><p>Si querés interceptar una flota que vuela de la luna a un campo de escombros, necesitás la hora aproximada a la que despegó. Entonces lanzás en el lugar donde creés que va a recolectar el campo de escombros, un campo de escombros visible (por ejemplo, con sondas de espionaje). Ahora calculás cuánto tarda la flota en llegar y a esa hora entrás al sistema y hacés clic una y otra vez en "Actualizar" hasta que el campo de escombros desaparezca. Anotás la hora, mejor también con el reloj despertador, y calculás cuánto tarda la flota en volver. Ahora tomás la hora a la que desapareció el campo de escombros y le sumás el tiempo de vuelo que necesita la flota enemiga para volver, lo que da la hora de llegada. Solo falta sincronizar los recicladores y la flota justo detrás de la flota enemiga y la intercepción está lograda.</p>
	<p><b>Atención:</b> Una intercepción así no siempre sale bien, porque hay formas de protegerse, por ejemplo, enviar un reciclador por delante que ya recolecte el campo de escombros antes.</p></li>
	<li>Otra forma de interceptar es "Mantener" con la propia flota en casa de amigos para protegerlos de otras flotas que los atacan, forzándolas a retirarse porque la flota defensora sería demasiado fuerte. Te podés proteger de ser interceptado haciendo un Savescan (ver Savescan).</li>
	<li><p>Si un jugador vuela de un planeta a otro en modo Estacionar y luego cancela, ya no es visible en la phalanx. Pero también acá hay un truco para atrapar esa flota. Se observa un tiempo el comportamiento de save de la víctima, es decir, cuándo despega y cuándo cancela. Si sabés más o menos cuándo cancela, te ponés de nuevo en su sistema y phalanxeás su planeta segundo a segundo. Si cancela y de repente ya no ves la flota en la phalanx, mirás el reloj despertador que ya se mencionó antes y calculás con el simulador de vuelo de regreso la distancia de retorno, la sumás a la hora de cancelación y lanzás tu flota y recicladores de manera que lleguen aproximadamente 4-6 segundos después de la flota de la víctima.</p><p>Si un jugador savea desde la luna a un campo de escombros y envía uno o varios recicladores por delante, es casi imposible de interceptar. Sin embargo, hay un camino: hay que destruir la luna. Entonces se envía una o varias Estrellas de la Muerte a la luna con el ataque "Destruir" (ver Lunas).</p><p>Una vez destruida la luna, se phalanxea el planeta al que regresa la flota (si la luna ya no está, la flota vuela automáticamente al planeta) y te colgás de nuevo unos segundos detrás de la flota del enemigo.</p><p>En todas estas técnicas es muy útil conocer bien el comportamiento de save del enemigo. Es decir, si sabés que quizás savea todas las noches a las 23 o que se conecta todos los mediodías a las 12. Así que antes de interceptar, estudiá bien al enemigo.</li></ul>
BODY;

$LNG['questions'][2][2]['title']	= 'Savear';
$LNG['questions'][2][2]['body']		= <<<BODY
<h3>Cómo me protejo</h3>
<p>Una gran cantidad de defensas intimida a algunos jugadores, pero lamentablemente atrae a otros, y estos vuelven una y otra vez hasta que te queda muy poco o directamente nada. Así se pierden muchísimos recursos, porque las defensas destruidas no van al campo de escombros. La única excepción son los universos llamados "Deff-en-EF", donde justamente no se construyen tantas defensas, porque eso sería prácticamente regalarle los recursos al atacante.</p>
<p>A esto se suma que también existen los misiles interplanetarios, cuya única tarea es destruir la defensa. A diferencia del ataque normal, las defensas no se reconstruyen. Un ataque bien planificado con misiles interplanetarios reduce mucho el peligro para la propia flota.</p>
<p>Una gran flota también solo detiene a los jugadores que son demasiado débiles, pero los que tienen una flota más fuerte vienen con gusto, porque así también se llevan el campo de escombros generado. Finalmente también está el SAC, que le permite a varios jugadores más débiles unir sus flotas y así ser más fuertes.</p>
<p>Aumentar la tecnología de espionaje es la forma más cara de ocultarle al otro jugador toda la información excepto los recursos presentes. Lamentablemente, se pueden compensar los niveles de espionaje faltantes con la cantidad correspondiente de sondas de espionaje. Y si en el informe de espionaje se ven suficientes recursos, el otro jugador también envía muchas más sondas para enterarse de todo.</p>
<p>La mejor forma de protegerse consiste en que ningún jugador pueda ver cuánto tenés realmente. Eso significa que al menos durante el tiempo en el que no podés estar en internet, enviás tu flota junto con los recursos presentes en el planeta de un planeta a otro. Como no son posibles los ataques en vuelo libre, las naves con los recursos están a salvo por el momento.</p>
<h3>Savear es la mejor defensa</h3>
<p>Savear la flota es uno de los componentes más importantes de OGame, pero lamentablemente muchos jugadores no dominan el save. Por eso acá va una explicación: hay muchas formas de proteger tus recursos y tu flota de manera más o menos segura contra los ataques de flotas enemigas. Algunas son casi 100% seguras, otras sin embargo son muy inseguras.<br>
El primer método de save es el save "Estacionar-Cancelar". Para eso, el jugador envía su flota a un planeta propio cercano con la orden de estacionar. Luego cancela ese vuelo después de un tiempo, ya que el vuelo de regreso de un estacionamiento no es visible en la phalanx. Este método de save no es 100% seguro, pero si no cancelás justo en el último momento sino varias horas antes, solo se puede interceptar con un esfuerzo enorme.</p>
<p>Un método muy difundido para savear la flota es el vuelo de una luna a un campo de escombros. Este es relativamente seguro en sí mismo, porque no se ve en la phalanx. Sin embargo, hay formas de determinar el momento exacto del regreso de la flota, controlando cuándo los recicladores de la flota recolectan el campo de escombros. Una forma de hacer más seguro este tipo de save es enviar por delante de la flota propiamente dicha los llamados "recicladores sombra", que recolectan el campo de escombros antes, de modo que el tiempo queda un poco disimulado. Otra forma de hacer seguro este vuelo es recolectar el campo de escombros en un planeta que esté completamente libre de defensas, ya que este nunca se muestra en la vista de galaxia porque está vacío, pero igual se puede atacar.</p>
<p>El método probablemente más seguro para savear la flota es el estacionamiento de luna a luna. Este vuelo no se puede ver en ninguna phalanx, y tampoco sirve observar los campos de escombros. La única forma de interceptar este vuelo es destruir una de las lunas, lo que en lunas grandes es casi imposible, o muy poco probable/caro.</p>
BODY;

$LNG['questions'][2][3]['title']	= 'Sistema de combate de alianza (SAC)';
$LNG['questions'][2][3]['body']		= <<<BODY
<h3>Atacar con el SAC</h3>
<p>Para que puedan atacar juntos, primero tenés que enviar una flota con la orden "Atacar" al objetivo de su ataque. Una vez iniciado el ataque, podés convertir tu flota en una agrupación de flotas desde el menú de flota con el botón "Agrupación". En el menú de agrupación de flotas tenés la posibilidad de renombrar la agrupación e invitar a nuevos jugadores, quedando el jugador que inició el ataque invitado automáticamente. Ahora solo falta que se sumen todas las flotas deseadas y su agrupación de flotas estará completa. Para eso, cada jugador invitado debe indicar las coordenadas correctas del objetivo al enviar sus propias naves, seleccionar la orden "Ataque de agrupación" y enviar la flota. La agrupación siempre vuela el tiempo que necesita la subflota más lenta. Las flotas más rápidas no modifican el tiempo restante de vuelo cuando se unen a la agrupación. Las flotas más lentas, sin embargo, aumentan el tiempo restante de vuelo a su propio tiempo de vuelo. También hay que tener en cuenta que como máximo 5 jugadores pueden volar un ataque conjunto y que en total pueden volar como máximo 16 flotas individuales en una agrupación. Una flota que se une a una agrupación puede aumentar su tiempo restante de vuelo como máximo un 30%. Si el tiempo restante de vuelo es de 100 minutos, una flota que quiera unirse a la agrupación en ese momento puede tener como máximo un tiempo de vuelo de 130 minutos.<br>
<b>Atención:</b> si se llama de vuelta la flota del fundador de la agrupación, ¡las demás siguen volando igual!</p>
<h3>Defender con el SAC</h3>
<p>Si sos atacado por una flota enemiga, tenés la posibilidad de hacerte ayudar por jugadores amigos, sin importar si el atacante es simplemente demasiado fuerte para vos solo o si buscás menos pérdidas y más ganancia en una intercepción. Para que los jugadores amigos puedan ayudarte, deben enviarte su flota como apoyo. Pueden ser todos los jugadores que pertenezcan a tu alianza o estén en tu lista de amigos. Si es así, pueden seleccionar en su menú de flota las coordenadas donde sos atacado, configurar cuánto tiempo quieren estacionar sus flotas en tu planeta y luego despegar con la orden "Mantener". Además del costo de deuterio por el vuelo, según el tamaño de la flota y la duración de la estadía se cobran costos adicionales, que se descuentan directamente al iniciar. Mientras las flotas amigas están estacionadas en tu planeta, participan en todos los combates en ese planeta o luna. Aparecen en un informe de espionaje como si fueran tus propias naves. Por eso es importante enviar las flotas que mantienen de manera que lleguen relativamente justo antes de la flota atacante, para no ser descubiertas en un posible Savescan. Los jugadores que enviaron sus flotas como apoyo pueden llamarlas de vuelta en cualquier momento desde el menú de flota. Si no se usa esta posibilidad, la flota simplemente espera el tiempo de mantenimiento configurado y luego vuelve a su dueño.</p>
<h3>Consumo de deuterio por 1 hora de mantenimiento:</h3>
<p>Nave pequeña de carga: 5<br>
Nave grande de carga: 5<br>
Cazador ligero: 2<br>
Cazador pesado: 7<br>
Crucero: 30<br>
Nave de batalla: 50<br>
Colonizador: 100<br>
Reciclador: 30<br>
Sonda de espionaje: 1/10<br>
Bombardero: 100<br>
Destructor: 100<br>
Estrella de la Muerte: 1/10</p>
BODY;

$LNG['questions'][2][4]['title']	= 'Lunas';
$LNG['questions'][2][4]['body']		= <<<BODY
<p>Una luna puede formarse cuando se genera un campo de escombros de al menos 100.000 unidades, que da un 1% de probabilidad de luna. El máximo es solo 20% de probabilidad de luna, sin importar qué tan grande sea el campo de escombros.</p>
<h3>Generalidades</h3>
<p>Las lunas se pueden renombrar como los planetas, solo que detrás del nombre siempre queda "(Luna". Se puede tener como máximo una luna por planeta. Las lunas sirven para poder savear de forma invisible para los demás, así que una luna debería dispararse relativamente temprano. En la luna se pueden construir fábrica de robots, hangar, almacén de metal, almacén de cristal, contenedor de deuterio, depósito de la alianza, base lunar, sensor phalanx y salto cuántico.</p>
<h3>Disparo de luna</h3>
<p>Se llama disparo de luna a la destrucción intencional de naves para generar un campo de escombros. Generalmente se usan cazadores ligeros, exactamente 1667 para obtener un 20% de probabilidad. Se usan CL porque son relativamente fáciles de destruir y porque se acercan mucho al 20% de probabilidad. Al disparar una luna hay que tener en cuenta que si el más fuerte destruye los CL del más débil, solo el más débil puede recolectar el campo de escombros. Y si el más débil ataca al más fuerte con naves a destruir, entonces de nuevo solo el más débil puede recolectar el campo de escombros, de lo contrario sería pushing.</p><p>En un universo con defensas-en-EF es mejor construir defensa y hacer que la destruyan en varias oleadas para poder hacer varios intentos de luna seguidos. Para eso se recomiendan 3334 lanzamisiles o 3334 láseres pequeños.</p><p>Cuando se formó una luna, en el informe de batalla dice "Las enormes cantidades de metal y cristal libres se atraen y forman un satélite alrededor del planeta".</p><p>Probabilidad de luna entre 1% y 19% ' Tamaño aleatorio. Probabilidad de luna del 20% ' Luna con más de 8000km de diámetro.<br>Una luna nunca puede tener más de 8944 km de diámetro.</p>
<h3>Edificios y construcción</h3>
<p>Los edificios, como ya se dijo arriba, son fábrica de robots, hangar, almacén de metal, almacén de cristal, contenedor de deuterio, depósito de la alianza, base lunar, sensor phalanx y salto cuántico. Sin embargo, no se deberían construir de ninguna manera los contenedores y almacenes, porque en la luna no tienen sentido, ya que de todos modos no se produce nada. Tampoco se debería construir necesariamente el hangar, porque tampoco sirve de mucho construir naves y defensas en la luna, por los largos tiempos de construcción. Con respecto al depósito de la alianza hay opiniones divididas sobre si vale la pena construirlo, pero ocupa campos valiosos.<br>
Los tres edificios especiales de la luna son:</p>
<ul><li><p><b>Base lunar</b><br>Sirve para crear nuevos campos construibles, por cada nivel mejorado se obtienen 3 nuevos campos en la luna, y uno de ellos debería ocupar la base del siguiente nivel.</p></li>
<li><p><b>Sensor phalanx</b><br>Sirve para poder ver en planetas enemigos qué movimientos de naves tiene en ese momento, aunque esto aplica a planetas y no a lunas. Por cada nivel mejorado aumenta el alcance.</p></li>
<li><p><b>Salto cuántico</b><br>Con el salto cuántico se pueden transferir naves sin pérdida de tiempo de una luna a otra, pero no se pueden llevar recursos. Entre 2 saltos debe pasar 1 hora, de lo contrario el salto cuántico se sobrecalienta.</p></li></ul>
<p>A continuación una lista con la construcción óptima de una luna:<br>
<b>Leyenda:</b><br>
BL – Base lunar<br>
SP – Sensor phalanx<br>
SC – Salto cuántico<br>
FR – Fábrica de robots</p>
<p>BL1 – FR1 – FR2 – BL2 – SP1 – FR3 – BL3 – SP2 – FR4 – BL4 – SP3 – FR5 – BL5 – SP4 – FR6 – BL6 – SP5 – SP6 – BL7 – SP7 – SP8 – BL8 – SC1<br>
Después de esta lista se puede seguir mejorando SP si se quiere o se tienen suficientes recursos. ¡También se puede demoler un poco la fábrica de robots y luego seguir mejorando SP!</p>
<h3>Destrucción</h3>
<p>Una luna también puede ser destruida, pero esto solo es posible con Estrellas de la Muerte.</p>
<p>En el menú de órdenes se selecciona "Destruir" en lugar de "Atacar". Pero primero hay que destruir la flota que está en la luna con la Estrella de la Muerte antes de que pueda intentar destruir la luna. Las Estrellas de la Muerte, por supuesto, también pueden ser destruidas en la destrucción de la luna misma si sobrevivieron al combate. La particularidad de la destrucción de la luna: ¡no se genera campo de escombros!</p>
<h3>Ataques a la luna con Estrellas de la Muerte:</h3>
<p>La probabilidad de destruir la luna es "(100 - Raíz(tamaño de luna)) * Raíz(cantidad de EM)". La probabilidad de que las EM enviadas al ataque sean destruidas en el ataque a la luna es "Raíz(tamaño de luna) / 2". Cuanto más grande la luna, más riesgoso es el intento de destruirla.</p>
<h3>Probabilidad de luna y tamaño de luna:</h3>
<p>100.000 unidades de EF dan 1% de probabilidad de luna. Probabilidad máxima de luna: 20%. Desde un cambio, todos los dueños de lunas tienen disponible la cantidad máxima de campos construibles (79). <br>
Antes se calculaba así:<br>
Campos máximos = REDONDEAR((diámetro de la luna/1000)²)<br>
Luna más grande posible: 8944 km de diámetro, es decir, 79 campos.</p>
BODY;

$LNG['questions'][2][5]['title']	= 'Alianzas';
$LNG['questions'][2][5]['body']		= <<<BODY
<h3>¿Cómo fundo una alianza?</h3>
<p>Para fundar una alianza, hacé clic en el menú de la izquierda en "Alianzas". Después hacé clic en "Fundar mi propia alianza". En el menú siguiente tenés que ingresar una "Etiqueta de alianza" y un nombre de alianza; la "etiqueta de alianza" es la abreviatura de tu alianza. Por ejemplo: si llamás a tu alianza "La Súper Alianza", una etiqueta posible sería "LSA".<br>
Tené en cuenta que no se permiten caracteres especiales, solo se pueden usar letras, números y espacios.<br>
Una vez que ingresaste la etiqueta y un nombre, hacé clic en "Fundar".<br>
Si ya existe una alianza con ese nombre o etiqueta, recibirás un mensaje correspondiente; en ese caso tendrás que pensar otra etiqueta u otro nombre.<br>
Si la alianza se fundó con éxito, también te lo mostrará. Si después hacés clic en "Continuar", entrás al menú de alianza todavía vacío, al que a partir de ahora podés acceder haciendo clic en "Alianzas" en el menú de la izquierda. Ahí vas a ver varias opciones e informaciones, arriba de todo la etiqueta y el nombre de tu alianza.</p>
<p>Debajo encontrás los siguientes enlaces:<br>
"Lista de miembros": en la lista de miembros ves a todos los miembros de tu alianza, con sus puntos, coordenadas del planeta principal y la fecha de su ingreso, así como su estado en línea. Con un clic en los encabezados de las columnas podés cambiar el orden de clasificación.<br>
"Tu rango": acá está el nombre de tu rango, al lado encontrás el enlace al menú de administración de la alianza, del que hablamos en seguida.<br>
"Mensaje circular": con un clic en "Enviar mensaje circular" podés enviar un mensaje a toda la alianza o solo a determinados rangos.</p>
<h3>El menú de administración de la alianza</h3>
<p>Bien arriba en el menú de administración de la alianza está el enlace "Configurar permisos". Ahí podés configurar los permisos para los distintos rangos, por ejemplo, el permiso para disolver la alianza o enviar mensajes circulares. Debajo encontrás el enlace "Administrar miembros". Ahí podés expulsar miembros de la alianza, asignarles rangos y también ver cuántos días hace que no se conectan a sus cuentas. Con los dos botones debajo del enlace "Administrar miembros" podés cambiar la etiqueta y el nombre de la alianza.<br>
En "Gestión de textos" podés cambiar los textos de la alianza. El texto externo lo ve cualquier jugador de OGame, el texto interno solo los miembros de tu alianza. El texto de solicitud es una especie de plantilla para las personas que se postulan a tu alianza.<br>
En la configuración podés enlazar una imagen que se mostrará en la página de la alianza, así como ingresar un enlace a un foro de alianza, si tenés uno. Además podés establecer si las solicitudes son posibles o no, y qué nombre de rango querés usar como fundador. Si no ingresás nada ahí, tu nombre de rango es "Fundador".<br>
Con "Disolver alianza" podés, lógicamente, disolver la alianza, y con "Transferir/Asumir alianza" podés pasarle la alianza a otro miembro de la alianza, que entonces obtiene el estado de fundador.</p>
BODY;
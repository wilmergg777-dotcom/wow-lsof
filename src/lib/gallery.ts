// ============================================================
// GALERÍA DE FOTOS DE LA TIENDA
// Fotos guardadas dentro de Violetero (carpeta public/gallery).
// Sirven para publicar ofertas cuando el vendedor no tiene
// foto propia: elige una de las fotos disponibles en la tienda.
// ============================================================

export type GalleryPhoto = {
  src: string // ruta de la foto guardada en la tienda
  label: string // nombre para mostrar
  category: string // categoría sugerida
}

export const GALLERY: GalleryPhoto[] = [
  { src: '/gallery/auriculares-1.jpg', label: 'Auriculares', category: 'Electrónica' },
  { src: '/gallery/auriculares-2.jpg', label: 'Auriculares para música', category: 'Electrónica' },
  { src: '/gallery/audifonos-1.jpg', label: 'Audífonos inalámbricos', category: 'Electrónica' },
  { src: '/gallery/audifonos-2.jpg', label: 'Audífonos deportivos', category: 'Electrónica' },
  { src: '/gallery/altavoz-1.jpg', label: 'Altavoz Bluetooth', category: 'Electrónica' },
  { src: '/gallery/altavoz-2.jpg', label: 'Altavoz portátil', category: 'Electrónica' },
  { src: '/gallery/tableta-1.jpg', label: 'Tableta', category: 'Electrónica' },
  { src: '/gallery/tableta-2.jpg', label: 'Tableta con teclado', category: 'Electrónica' },
  { src: '/gallery/reloj-1.jpg', label: 'Reloj deportivo', category: 'Deportes' },
  { src: '/gallery/reloj-2.jpg', label: 'Pulsera de actividad', category: 'Deportes' },
  { src: '/gallery/mouse-1.jpg', label: 'Mouse inalámbrico', category: 'Computadoras' },
  { src: '/gallery/mouse-2.jpg', label: 'Mouse ergonómico', category: 'Computadoras' },
  { src: '/gallery/teclado-1.webp', label: 'Teclado mecánico', category: 'Computadoras' },
  { src: '/gallery/teclado-2.png', label: 'Teclado inalámbrico', category: 'Computadoras' },
  { src: '/gallery/monitor-1.jpg', label: 'Monitor de oficina', category: 'Computadoras' },
  { src: '/gallery/monitor-2.png', label: 'Monitor curvo', category: 'Computadoras' },
  { src: '/gallery/computadora-1.jpg', label: 'Computadora de escritorio', category: 'Computadoras' },
  { src: '/gallery/computadora-2.jpg', label: 'PC para el hogar', category: 'Computadoras' },
  { src: '/gallery/laptop-1.jpg', label: 'Laptop', category: 'Computadoras' },
  { src: '/gallery/laptop-2.jpg', label: 'Laptop delgada', category: 'Computadoras' },
  { src: '/gallery/olla-1.jpg', label: 'Olla eléctrica', category: 'Hogar y cocina' },
  { src: '/gallery/olla-2.jpg', label: 'Olla de presión', category: 'Hogar y cocina' },
  { src: '/gallery/cafetera-1.jpg', label: 'Cafetera espresso', category: 'Hogar y cocina' },
  { src: '/gallery/cafetera-2.jpg', label: 'Cafetera de filtro', category: 'Hogar y cocina' },
  { src: '/gallery/batidora-1.jpg', label: 'Batidora de pie', category: 'Hogar y cocina' },
  { src: '/gallery/batidora-2.jpg', label: 'Batidora profesional', category: 'Hogar y cocina' },
  { src: '/gallery/robot-1.jpg', label: 'Robot aspirador', category: 'Hogar y cocina' },
  { src: '/gallery/robot-2.jpg', label: 'Robot de limpieza', category: 'Hogar y cocina' },
  { src: '/gallery/perfume-1.jpeg', label: 'Perfume', category: 'Belleza' },
  { src: '/gallery/perfume-2.jpg', label: 'Set de perfumes', category: 'Belleza' },
  { src: '/gallery/vestido-1.jpg', label: 'Vestido', category: 'Ropa' },
  { src: '/gallery/vestido-2.jpg', label: 'Blusa', category: 'Ropa' },
  { src: '/gallery/chaqueta-1.jpg', label: 'Blazer', category: 'Ropa' },
  { src: '/gallery/chaqueta-2.jpg', label: 'Chaqueta casual', category: 'Ropa' },
  { src: '/gallery/camiseta-1.jpg', label: 'Camiseta deportiva', category: 'Deportes' },
  { src: '/gallery/camiseta-2.jpg', label: 'Conjunto deportivo', category: 'Deportes' },
  { src: '/gallery/zapatillas-1.jpg', label: 'Zapatillas', category: 'Deportes' },
  { src: '/gallery/zapatillas-2.jpg', label: 'Zapatillas de correr', category: 'Deportes' },
  { src: '/gallery/juguete-1.jpg', label: 'Peluche', category: 'Juguetes' },
  { src: '/gallery/juguete-2.jpeg', label: 'Set de juguetes', category: 'Juguetes' },
]

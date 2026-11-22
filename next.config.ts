import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  /* config options here */
  typescript: {
    ignoreBuildErrors: true,
  },
  reactStrictMode: false,
  // Parches de seguridad anti-ataques (cabeceras HTTP)
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          // Evita que otras webs incrusten Violetero en un iframe (clickjacking)
          { key: "X-Frame-Options", value: "DENY" },
          // Evita que el navegador adivine el tipo de contenido
          { key: "X-Content-Type-Options", value: "nosniff" },
          // No enviar la URL de origen a otras webs
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          // Limitar APIs del navegador (cámara, micro, geolocalización…)
          {
            key: "Permissions-Policy",
            value: "camera=(), microphone=(), geolocation=(self), payment=()",
          },
          // Fuerza HTTPS cuando haya certificado disponible
          {
            key: "Strict-Transport-Security",
            value: "max-age=31536000; includeSubDomains",
          },
          // Aísla el documento del navegador (protección Spectre/fuga de datos)
          { key: "Cross-Origin-Opener-Policy", value: "same-origin" },
        ],
      },
    ];
  },
};

export default nextConfig;

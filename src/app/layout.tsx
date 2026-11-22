import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "@/components/ui/toaster";

export const metadata: Metadata = {
  title: "Violetero: Tienda online con mini tiendas y entrega a domicilio",
  description:
    "Violetero es tu tienda online: compra en mini tiendas de emprendedores, recibe a domicilio con repartidores y vende tus propios productos.",
  keywords: ["Violetero", "tienda online", "mini tiendas", "entrega a domicilio", "ofertas"],
  icons: {
    icon: "https://z-cdn.chatglm.cn/z-ai/static/logo.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" suppressHydrationWarning>
      <body className="antialiased bg-white text-foreground">
        {children}
        <Toaster />
      </body>
    </html>
  );
}
